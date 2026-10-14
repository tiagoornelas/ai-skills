# Database Queries and Schema Migrations

> **Central thesis**: Database schemas and queries execute against shared state under strict concurrency constraints. Unlike transient in-memory code, database oversights directly cause production downtime: exclusive table locks halting incoming HTTP traffic, unindexed queries exhausting CPU and connection pools, and unbounded result sets crashing application runtimes. This reference defines operational safety and performance criteria for database migrations and queries.

---

## When to Consult

- When authoring, reviewing, or refactoring database migrations, schema definitions, or DDL scripts.
- When writing, modifying, or reviewing SQL queries, ORM calls, repositories, query builders, or GraphQL resolvers.
- During [`agent-self-review`](../../agent-self-review/SKILL.md) and [`github-code-review`](../../github-code-review/SKILL.md) whenever a changeset touches database access patterns or schema files.

---

## 1. Severity Scale

Every database finding maps to the standard severity scale:

| Severity | Operational Criteria | Action in Self-Review | Action in PR Review |
| :--- | :--- | :--- | :--- |
| 🔴 **Critical** | Exclusive table locks on active tables, non-concurrent index creation on production tables, destructive schema changes lacking zero-downtime transition, or N+1 queries in high-frequency / hot execution paths. | **Blocking** (must fix before delivery) | **Critical** (request changes, cannot merge as-is) |
| 🟡 **Warning** | Missing indexes on foreign keys or frequent filter/join predicates, unbounded queries lacking `LIMIT`, N+1 queries in low-traffic or administrative endpoints, or wide table scans on growing collections. | **Should fix** (within budget) | **Warning** (warrants discussion) |
| 🟢 **Suggestion** | Suboptimal compound index column ordering, high-offset pagination where cursor pagination is cleaner, or redundant query projections. | Discard or single-line note | **Suggestion** (optional improvement) |

---

## 2. Schema Migrations and DDL Safety

Database migrations run in production with production traffic active. Any migration that blocks read or write operations across an entire table must be prevented.

### 2.1. Table Locks and Table Rewrites
- **The Hazard**: Operations that acquire `ACCESS EXCLUSIVE` locks on PostgreSQL or `EXCLUSIVE` metadata locks in MySQL/MariaDB queue behind any ongoing read or write transaction, while blocking *all* subsequent incoming queries. The connection pool saturates in seconds, causing total service unavailability.
- **Rules**:
  1. **Lock Timeouts**: Always specify explicit, short lock timeouts on migration scripts (e.g., `SET lock_timeout = '2s'; SET statement_timeout = '5s';`). If the lock cannot be acquired within 2 seconds, fail the migration rather than queueing and bringing down the application.
  2. **Non-concurrent Index Creation**: Never use plain `CREATE INDEX` on existing tables with significant row count. In PostgreSQL, always use `CREATE INDEX CONCURRENTLY` (executed outside a transaction block). In MySQL, ensure `ALGORITHM=INPLACE, LOCK=NONE`.
  3. **Adding Columns with Defaults**: In PostgreSQL < 11 and older MySQL versions, `ADD COLUMN ... DEFAULT <value>` with non-null values rewrites the entire table. In modern engines, verify that the default is static and non-volatile (e.g., `now()` or random expressions may force table rewrites).
  4. **Adding NOT NULL Constraints**: Adding `NOT NULL` to an existing column requires scanning the whole table. In PostgreSQL, prefer:
     - Add a `CHECK (col IS NOT NULL) NOT VALID;` (instant lock).
     - Validate the constraint concurrently: `ALTER TABLE ... VALIDATE CONSTRAINT ...;` (no exclusive table lock).
     - Then convert to `NOT NULL` in a subsequent step if required.

### 2.2. Backward-Compatible Changes (Expand and Contract)
- **The Hazard**: Deployments are rolling or blue/green; old and new application code run simultaneously during releases. Renaming or dropping a column/table immediately breaks the running old code.
- **Rules**:
  1. **Never drop or rename a column in a single release**: Follow the *Expand and Contract* pattern across releases:
     - *Phase 1 (Expand)*: Add new column or table.
     - *Phase 2 (Migrate)*: Deploy application writing to both columns (dual-write) and reading with fallback; backfill existing rows.
     - *Phase 3 (Contract)*: Deploy application reading and writing solely from new column.
     - *Phase 4 (Cleanup)*: Remove old column via migration.
  2. **Safe Column Type Changes**: Changing a column type (e.g., `VARCHAR(50)` to `VARCHAR(100)` or `INT` to `BIGINT`) often triggers a table rewrite. Where dangerous, add a new column of the target type, dual-write, and backfill.

### 2.3. Data Migrations & Backfills
- **The Hazard**: Running heavy data updates (`UPDATE users SET status = 'active' WHERE ...` across millions of rows) inside a DDL transaction creates massive write-ahead log (WAL) bloat, holds row locks for minutes, and risks transaction rollback on timeouts.
- **Rules**:
  1. **Separate DDL from DML**: Keep schema changes (DDL) separate from data backfill scripts (DML).
  2. **Batch Data Backfills**: Backfill rows in bounded chunks (e.g., batches of 1,000–5,000 records) with sleep intervals or background workers, committing each batch independently.

---

## 3. Query Performance and Access Patterns

### 3.1. N+1 Queries
- **Signal**: Executing an initial query to fetch $N$ parent records, followed by a loop that issues $N$ subsequent queries to fetch child relationships or related attributes.
- **Why it Hurts**: Amplifies network round-trips and connection acquisition overhead. 100 items become 101 database round-trips, causing latency spikes and connection pool starvation.
- **Remediations**:
  - Use eager loading / relationship joins (e.g., `JOIN`, `includes`, `prefetch_related`, `select_related`).
  - Batch fetch child IDs in a single query: `WHERE parent_id IN (...)` and assemble in memory.
  - In GraphQL, use dataloaders to batch and memoize entity resolution across sub-fields.

### 3.2. Indexing and Predicate Traps
- **Signal**: Queries filtering (`WHERE`), joining (`ON`), grouping (`GROUP BY`), or ordering (`ORDER BY`) on columns lacking an index, or utilizing patterns that prevent index utilization.
- **Common Traps**:
  1. **Function Wrapping on Columns**:
     - *Anti-pattern*: `WHERE LOWER(email) = 'user@example.com'` or `WHERE DATE(created_at) = '2026-10-14'` forces a full sequential scan because the standard B-tree index on `email` or `created_at` cannot be used.
     - *Remediation*: Query across a range (`WHERE created_at >= '2026-10-14' AND created_at < '2026-10-15'`), or create an expression/functional index (`CREATE INDEX ON users (LOWER(email))`).
  2. **Leading Wildcard Search**:
     - *Anti-pattern*: `WHERE name LIKE '%term%'` prevents index range scans.
     - *Remediation*: Use trailing wildcard `WHERE name LIKE 'term%'`, or implement Full-Text Search (trigram index `pg_trgm`, GIN/GiST index) or search engines (Elasticsearch).
  3. **Foreign Keys Missing Indexes**: Foreign key columns (`user_id`, `tenant_id`, `order_id`) used in join conditions must almost always be indexed. Missing foreign key indexes cause sequential scans on joins and trigger full table scans during parent record deletions or cascades.
  4. **Compound Index Ordering**:
     - Compound index on `(A, B)` can satisfy queries on `WHERE A = 1` and `WHERE A = 1 AND B = 2`, but **cannot** satisfy `WHERE B = 2` without checking `A`.
     - Order columns: high-cardinality equality filters first, range/inequality filters last.

### 3.3. Unbounded Queries and Result Sets
- **Signal**: `SELECT * FROM orders WHERE user_id = ?` without a `LIMIT` clause or pagination.
- **Why it Hurts**: A user or tenant with thousands of records will exhaust memory, transfer megabytes of unneeded payload over the wire, and cause latency jitter.
- **Remediations**:
  - Always enforce pagination or maximum limits on list/search endpoints.
  - Use **Keyset / Cursor Pagination** (`WHERE id > :last_seen_id ORDER BY id ASC LIMIT 50`) for high-volume streams instead of deep offset pagination (`OFFSET 100000 LIMIT 50`), which forces scanning and discarding 100,000 rows.
  - Project only needed columns instead of `SELECT *` when payloads or join widths are large.

### 3.4. Transaction Lifespan and Scope
- **Signal**: Opening a database transaction and performing long-running computations, third-party HTTP requests, file uploads, or waiting on external message queues inside the transaction block.
- **Why it Hurts**: Holds database connection leases and locks open while waiting on non-database I/O, leading to connection pool exhaustion and cascading timeouts.
- **Remediation**: Keep transactions strictly around database writes. Complete external I/O *before* opening the database transaction, or dispatch asynchronous follow-ups *after* the transaction commits.

---

## 4. Operational Anti-Pattern Catalog

| Smell / Anti-Pattern | Signal | Operational Hazard | Safe Remediation | Severity |
| :--- | :--- | :--- | :--- | :---: |
| **Blocking Index Creation** | `CREATE INDEX` on table without concurrency directive. | Acquires exclusive write lock on entire table for the duration of the index build. | `CREATE INDEX CONCURRENTLY` (PostgreSQL) or `ALGORITHM=INPLACE` (MySQL). | 🔴 |
| **Missing Lock Timeout** | Migration script lacks `lock_timeout`. | Migration queues behind slow read queries, blocking all incoming requests and starving connection pool. | Set explicit `lock_timeout = '2s'` at start of migration. | 🔴 |
| **Hot Path N+1** | Association queried inside loop within critical API endpoint. | Multiplies query volume by order of magnitude; saturates database connections. | Eager loading, batched `IN (?)` queries, or dataloaders. | 🔴 |
| **Destructive Single-Step Drop** | Column or table dropped in same migration where application stops using it. | In-flight requests or rolling deployment nodes crash on missing column. | Expand-and-contract rollout across distinct deployments. | 🔴 |
| **Unindexed Foreign Key / Join** | Foreign key column without index used in joins or cascaded deletes. | Full table scan on every join; slow cascaded deletes. | Add index on foreign key column. | 🟡 |
| **Unbounded Query** | Collection query lacking `LIMIT` or pagination. | OOM crash, excessive latency on large datasets. | Enforce pagination with default and max limits. | 🟡 |
| **Function Wrapped Filter** | `LOWER(col) = ?` or date truncation on indexed column. | Nullifies index, forcing full table scan. | Functional index or range query. | 🟡 |
| **External I/O in Transaction** | `fetch()`, email dispatch, or heavy hashing inside DB transaction. | Prolongs connection hold times; starves pool. | Perform I/O outside transaction scope. | 🟡 |
| **Deep Offset Pagination** | `OFFSET 50000 LIMIT 50` on large dataset. | Reads and discards 50,000 rows before returning page. | Keyset/cursor pagination (`WHERE id > ?`). | 🟢 |

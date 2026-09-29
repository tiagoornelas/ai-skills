# Dependencies Point Toward Business Rules

> **Central thesis**: separate **policy** (business rules) from **details** (persistence, UI, frameworks, external vendors, delivery mechanisms) and ensure code dependencies cross that boundary **in a single direction: pointing inward toward policy**. Business rules declare the **ports** they require, using their own vocabulary; infrastructure details implement them as **plug-ins**. Consequently, no change to an infrastructure detail forces changes to core business policy.

---

## When to consult

- When establishing or reviewing **dependency direction** between modules.
- When business logic requires external capabilities (databases, message queues, HTTP endpoints, system clocks, third-party APIs).
- When architecting system boundaries and separating core domain logic from infrastructure plumbing.
- Under pressure to commit prematurely to database engines, frameworks, or cloud topologies.

---

## 1. Policy vs. Detail

- **Policy**: rules that exist independently of computers (computations, validations, domain decisions, business workflows). It defines what the system **is**.
- **Detail**: technical mechanisms used to transport, store, or display information (databases, web frameworks, CLI parsers, message queues, vendor SDKs). It defines **how** the system executes today, and can change without changing business logic.
- Policy and details change for different reasons and at different cadences. This divergence justifies an architectural boundary between them.
- Terminology: this reference uses **policy × detail** rather than ambiguous "high/low level". "Upper/lower layer" retains the meaning from [different-layer-different-abstraction.md](different-layer-different-abstraction.md) and [general-purpose-modules.md](general-purpose-modules.md) (general-purpose mechanisms sit lower, consumed by higher layers).

---

## 2. Boundaries and Directionality

- The direction of **source code dependencies** (who imports or references whom) does not need to mirror runtime **control flow** (who invokes whom during execution).
- At runtime, business rules invoke persistence operations. In source code, however, persistence modules depend on the port declared by the business rules:

```text
Orders ──declares──▶ OrderRepository.save(order)
                              ▲
PostgresPersistence ──implements──┘
```

- Every arrow crossing the architectural boundary points toward policy. The core domain knows nothing about the concrete database, web framework, or third-party service on the other side.
- Consequence: business rules can be **understood and tested in isolation**, with zero dependency on databases, web servers, or cloud infrastructure.

---

## 3. The Port Belongs to Policy

- The port is declared **by the domain core**, expressed in the **domain's own vocabulary**, containing **only the operations it requires**. To the domain, `OrderRepository` is an intrinsic domain concept, not an accommodation for an external client.
- This aligns with [general-purpose-modules.md](general-purpose-modules.md). The two principles govern different boundaries:
  - **at the boundary between policy and detail**, the port lives on the policy side and uses policy vocabulary;
  - **behind the port**, infrastructure adapters consume general-purpose utilities expressed in infrastructure vocabulary (SQL drivers, key-value stores, HTTP clients).
- Ports must be **deep** and **encapsulate** all infrastructure details (see [information-hiding.md](information-hiding.md)). A port that merely mirrors database APIs or SDK types fails to protect the core: infrastructure concepts (tables, transaction handles, HTTP status codes, vendor pagination tokens) leak directly into business logic.

---

## 4. Details as Plug-ins

- By placing ports on the policy side, infrastructure details become interchangeable **plug-ins**: they can be swapped, duplicated (in-memory doubles for tests vs. production implementations), or deferred without touching core logic.
- The relationship is **asymmetric**: plug-ins know the core; the core does not know plug-ins exist.
- This requires **substitutability**: every implementation must fulfill the complete contract, including informal behavioral guarantees (see [deep-modules.md](deep-modules.md)).

### Deferring Decisions

- With ports established, technical decisions (database engine, framework, cloud vendor, service boundaries) can be **deferred** until sufficient operational data exists. Development begins with the simplest lightweight implementation that satisfies the contract.
- Infrastructure decisions made prematurely before understanding use cases contaminate domain models and incur heavy downstream costs.

---

## 5. Composition Roots

- Somewhere in the application, concrete implementations must be instantiated and injected into ports.
- Concentrate concrete wiring into **centralized composition roots** (the `main` function, a dependency injection container, application bootstrap scripts), keeping instantiation out of business logic.

---

## 6. Taking It Too Far

- **Invert dependencies only at genuine policy/detail boundaries.** Within domain policy, or within a single infrastructure adapter, direct dependencies between cohesive classes are simpler and more obvious. Creating an interface for every single class with only one implementation breeds shallow modules and **obscurity** (forcing readers to hunt for the actual execution path). See [deep-modules.md](deep-modules.md) and [obvious-code.md](obvious-code.md).
- **Stable dependencies can remain direct.** Language standard libraries and fundamental primitives change rarely; wrapping them behind custom ports adds boilerplate without protection.
- **Logical boundaries precede physical boundaries.** Architectural boundaries do not require microservices, separate processes, or message queues: in most cases, clean interfaces and correct dependency arrows in code are sufficient. Physical boundaries introduced prematurely impose distributed systems overhead without architectural benefits.
- **Do not decouple things that change together.** An improperly placed boundary amplifies changes across every new feature. Cross-reference with [together-or-apart.md](together-or-apart.md).

---

## Red Flags

- Business logic importing database drivers, web frameworks, cloud SDKs, or queue libraries.
- Infrastructure concepts (tables, transactions, HTTP codes, cloud payloads) surfacing in domain types.
- Ports that mirror vendor APIs rather than expressing core domain needs.
- Business rules untestable without booting a database, web server, or cloud emulator.
- Changing infrastructure requires modifying business policy.
- Dependency arrows crossing an architectural boundary in both directions.
- Direct instantiation of concrete infrastructure classes scattered across business services.
- The inverse anti-pattern: one-to-one interfaces with zero policy/detail boundary to protect.

---

## How to Apply

1. On the module map, **classify every module** as policy or detail. When classification hinges on business context, confirm with the human.
2. **Draw the boundary** between policy and detail.
3. For every dependency pointing from policy toward detail, **define a port on the policy side**, in policy vocabulary, containing only the operations the policy needs. The detail implements the port.
4. Verify that the port **encapsulates** the detail: no infrastructure artifacts may leak through.
5. **Centralize instantiation** of concrete classes within composition roots.
6. **The plug-in test**: for each detail, ask "Can this be replaced with an in-memory double without editing business logic?" If not, the boundary is leaking.
7. List **infrastructure decisions that can be deferred** and the criteria needed to make them.

When presenting to the human, highlight core domain, plug-ins, and boundary lines on the module map, showing all boundary-crossing arrows pointing inward, accompanied by interface cards for each port. Dependency direction, ports, and deferred decisions belong to the Human Layer.

---

## Relationships

- Ports must be deep and encapsulate implementation details: [deep-modules.md](deep-modules.md) and [information-hiding.md](information-hiding.md).
- Behind the port, general-purpose modules in their own vocabulary: [general-purpose-modules.md](general-purpose-modules.md).
- Each side of the boundary provides a different abstraction: [different-layer-different-abstraction.md](different-layer-different-abstraction.md).
- The cost of separating things that change together: [together-or-apart.md](together-or-apart.md).
- Dependencies as a primary driver of complexity: [nature-of-complexity.md](nature-of-complexity.md).

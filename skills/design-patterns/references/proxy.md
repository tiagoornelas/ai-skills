# Proxy

> **Structural Pattern** — Refactoring Guru Catalog
> Lets you provide a substitute or placeholder for another object. A proxy controls access to the original object, allowing you to perform something either before or after the request gets through to the original object.

---

## 1. Intent & Core Mechanism

Implements the same interface as the real service object. When clients call the proxy, it performs auxiliary operations (lazy initialization, access control, caching, logging, remote serialization) before or instead of delegating to the real service.

---

## 2. When Justified

- **Lazy initialization (Virtual Proxy)**: Delaying the heavy instantiation of a resource until its first actual method invocation.
- **Access control (Protection Proxy)**: Verifying caller credentials or permissions before passing requests.
- **Caching (Caching Proxy)**: Storing operation results to avoid repeated expensive calls.
- **Remote proxy**: Marshalling method calls across network/IPC boundaries.

---

## 3. Parsimony Filter & Simpler Alternatives

> **Do not write full proxy classes when language-level wrappers, closures, or built-in interceptors solve the problem.**

| If you have... | Prefer this simpler alternative |
| :--- | :--- |
| JavaScript / TypeScript | The built-in `Proxy` object: `new Proxy(target, { get(...) { ... } })`. |
| Caching a single function | A memoization wrapper function: `memoize(expensiveFn)`. |
| Lazy loading a module or value | Lazy getter functions or dynamic `import()`. |
| Authentication / Authorization | Standard route middleware or guard functions. |

**The Trap**: Writing manual proxy classes that duplicate every single method signature of an interface just to add a 1-line log statement to one method.

---

## 4. Structure & Contracts

```text
┌─────────────────────────────────┐
│       ServiceInterface          │
├─────────────────────────────────┤
│ + operation(): void             │
└────────────────▲────────────────┘
                 │
       ┌─────────┴─────────┐
       │                   │
┌──────┴──────────┐ ┌──────┴──────────┐
│   RealService   │ │      Proxy      │
├─────────────────┤ ├─────────────────┤
│ + operation()   │ │ - real: Service │
└─────────────────┘ ├─────────────────┤
                    │ + operation()   │──┐ checks/caches,
                    └─────────────────┘  │ then forwards
                             │           │
                             └───────────┘
```

- **ServiceInterface**: Declares common operations for both RealService and Proxy.
- **RealService**: Class that provides the actual business logic.
- **Proxy**: Maintains a reference to RealService and controls access to it.

---

## 5. Downsides & Accidental Complexity

- **Response latency**: Every proxied call introduces additional indirection and checks.
- **Hidden behavior**: Callers assume they are calling the real service; hidden proxy behaviors (like transparent retries or stale cache returns) can lead to subtle bugs.

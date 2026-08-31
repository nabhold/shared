# Contract versioning and compatibility policy

## Versioning

Published contract packages use Semantic Versioning. Contract identifiers also
include a major version, such as `nabhold.control-plane.tenant.v1`.

- **Patch:** clarification or fixture correction that changes no valid payload.
- **Minor:** backward-compatible optional fields, event types, or enum values
  whose consumers are required to handle an unknown value safely.
- **Major:** removal, rename, changed meaning, newly required field, or narrowed
  validation.

Schemas under an existing `v1` directory are never changed incompatibly. A
breaking revision is introduced under `v2` and supported in parallel during a
documented migration window.

## Consumer rules

- Pin released package versions; never consume another repository's default
  branch as a production dependency.
- Validate at trust boundaries, not between every internal function.
- Preserve correlation, causation, subject, tenant, and idempotency metadata.
- Do not branch business logic on fields a consumer does not own.
- Treat unknown event types as non-processable and route them to quarantine,
  not an infinite retry loop.

## Change workflow

1. Change schemas, examples, and compatibility fixtures in one pull request.
2. Run schema linting and backward-compatibility checks in `shared`.
3. Dispatch read-only compatibility tests in registered consumers.
4. Review and publish a versioned package.
5. Let automation open explicit dependency-update pull requests downstream.

A `shared` pull request must not deploy an environment or push directly to a
consumer branch.

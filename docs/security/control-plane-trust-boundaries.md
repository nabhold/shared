# Control-plane security and trust boundaries

## Identities

Human administrators authenticate through an external OIDC provider. Services
use workload identities. JWTs use asymmetric signatures, short lifetimes,
explicit issuer and audience validation, and key rotation through JWKS.

The shared contract defines claims and validation requirements; cryptographic
implementation remains in the consuming runtime.

## Permission boundaries

| Principal | Minimum authority |
| --- | --- |
| Management API | Control-plane metadata and outbox writes |
| Database provisioner | Approved tenant-schema operations only |
| Broker provisioner | Approved vhost/exchange/queue operations only |
| Gateway reconciler | APISIX route and upstream resources only |
| Infrastructure pipeline | Reviewed environment provisioning only |
| Digital estate | Its own product APIs and tenant-scoped resources only |

Provisioner credentials are independent, rotatable, and unavailable to digital
estates. The control plane stores secret references, not secret values.

## Audit requirements

Every privileged command records actor, tenant, action, target, timestamp,
correlation identifier, idempotency key, result, and policy decision. Logs must
redact tokens, credentials, personal data, and connection strings.

## Failure posture

- Gateway discovery fails closed for unknown or suspended tenants.
- A Redis outage degrades reconciliation; it does not authorize new traffic.
- Events that exhaust bounded retries enter a dead-letter queue with an audit
  record and require an explicit replay decision.
- No component falls back to broader credentials when a scoped identity fails.

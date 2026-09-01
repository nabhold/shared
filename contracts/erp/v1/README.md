# Baobab ERP boundary contracts v1

This package defines the vendor-neutral interface between Baobab engines and
the Baobab ERP Engine. It does not expose iDempiere, ERPNext, database, Client,
Organisation or table identifiers.

## Contract surfaces

- `openapi.yaml` provides idempotent provisioning and immediate operational
  queries.
- `asyncapi.yaml` carries Trade-owned order/customer inputs and ERP-owned
  status, inventory, warehouse, invoice, payment-accounting and provisioning
  outcomes.
- JSON Schemas define the payloads and canonical public mapping metadata.
- `system-of-record.yaml` declares ownership, direction, consistency and
  conflict policy for every shared ERP concept.

All asynchronous messages use `contracts/events/v1/envelope.schema.json`. All
HTTP errors use `contracts/errors/v1/problem-details.schema.json`. Consumers
must apply `contracts/idempotency/v1/policy.yaml`.

The tenant context is a Control Plane identity. Legal-entity identity comes
from the Shared registry. ERP public IDs are minted by the Baobab ERP boundary.
The adapter may retain vendor bindings privately, but must never substitute a
vendor identifier for any of those identities.

The contract deliberately does not mint a canonical `organisation_id`: that
owner remains unassigned. Nor does it choose an iDempiere release, deployment
topology, database layout, broker implementation or country localisation.


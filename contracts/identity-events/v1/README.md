# Baobab identity-events contracts v1

This package defines the canonical identity-lifecycle events referenced by
`baobab-iam` ADR-0016 ("Identity Lifecycle, Revocation and Deprovisioning")
and consumed by any engine that needs to react to a principal's or
membership's state changing.

## Contract surfaces

- `asyncapi.yaml` carries the events this domain currently defines:
  identity created, identity disabled, identity suspended, identity
  reactivated, and membership revoked.
- JSON Schemas (`identity-created.schema.json`, `identity-disabled.schema.json`,
  `identity-suspended.schema.json`, `identity-reactivated.schema.json`,
  `membership-revoked.schema.json`) define each event's `data` payload.
  Shared identity types (`ActorType`, etc.) live in `contracts/identity/v1`
  and are referenced, not duplicated.

`identity-disabled.schema.json`'s `new_status` was originally `["SUSPENDED",
"DISABLED"]`, letting an ACTIVE-to-SUSPENDED transition be reported under
either `identity.disabled` or the newly-added `identity.suspended`. Narrowed
to `["DISABLED"]` only now that `identity.suspended` exists to own that
transition — one transition, one event type, not two ways to say the same
thing.

All events use `contracts/events/v1/envelope.schema.json` — composed in
`asyncapi.yaml`, not embedded inside the payload schemas themselves (that
was this package's original defect: each payload schema tried to `allOf`
in the envelope directly, via a path — `../../common/event-envelope.schema.json`
— that has never existed in this repository; nothing validated it, so the
break went unnoticed). No message broker exists yet anywhere in this
ecosystem to actually carry these — same position `contracts/erp/v1` and
`contracts/supplier-onboarding/v1` are already in — so this contract exists
for producers and future consumers to build against ahead of one existing,
not because one does.

## What this contract deliberately does not do yet

ADR-0016 §90 ("Event Examples") suggests `nabhold/shared` SHOULD define
versioned events including `identity.suspended`, `identity.reactivated`,
`entitlement.revoked`, `credential.compromised`, `session.revoked`, and
`workload.revoked`, in addition to the `identity.disabled` and
`membership.revoked` this package already had. `identity.suspended` and
`identity.reactivated` are now defined (this pass); `entitlement.revoked`,
`credential.compromised`, `session.revoked`, and `workload.revoked` remain
outstanding. Each needs its own payload design against ADR-0016's
revocation-propagation, staleness (§93–95), and audit (§139) requirements.
The reason-code registry and `AuthenticationAssurance`/`Delegation`
contracts ADR-0016/ADR-0017 also call for now exist
(`contracts/authorization/v1/reason-code-registry.yaml`,
`contracts/identity/v1/authentication-assurance.schema.json`,
`contracts/authorization/v1/delegation.schema.json`) — `session.revoked`
in particular should build on `AuthenticationAssurance` rather than
inventing its own assurance vocabulary, the same reconciliation `Session`
itself just went through. Fabricating shapes without per-event design work
would just create a second, differently-wrong version of this same defect.
Tracked as follow-up work, not represented as done here.

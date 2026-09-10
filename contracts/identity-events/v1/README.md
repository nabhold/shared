# Baobab identity-events contracts v1

This package defines the canonical identity-lifecycle events referenced by
`baobab-iam` ADR-0016 ("Identity Lifecycle, Revocation and Deprovisioning")
and consumed by any engine that needs to react to a principal's or
membership's state changing.

## Contract surfaces

- `asyncapi.yaml` carries the events this domain currently defines:
  identity created, identity disabled, identity suspended, identity
  reactivated, membership revoked, entitlement revoked, credential
  compromised, and session revoked.
- JSON Schemas (`identity-created.schema.json`, `identity-disabled.schema.json`,
  `identity-suspended.schema.json`, `identity-reactivated.schema.json`,
  `membership-revoked.schema.json`, `entitlement-revoked.schema.json`,
  `credential-compromised.schema.json`, `session-revoked.schema.json`)
  define each event's `data` payload. Shared identity types (`ActorType`,
  etc.) live in `contracts/identity/v1` and are referenced, not duplicated.

`session-revoked.schema.json` deliberately does not embed
`AuthenticationAssurance`: a revocation event records that a session ended
and why, not how it was originally authenticated, and that assurance detail
already lives on the `Session` resource itself
(`contracts/identity/v1/session.schema.json`'s required
`authentication_assurance`) rather than needing to be re-asserted here.

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
`membership.revoked` this package already had. All but `workload.revoked`
are now defined. `workload.revoked` remains outstanding: it needs its own
payload design against ADR-0016 §79-84's workload lifecycle (a workload
identity is not a human principal, so its subject shape differs from every
event above), not a placeholder. Fabricating a shape without that design
work would just create a second, differently-wrong version of the defect
this package originally shipped with. Tracked as follow-up work, not
represented as done here.

`credential-compromised.schema.json`'s `credential_type` enumerates
ADR-0015 §5's supported human authenticator categories (password, passkey,
security-key WebAuthn, platform WebAuthn, TOTP, recovery code, federated
enterprise IdP, social IdP) — grounded in that table, not invented.

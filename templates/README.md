# Caller Templates

Most files here are thin wrappers for a consuming repository's own
`.github/workflows/`. Reusable workflows can only carry a `workflow_call`
trigger — the real trigger (`push`, `pull_request`, `issues`, ...) and any
job-level `permissions:` elevation always live in the caller repo, not in
`nabhold/shared`. The one exception is `dependabot.yml`, which isn't a
workflow at all — see its own entry below for why it's copied differently.

- `caller-greetings.yml` — org-standard first-interaction bot. Toolchain-
  agnostic, works for any repo.
- `caller-pages-zensical.yml` — docs build/deploy. Assumes uv + Zensical
  (the NABHOLD default). A repo on a different documentation toolchain
  needs a different reusable workflow, not a modified copy of this one —
  raise that as a new shared/ addition rather than forking this template.
- `caller-enforce-action-pinning.yml` — CI check that fails if any
  `uses:` reference in the consuming repo isn't pinned to a full-length
  commit SHA. Recommended for every repo, not just this one — see
  README.md's "Immutable Dependencies" policy.
- `dependabot.yml` — org-standard Dependabot config for tracking GitHub
  Actions dependencies. Unlike the other files here, this isn't a
  reusable-workflow caller — Dependabot config can't be centralized that
  way (see README.md's "Dependency Updates" section) — so it's copied
  verbatim rather than delegated via `uses:`.
- `caller-enforce-dependabot-config.yml` — CI check that fails if the
  consuming repo's `.github/dependabot.yml` has drifted from the org's
  structural requirements (missing ecosystem entry, missing schedule,
  etc.). Pairs with `dependabot.yml` above the way
  `caller-enforce-action-pinning.yml` pairs with the pinning policy —
  copy once, then let this catch drift afterwards.

Steps:

1. Copy the relevant `caller-*.yml` into `<repo>/.github/workflows/<name>.yml`.
2. Resolve every `TODO`.
3. Pin the `nabhold/shared/...@<sha>` reference to a full-length commit
   SHA — this is required by org policy, not optional, and applies to
   `nabhold/shared` references exactly as it does to third-party actions
   (see README.md's "Immutable Dependencies" section). Verify the SHA
   live against the upstream tag/branch rather than trusting what's
   already in the template, since it may be stale by the time you copy
   it. **As of this writing `nabhold/shared` has no tags at all** — until
   a `v1.0.0` release is cut, the only thing to pin to is `main` HEAD;
   re-pin once a tag exists.
4. Confirm the consuming repo's Settings → Actions → General → Actions
   permissions allows `nabhold/shared` (only relevant if that repo has an
   explicit allow-list rather than "Allow all actions").

`dependabot.yml` follows a different, simpler process: copy it into
`<repo>/.github/dependabot.yml`, resolve its TODOs, and that's it — there's
no `uses:` reference to pin, since (as above) Dependabot config isn't
delegated the way workflows are. Its drift-check counterpart,
`caller-enforce-dependabot-config.yml`, does still get steps 1–4 above,
since it *is* a normal reusable-workflow caller.
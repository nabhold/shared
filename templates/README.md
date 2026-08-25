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
- `caller-release.yml` — creates a GitHub Release from a pushed version
  tag, with release notes drawn from the caller's own CHANGELOG.md. Not
  a fit for a repository whose release is inseparable from a bespoke
  artifact pipeline (container build/sign/attest, package publish) — see
  release.yml's own header.
- `caller-security-secrets-scan.yml` — fails CI if gitleaks finds a
  secret anywhere in the calling repository's git history. Toolchain-
  agnostic, works for any repo — recommended for every repo, same as
  action-pinning.
- `caller-security-codeql.yml` — runs GitHub CodeQL SAST for whichever
  languages the caller declares. Only adopt this in a repo that has at
  least one CodeQL-supported language — see the template's own header.
- `caller-security-python.yml` — runs Bandit (SAST) and pip-audit
  (dependency vulnerability audit) for a uv-managed Python repo. Assumes
  the "security" dependency-group convention documented in
  nabhold/baobab's pyproject.toml.

Steps:

1. Copy the relevant `caller-*.yml` into `<repo>/.github/workflows/<name>.yml`.
2. Resolve every `TODO`.
3. Pin the `nabhold/shared/...@<sha>` reference to a full-length commit
   SHA — this is required by org policy, not optional, and applies to
   `nabhold/shared` references exactly as it does to third-party actions
   (see README.md's "Immutable Dependencies" section). Verify the SHA
   live against the upstream tag/branch rather than trusting what's
   already in the template, since it may be stale by the time you copy
   it. **As of this writing `nabhold/shared` has one tagged release,
   `v1.0.0`** — pin to that tag's SHA for any file it already contains
   (`greetings.yml`, `pages-zensical.yml`, `enforce-action-pinning.yml`,
   `enforce-dependabot-config.yml`). A file added after `v1.0.0` (for
   example `release.yml`, or the `security-*.yml` workflows) has no
   covering tag yet — pin to `main` HEAD instead
   (`git ls-remote https://github.com/nabhold/shared.git main`) and
   re-pin once a new tag is cut that includes it.
4. Confirm the consuming repo's Settings → Actions → General → Actions
   permissions allows `nabhold/shared` (only relevant if that repo has an
   explicit allow-list rather than "Allow all actions").

`dependabot.yml` follows a different, simpler process: copy it into
`<repo>/.github/dependabot.yml`, resolve its TODOs, and that's it — there's
no `uses:` reference to pin, since (as above) Dependabot config isn't
delegated the way workflows are. Its drift-check counterpart,
`caller-enforce-dependabot-config.yml`, does still get steps 1–4 above,
since it *is* a normal reusable-workflow caller.

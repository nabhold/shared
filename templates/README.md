# Caller Templates

Each file here is a thin wrapper for a consuming repository's own
`.github/workflows/`. Reusable workflows can only carry a `workflow_call`
trigger — the real trigger (`push`, `pull_request`, `issues`, ...) and any
job-level `permissions:` elevation always live in the caller repo, not in
`nabhold/shared`.

- `caller-greetings.yml` — org-standard first-interaction bot. Toolchain-
  agnostic, works for any repo.
- `caller-pages-zensical.yml` — docs build/deploy. Assumes uv + Zensical
  (the NABHOLD default). A repo on a different documentation toolchain
  needs a different reusable workflow, not a modified copy of this one —
  raise that as a new shared/ addition rather than forking this template.

Steps:

1. Copy the relevant `caller-*.yml` into `<repo>/.github/workflows/<name>.yml`.
2. Resolve every `TODO`.
3. Pin the `nabhold/shared/...@v1` reference to the version you intend to
   track (moving major tag `@v1`, or a specific `@vX.Y.Z` / commit SHA for
   extra rigor).
4. Confirm the consuming repo's Settings → Actions → General → Actions
   permissions allows `nabhold/shared` (only relevant if that repo has an
   explicit allow-list rather than "Allow all actions").
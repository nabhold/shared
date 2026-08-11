# NABHOLD Shared

> **Organisation-wide shared workflows, pipelines, automation, configuration, and engineering standards for the NABHOLD GitHub ecosystem.**

**Repository:** `nabhold/shared`
**Visibility:** Private
**Scope:** NABHOLD Organisation
**Status:** Foundational / Internal Infrastructure

---

## Overview

`nabhold/shared` is the central repository for **reusable engineering infrastructure across the NABHOLD organisation**.

It exists to prevent individual repositories from independently reinventing the same CI/CD pipelines, GitHub Actions workflows, automation scripts, security controls, configuration patterns, and operational conventions.

The repository provides a controlled foundation that can be consumed by NABHOLD projects, products, platforms, and subsidiaries.

The principle is simple:

> **Build common engineering capabilities once, govern them centrally, and reuse them consistently.**

This repository should therefore be treated as **organisation infrastructure**, rather than as an ordinary application repository.

---

## Why This Repository Exists

As the NABHOLD technology estate grows, individual repositories will inevitably need many of the same capabilities:

* Continuous Integration
* Continuous Deployment
* Documentation deployment
* GitHub Pages deployment
* Python dependency management
* JavaScript/TypeScript builds
* Docker image builds
* Security scanning
* Dependency auditing
* Code quality checks
* Release automation
* Version management
* Artifact handling
* Infrastructure validation
* Pull-request validation
* Repository hygiene
* Dependency updates
* Supply-chain security
* Environment validation
* Scheduled maintenance
* Notifications and operational automation

Copying these workflows from repository to repository creates a predictable problem:

```text
Repository A ──┐
Repository B ──┤
Repository C ──┼──> Duplicated CI/CD logic
Repository D ──┤
Repository E ──┘
```

Over time, the implementations diverge.

One repository gets a security improvement. Another remains on an older action. A third uses a different Python version. A fourth has subtly different permissions.

That is technical debt disguised as configuration.

The `shared` repository exists to establish a common foundation:

```text
                    ┌──────────────────────┐
                    │    NABHOLD Shared    │
                    │                      │
                    │ Workflows             │
                    │ Pipelines             │
                    │ Actions               │
                    │ Scripts               │
                    │ Standards             │
                    │ Security Controls     │
                    │ Templates             │
                    └──────────┬───────────┘
                               │
             ┌─────────────────┼─────────────────┐
             │                 │                 │
             ▼                 ▼                 ▼
       ┌──────────┐      ┌──────────┐      ┌──────────┐
       │ Baobab   │      │ ZuriBeans│      │ Other    │
       │ Platform │      │          │      │ Projects │
       └──────────┘      └──────────┘      └──────────┘
```

---

# Objectives

The repository has six primary objectives.

## 1. Standardisation

Provide common implementation patterns for recurring engineering tasks.

Repositories should not need to invent their own CI/CD architecture unless there is a legitimate project-specific requirement.

---

## 2. Reuse

Enable repositories throughout NABHOLD to consume common workflows and automation without copying implementation code.

Where GitHub supports reusable workflows, those should generally be preferred over duplication.

---

## 3. Security

Centralise security-conscious implementation patterns, particularly around:

* GitHub Actions permissions
* Immutable action pinning
* Dependency management
* Secret handling
* OIDC authentication
* Artifact management
* Supply-chain security
* Container security
* Dependency vulnerability scanning

Security improvements made here should be capable of benefiting multiple repositories.

---

## 4. Maintainability

Reduce the number of independently maintained workflow implementations.

A change to a common process should ideally require changing one centrally maintained implementation rather than dozens of repositories.

---

## 5. Governance

Establish organisation-wide conventions for how NABHOLD repositories:

* build;
* test;
* package;
* release;
* deploy;
* document;
* scan;
* version; and
* maintain software.

---

## 6. Engineering Enablement

Make the correct engineering approach the easiest approach.

The repository should provide **paved roads**, not bureaucratic obstacles.

Project teams should be able to adopt established engineering practices with minimal configuration.

---

# Scope

The repository may contain organisation-wide resources in the following categories.

## Shared GitHub Actions Workflows

Reusable workflows for common repository operations, such as:

* Python CI
* Node.js / TypeScript CI
* Flutter CI
* Django CI
* FastAPI CI
* Docker builds
* Container publishing
* Documentation builds
* GitHub Pages deployment
* Release workflows
* Pull-request validation
* Scheduled maintenance
* Security scanning
* Dependency auditing

Example:

```yaml
jobs:
  ci:
    uses: nabhold/shared/.github/workflows/python-ci.yml@v1
```

---

## Shared Composite Actions

Where a reusable workflow is not appropriate, common task-level operations may be implemented as composite actions.

Examples include:

* installing `uv`;
* configuring Python;
* configuring Node;
* authenticating to registries;
* validating repository structure;
* generating release metadata;
* running security checks.

---

## Shared Scripts

Organisation-wide shell, Python, or other automation scripts may be maintained here where they have legitimate reuse across multiple repositories.

Scripts should remain:

* deterministic;
* documented;
* testable;
* portable where practical;
* dependency-conscious; and
* safe to execute in CI.

---

## Configuration

Common configuration may include:

* Dependabot configuration patterns;
* CodeQL configuration;
* security scanning configuration;
* linting configuration;
* repository metadata;
* release configuration;
* workflow configuration;
* automation configuration.

Project-specific configuration should remain in the consuming repository.

---

## Templates

The repository may provide templates for:

* workflows;
* issue forms;
* pull requests;
* release processes;
* security reporting;
* repository bootstrapping;
* documentation;
* development environments.

Templates should be used where central reuse is not technically appropriate.

---

# What Does *Not* Belong Here

Centralisation is useful, but not everything belongs in `shared`.

The repository should **not become a dumping ground**.

The following generally belong in their respective project repositories:

### Application code

Business logic and application-specific implementation belong in the consuming project.

### Product documentation

Product-specific documentation belongs in the product repository.

### Project-specific workflows

A workflow that genuinely depends on unique project architecture should remain with that project.

### Secrets

Secrets must **never** be committed to this repository.

### Credentials

API keys, passwords, private certificates, tokens, and other credentials must never be stored here.

### Environment-specific configuration

Configuration containing environment-specific operational values should normally remain outside this repository and be supplied through appropriate GitHub, cloud, or infrastructure mechanisms.

---

# Design Principles

## DRY — Don't Repeat Yourself

Common behaviour should have one authoritative implementation wherever practical.

---

## Secure by Default

Reusable workflows must assume that repositories should operate under the principle of least privilege.

For example:

```yaml
permissions:
  contents: read
```

should be preferred over broad permissions unless additional access is demonstrably required.

---

## Immutable Dependencies

GitHub Actions should be pinned to full-length commit SHAs wherever organisation policy requires immutable action references.

Avoid:

```yaml
uses: actions/checkout@v4
```

Prefer:

```yaml
uses: actions/checkout@<40-character-commit-sha>
```

with the release version documented in a comment.

This provides both:

1. immutable execution; and
2. human-readable release traceability.

---

## Explicit Over Clever

Shared infrastructure is consumed by people who did not necessarily write it.

Prefer straightforward workflows over clever abstractions.

A few extra lines of YAML are cheaper than several hours of debugging an opaque abstraction.

---

## Backwards Compatibility

Reusable workflows are APIs.

Changing their inputs, outputs, behaviour, permissions, or assumptions can break downstream repositories.

Changes must therefore be treated with the same care as changes to a public software interface.

---

## Version Everything

Reusable workflows and actions should be versioned.

Consumers should preferably reference a stable major version:

```yaml
uses: nabhold/shared/.github/workflows/python-ci.yml@v1
```

while major-version branches/tags are maintained deliberately.

Breaking changes should result in a new major version.

---

# Versioning Strategy

Shared workflows should follow semantic-versioning principles where practical.

```text
MAJOR.MINOR.PATCH
```

### MAJOR

Breaking interface or behavioural changes.

Examples:

* removed input;
* renamed input;
* changed required secret;
* changed expected artifact;
* incompatible runner;
* changed output contract.

### MINOR

Backward-compatible functionality.

Examples:

* new optional input;
* additional validation;
* additional supported runtime.

### PATCH

Backward-compatible fixes.

Examples:

* corrected shell logic;
* dependency update;
* documentation correction;
* security fix that does not change the interface.

For reusable workflows, consumers may generally pin to a major release:

```text
@v1
```

while the organisation maintains the corresponding release line.

Repositories requiring maximum reproducibility may pin to a specific immutable commit.

---

# Security Model

Because this repository contains infrastructure capable of affecting multiple repositories, it should be considered **high-value internal infrastructure**.

Changes must therefore receive appropriate review.

## Minimum Security Expectations

Shared workflows should:

* use least-privilege permissions;
* avoid unnecessary secrets;
* prefer OIDC over long-lived cloud credentials where supported;
* pin third-party actions;
* validate external inputs;
* avoid executing untrusted pull-request content with privileged credentials;
* avoid exposing secrets to forked pull requests;
* minimise write permissions;
* avoid unnecessary network access;
* document security-sensitive behaviour.

---

# Secrets

Secrets must never be committed to the repository.

Use the appropriate GitHub mechanism:

* organisation secrets;
* repository secrets;
* environment secrets;
* GitHub OIDC;
* external secret managers.

Reusable workflows must explicitly document any secrets they expect.

Example:

```yaml
on:
  workflow_call:
    secrets:
      DEPLOY_TOKEN:
        required: true
```

A workflow should request only the secrets it actually needs.

---

# Permissions

Permissions should be explicitly declared.

For example:

```yaml
permissions:
  contents: read
```

If a workflow needs additional privileges, they should be declared deliberately and documented.

Avoid relying on implicit repository-level defaults.

---

# Repository Structure

The exact structure may evolve, but the repository should generally follow a predictable layout:

```text
shared/
├── .github/
│   ├── workflows/
│   │   ├── ci/
│   │   ├── cd/
│   │   ├── security/
│   │   ├── documentation/
│   │   └── maintenance/
│   │
│   ├── actions/
│   │   └── <composite-actions>/
│   │
│   ├── ISSUE_TEMPLATE/
│   └── dependabot.yml
│
├── actions/
│   └── <organisation-actions>/
│
├── scripts/
│   ├── ci/
│   ├── release/
│   ├── security/
│   └── maintenance/
│
├── templates/
│   ├── workflows/
│   ├── repositories/
│   └── documentation/
│
├── docs/
│   ├── architecture/
│   ├── workflows/
│   ├── security/
│   └── operations/
│
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
├── CHANGELOG.md
└── CODEOWNERS
```

The structure should remain **purpose-driven**. Directories should not be created merely because the structure looks impressive.

---

# Consuming Shared Workflows

A consuming repository should use a reusable workflow rather than copying it whenever the workflow is sufficiently generic.

Example:

```yaml
name: CI

on:
  pull_request:
  push:
    branches:
      - main

jobs:
  ci:
    uses: nabhold/shared/.github/workflows/python-ci.yml@v1
```

If inputs are required:

```yaml
jobs:
  ci:
    uses: nabhold/shared/.github/workflows/python-ci.yml@v1
    with:
      python-version: "3.13"
      test-command: "pytest"
```

Project-specific behaviour should be supplied through documented inputs rather than hard-coded into the shared workflow.

---

# Workflow Contract

Every reusable workflow should document its contract.

At minimum:

| Property           | Description                   |
| ------------------ | ----------------------------- |
| Purpose            | What the workflow does        |
| Trigger            | How the workflow is invoked   |
| Inputs             | Accepted configuration        |
| Secrets            | Required secrets              |
| Permissions        | Required GitHub permissions   |
| Outputs            | Values exposed to callers     |
| Artifacts          | Artifacts produced            |
| Runners            | Required runner environment   |
| Dependencies       | External dependencies         |
| Failure conditions | Conditions that cause failure |
| Version            | Current workflow version      |
| Breaking changes   | Compatibility considerations  |

This documentation is particularly important because reusable workflows behave like internal APIs.

---

# Testing Shared Workflows

Changes to shared workflows must be tested before they are promoted to a stable release.

Testing should include, where applicable:

1. YAML syntax validation.
2. Action reference validation.
3. Permission validation.
4. Reusable workflow invocation.
5. Representative consumer repositories.
6. Security checks.
7. Artifact creation.
8. Failure-path behaviour.

A workflow that is syntactically valid but unusable by consumers is not considered successfully tested.

---

# Release Process

Changes should normally follow:

```text
Change
  │
  ▼
Pull Request
  │
  ▼
Review
  │
  ▼
Validation
  │
  ▼
Merge
  │
  ▼
Release
  │
  ▼
Version
  │
  ▼
Consumer Adoption
```

Breaking changes should receive particular attention and must not be silently introduced into an existing major release.

---

# Deprecation

Shared workflows should not be removed abruptly when downstream repositories depend on them.

A normal deprecation process should be:

```text
Introduce replacement
        │
        ▼
Mark old workflow deprecated
        │
        ▼
Notify consumers
        │
        ▼
Provide migration guidance
        │
        ▼
Monitor adoption
        │
        ▼
Remove after agreed sunset period
```

Deprecation notices should identify:

* affected workflow;
* replacement;
* migration instructions;
* deadline;
* breaking changes;
* responsible maintainers.

---

# Ownership

The `shared` repository should have explicit ownership.

Critical files and directories should be covered by `CODEOWNERS`.

Example:

```text
/.github/              @nabhold/platform-engineering
/actions/              @nabhold/platform-engineering
/scripts/              @nabhold/platform-engineering
/security/             @nabhold/security
```

The actual teams should be substituted for the organisation's real GitHub teams.

---

# Contribution Guidelines

Contributors should ask one question before adding anything:

> **Is this genuinely reusable across multiple NABHOLD repositories?**

If the answer is no, the code probably belongs in the consuming project.

Before contributing a shared workflow:

* identify its intended consumers;
* define its interface;
* minimise required inputs;
* minimise required permissions;
* document secrets;
* pin external actions;
* test the workflow;
* document compatibility;
* consider versioning;
* consider failure behaviour.

---

# Change Management

Shared infrastructure changes require greater discipline than ordinary application changes because a single defect can affect multiple repositories.

Changes should be categorised as:

* **Breaking**
* **Feature**
* **Fix**
* **Security**
* **Maintenance**
* **Documentation**

Security fixes should be prioritised appropriately and may require expedited release procedures.

---

# Recommended Repository Labels

The following labels are recommended for issues and pull requests in `nabhold/shared`.

## Type

| Label                | Purpose                                                  |
| -------------------- | -------------------------------------------------------- |
| `type:feature`       | New capability                                           |
| `type:fix`           | Bug or defect correction                                 |
| `type:security`      | Security-related change                                  |
| `type:maintenance`   | Routine maintenance                                      |
| `type:refactor`      | Internal restructuring without intended behaviour change |
| `type:documentation` | Documentation-only change                                |
| `type:breaking`      | Breaking change                                          |
| `type:deprecation`   | Deprecation or removal                                   |
| `type:automation`    | Automation-related change                                |

## Area

| Label                 | Purpose                       |
| --------------------- | ----------------------------- |
| `area:actions`        | GitHub Actions                |
| `area:workflows`      | Reusable workflows            |
| `area:ci`             | Continuous Integration        |
| `area:cd`             | Continuous Deployment         |
| `area:security`       | Security infrastructure       |
| `area:dependencies`   | Dependency management         |
| `area:release`        | Release automation            |
| `area:documentation`  | Documentation infrastructure  |
| `area:containers`     | Docker/container workflows    |
| `area:python`         | Python tooling                |
| `area:node`           | Node.js/TypeScript tooling    |
| `area:flutter`        | Flutter tooling               |
| `area:infrastructure` | Infrastructure automation     |
| `area:scripts`        | Shared scripts                |
| `area:templates`      | Repository/workflow templates |
| `area:github`         | GitHub platform configuration |

## Priority

| Label               | Purpose                                    |
| ------------------- | ------------------------------------------ |
| `priority:critical` | Immediate attention required               |
| `priority:high`     | Significant operational or security impact |
| `priority:medium`   | Normal priority                            |
| `priority:low`      | Can be scheduled later                     |

## Status

| Label                  | Purpose                                      |
| ---------------------- | -------------------------------------------- |
| `status:blocked`       | Cannot proceed due to an external dependency |
| `status:in-progress`   | Currently being implemented                  |
| `status:needs-review`  | Awaiting review                              |
| `status:needs-testing` | Implementation requires validation           |
| `status:ready`         | Ready for implementation                     |
| `status:stale`         | No recent activity                           |

## Security

| Label                    | Purpose                                 |
| ------------------------ | --------------------------------------- |
| `security:vulnerability` | Confirmed vulnerability                 |
| `security:hardening`     | Security improvement                    |
| `security:supply-chain`  | Dependency/action supply-chain security |
| `security:permissions`   | GitHub permissions/security boundary    |
| `security:secrets`       | Secret-handling concern                 |
| `security:oidc`          | OIDC/authentication security            |

## Dependencies

| Label                        | Purpose                         |
| ---------------------------- | ------------------------------- |
| `dependencies:github-action` | GitHub Action dependency        |
| `dependencies:python`        | Python dependency               |
| `dependencies:node`          | Node/npm dependency             |
| `dependencies:container`     | Container/base-image dependency |
| `dependencies:tooling`       | Development/CI tooling          |

## Compatibility

| Label                               | Purpose                               |
| ----------------------------------- | ------------------------------------- |
| `compatibility:breaking`            | Breaking compatibility change         |
| `compatibility:backward-compatible` | Backward-compatible change            |
| `compatibility:consumer-impact`     | Requires downstream repository action |

---

# Label Naming Convention

Labels use a namespace format:

```text
namespace:value
```

For example:

```text
type:security
area:workflows
priority:high
security:supply-chain
```

This makes labels easier to search, filter, automate, and interpret consistently.

Avoid creating arbitrary labels such as:

```text
urgent
important
workflow issue
security thing
```

Prefer the structured namespace.

---

# Governance

The `shared` repository should be governed as an internal platform.

That means:

* changes should be reviewed;
* security-sensitive changes should receive appropriate scrutiny;
* breaking changes should be explicitly identified;
* reusable workflows should have documented contracts;
* dependencies should be kept current;
* deprecated interfaces should be managed deliberately;
* consumers should not be surprised by changes.

The repository should favour **predictability over novelty**.

---

# Relationship With NABHOLD Projects

`nabhold/shared` is intended to sit beneath the organisation's application and product repositories as a common engineering layer.

Conceptually:

```text
                    NABHOLD ORGANISATION
                           │
                           ▼
                  ┌─────────────────┐
                  │ nabhold/shared  │
                  │                 │
                  │ CI/CD           │
                  │ Security        │
                  │ Automation      │
                  │ Standards       │
                  │ Tooling         │
                  └────────┬────────┘
                           │
             ┌─────────────┼─────────────┐
             │             │             │
             ▼             ▼             ▼
         ┌────────┐    ┌────────┐    ┌────────┐
         │ Baobab │    │ Zuri   │    │ Future │
         │        │    │ Beans  │    │ Repos  │
         └────────┘    └────────┘    └────────┘
```

The shared repository should provide the **common engineering foundation**, while individual repositories retain responsibility for their own business logic and product-specific behaviour.

---

# Repository Classification

`nabhold/shared` should be considered:

**Category:** Internal Platform / Engineering Infrastructure
**Visibility:** Private
**Criticality:** High
**Consumers:** NABHOLD repositories and approved organisation projects
**Primary Function:** Reusable engineering automation and governance

---

# Roadmap

The repository may progressively evolve toward the following capabilities:

### Foundation

* [ ] Reusable CI workflows
* [ ] Reusable CD workflows
* [ ] Security workflows
* [ ] Documentation workflows
* [ ] Release workflows
* [ ] Standard action pinning
* [ ] Standard permissions model
* [ ] Repository templates

### Developer Experience

* [ ] Standard development environment checks
* [ ] Language-specific CI templates
* [ ] Container build templates
* [ ] Release automation
* [ ] Dependency update automation

### Security

* [ ] CodeQL integration
* [ ] Dependency vulnerability scanning
* [ ] Secret scanning guidance
* [ ] Supply-chain controls
* [ ] OIDC patterns
* [ ] SBOM generation
* [ ] Container scanning

### Platform Engineering

* [ ] Standard deployment workflows
* [ ] Cloud authentication patterns
* [ ] Infrastructure validation
* [ ] Environment promotion workflows
* [ ] Organisation-wide operational automation

---

# Guiding Principle

The purpose of `shared` is not to centralise everything.

It is to **centralise what should be common**.

A good shared component should provide:

> **One implementation, many consumers, clear ownership, explicit contracts, secure defaults, and predictable versioning.**

If a component cannot satisfy those characteristics, it should probably remain local to the project that needs it.

---

## Maintainers

**NABHOLD Engineering / Platform Team**

For changes affecting organisation-wide workflows, security controls, deployment infrastructure, or reusable workflow contracts, obtain appropriate maintainer review before merging.

---

## License

This repository is private and proprietary to **NABHOLD**.

No content in this repository should be copied, redistributed, or reused outside authorised NABHOLD projects without explicit permission.

---

## Internal Use

This repository is intended for authorised NABHOLD personnel, systems, and repositories.

Because workflows contained here may execute with elevated privileges across other repositories, treat changes to this repository as changes to **shared organisational infrastructure**.

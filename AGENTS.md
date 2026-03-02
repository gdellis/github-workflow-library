# AGENTS.md - GitHub Workflow Library

This is a repository containing reusable GitHub Actions workflows, composite actions, and templates.

## Purpose

This library provides CI/CD, security, and quality assurance workflows that can be reused across multiple projects via `uses:` directives.

## Directory Structure

```
.github/
├── workflows/           # Reusable workflows (call via workflow_call)
│   ├── ci/             # CI workflows (lint, typecheck, test)
│   ├── cd/             # CD workflows (release, npm, pypi, docker)
│   ├── security/       # Security workflows
│   ├── quality/        # Quality workflows
│   └── pull-request/  # PR workflows
├── actions/            # Composite actions (reusable steps)
├── templates/          # Copy-paste templates for new projects
├── configs/            # Shared configuration files
├── scripts/            # Shared shell scripts
└── libs/               # Reusable workflow fragments
```

## Build/Lint/Test Commands

### Validate All Workflows

```bash
# Lint all GitHub Actions workflows
actionlint .github/workflows/

# Validate shell scripts
shellcheck .github/scripts/*.sh

# Format shell scripts
shfmt -i 2 -d .github/scripts/
```

### Individual Workflow Validation

```bash
# Validate a single workflow
actionlint .github/workflows/ci/ci-basic.yml
```

### Shell Script Commands

```bash
# Run shell script linting
shellcheck .github/scripts/lint.sh
shellcheck .github/scripts/test.sh
shellcheck .github/scripts/audit.sh

# Format shell scripts
shfmt -i 2 -w .github/scripts/lint.sh
shfmt -i 2 -w .github/scripts/test.sh
shfmt -i 2 -w .github/scripts/audit.sh
```

### Testing Workflows

Workflows can be tested locally using:
- [act](https://github.com/nektos/act) - Run GitHub Actions locally

```bash
# Run a specific workflow locally
act -W .github/workflows/ci/ci-basic.yml
```

## Code Style Guidelines

### YAML Workflow Files

#### Naming Conventions

- Workflow files: `kebab-case.yml`
- Job names: `kebab-case`
- Step names: Descriptive, Title Case for display
- Action names: `kebab-case`

#### Formatting

- Indent: 2 spaces
- Use anchors (`&anchor`) and aliases (`*alias`) for repeated configurations
- Keep workflows under 300 lines; extract reusable jobs to separate files
- Use `on: workflow_call` for reusable workflows (not directly triggered)

#### Job Organization

```yaml
# Run independent jobs in parallel (default)
# Dependencies use 'needs:'
jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
  
  test:
    name: Test
    runs-on: ubuntu-latest
    needs: []  # Explicitly parallel

  build:
    name: Build
    needs: [lint, test]  # Sequential after checks
```

#### Permissions

Always specify minimal permissions:

```yaml
permissions:
  contents: read      # Minimal required
  id-token: write     # For OIDC publishing
```

#### Action Versions

- Pin to major version tags (`@v4`) for stability
- Avoid `@main` or `@master` in production workflows
- Use specific SHAs for security-critical actions in high-security environments

#### Secrets Handling

- Use `secrets:` input for sensitive values
- Never hardcode secrets in workflows
- Use OIDC (`id-token: write`) for cloud publishing when possible

### Composite Actions

#### Structure

```yaml
name: Action Name
description: What it does

inputs:
  input-name:
    type: string
    required: false
    default: 'default-value'

outputs:
  output-name:
    description: What it outputs
    value: ${{ steps.step-id.outputs.output }}

runs:
  using: composite
  steps:
    - uses: actions/checkout@v4
    
    - name: Step Name
      id: step-id
      run: |
        echo "output=value" >> $GITHUB_OUTPUT
```

#### Best Practices

- Always define `name` and `description`
- Use `id:` on steps for output access
- Use `${{ env.VAR }}` for environment variables
- Clean up temporary files in `finally:` blocks if needed

### Shell Scripts

#### Header

Always include:
```bash
#!/bin/bash
set -euo pipefail
```

#### Error Handling

- Use `set -euo pipefail` for strict error handling
- Check exit codes explicitly for risky commands
- Use `|| true` only when failure is acceptable

#### Formatting

- Use `shellcheck` for validation
- Use `shfmt` for formatting (2-space indent)
- Quote all variables: `"$VAR"` not `$VAR`

### Reusable Workflows

#### Input Definitions

```yaml
on:
  workflow_call:
    inputs:
      python-version:
        type: string
        default: '3.13'
    secrets:
      NPM_TOKEN:
        required: true
```

#### Documentation

Add description to all inputs:
```yaml
inputs:
  python-version:
    type: string
    default: '3.13'
    description: Python version to use
```

## Common Patterns

### Caching

Use built-in caching where available:
- `actions/setup-node` with `cache: 'pnpm'`
- `actions/cache` for custom caches

### Concurrency Control

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### Matrix Builds

```yaml
strategy:
  fail-fast: false
  matrix:
    python-version: ['3.11', '3.12', '3.13']
```

## Adding New Workflows

1. Determine category: `ci/`, `cd/`, `security/`, `quality/`, or `pull-request/`
2. Use `on: workflow_call` for reusable workflows
3. Add input definitions with descriptions
4. Validate with `actionlint`
5. Update `.github/README.md` with new workflow documentation

## Security Considerations

- Never log secrets or tokens
- Use OIDC for cloud provider authentication
- Pin action versions to prevent supply chain attacks
- Run security scans regularly with `dependency-review-action`
- Enable secret scanning on all repositories using these workflows

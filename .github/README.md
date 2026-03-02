# GitHub Workflow Library

A collection of reusable GitHub Actions workflows, composite actions, and templates for CI/CD, security, and quality assurance.

## Directory Structure

```tree
.github/
├── workflows/           # Reusable workflows
│   ├── ci/             # CI workflows (lint, typecheck, test)
│   ├── cd/             # CD workflows (release, npm, pypi, docker)
│   ├── security/      # Security workflows (secret scanning, dependency review, code scanning)
│   ├── quality/       # Quality workflows (label-pr, welcome, stale)
│   └── pull-request/  # PR workflows (checks, title format)
├── actions/            # Composite actions
│   ├── setup-python/  # Python setup with uv
│   ├── setup-node/    # Node.js setup with pnpm
│   ├── setup-rust/    # Rust setup
│   ├── setup-docker/  # Docker setup with BuildKit
│   ├── lint/          # Lint action
│   ├── test/          # Test action
│   └── audit/        # Dependency audit action
├── templates/         # Workflow templates for new projects
├── configs/           # Shared configuration files
├── scripts/           # Shared scripts
└── libs/              # Reusable workflow fragments
```

## Usage

### Reusable Workflows

Call workflows from your project:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ci:
    uses: owner/repo/.github/workflows/ci/ci-basic.yml@main
    with:
      python-version: '3.13'
```

### Composite Actions

Use actions directly in your workflows:

```yaml
steps:
  - uses: ./.github/actions/lint
    with:
      lint-command: 'uv run ruff check .'
```

### Templates

Copy templates from `.github/templates/` to your project's `.github/workflows/`.

- `ci.yml.tpl` - Simple CI workflow template
- `full-ci-cd.yml.tpl` - Full CI/CD workflow template
- `pr_agent.yml.tpl` - AI-powered PR review using OpenCode

## Available Workflows

### CI

- `ci/ci-basic.yml` - Lint, typecheck, and test
- `ci/ci-extended.yml` - Basic + coverage reporting
- `ci/ci-legacy.yml` - Multi-version matrix testing

### CD

- `cd/cd-release.yml` - GitHub Releases with Commitizen
- `cd/cd-npm.yml` - NPM package publishing
- `cd/cd-pypi.yml` - PyPI package publishing
- `cd/cd-docker.yml` - Docker image building and publishing

### Security

- `security/secret-scanning.yml` - GitHub Advanced Security secret scanning
- `security/dependency-review.yml` - Dependency vulnerability review
- `security/code-scanning.yml` - CodeQL analysis

### Quality

- `quality/label-pr.yml` - Auto-label PRs based on changed files
- `quality/welcome.yml` - Welcome new contributors
- `quality/stale.yml` - Close stale issues and PRs

### Pull Request

- `pull-request/pr-checks.yml` - Required PR checks
- `pull-request/pr-title-format.yml` - Enforce conventional commit titles

## Available Actions

### PR Agent

AI-powered PR review using OpenCode. Located at `.github/actions/pr-agent/`.

**Usage:**

```yaml
jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
      pull-requests: write
      issues: write
    steps:
      - uses: ./.github/actions/pr-agent
        env:
          OLLAMA_API_KEY: ${{ secrets.OLLAMA_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**With custom model:**

```yaml
steps:
  - uses: ./.github/actions/pr-agent
    with:
      model: "ollama-cloud/llama3:70b"
    env:
      OLLAMA_API_KEY: ${{ secrets.OLLAMA_API_KEY }}
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**With custom prompt:**

```yaml
steps:
  - uses: ./.github/actions/pr-agent
    env:
      OLLAMA_API_KEY: ${{ secrets.OLLAMA_API_KEY }}
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      PR_AGENT_PROMPT: "Your custom prompt here..."
```

## Configuration

### Actionlint

Run actionlint to validate workflows:

```bash
actionlint -config .github/configs/actionlint.yaml .github/workflows/
```

### Shellcheck

Validate shell scripts:

```bash
shellcheck .github/scripts/*.sh
```

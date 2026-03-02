name: OpenCode Review

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

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

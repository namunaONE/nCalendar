# Keeping Linear Project Data in Sync

This repo mirrors Linear project **nCalander** data under `docs/`. Use this guide to refresh the snapshot from Linear.

## Option A — Manual (via Linear MCP)

If you have the Linear MCP server connected, run:

```bash
# 1. Project details
linear get_project --id P-HYA-13   # or list_projects and filter by name

# 2. Issues
linear list_issues   # filter where project == nCalander

# 3. Re-generate docs/linear-project.md and docs/linear-issues.md from the output
```

## Option B — Automated script (Linear GraphQL API)

Create `.github/scripts/sync-linear-docs.py` and run it on a schedule (or via `workflow_dispatch`).

You need a [Linear API key](https://linear.app/settings/api) with `issues` and `projects` read access. Store it as a GitHub secret named `LINEAR_API_KEY`.

```python
import os
import json
import requests

LINEAR_API_KEY = os.environ["LINEAR_API_KEY"]
PROJECT_NAME = "nCalander"

query = """
query {
  project(key: "HYA-13") {   # use the project key/name as appropriate
    id
    name
    summary
    description
    status { name type }
    priority { name value }
    issues { nodes { id identifier title description priority { name value } status statusType createdAt updatedAt url project { name } } }
  }
}
"""

headers = {"Authorization": LINEAR_API_KEY, "Content-Type": "application/json"}
resp = requests.post("https://api.linear.app/graphql", json={"query": query}, headers=headers)
resp.raise_for_status()
data = resp.json()["data"]["project"]

# Write docs/linear-project.md and docs/linear-issues.md from `data`
# ...
```

## Option C — GitHub Actions scheduled sync

Add to `.github/workflows/pages.yml` or a separate workflow:

```yaml
name: Sync Linear docs
on:
  schedule:
    - cron: '0 6 * * *'   # daily 06:00 UTC
  workflow_dispatch:

permissions:
  contents: write

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Linear sync script
        env:
          LINEAR_API_KEY: ${{ secrets.LINEAR_API_KEY }}
        run: python .github/scripts/sync-linear-docs.py
      - name: Commit changes
        run: |
          git config user.name "github-actions"
          git config user.email "github-actions@github.com"
          git add docs/
          git commit -m "docs: refresh Linear project snapshot" || true
          git push
```

## Where the data lives

| File | Contents |
|------|----------|
| `docs/linear-project.md` | Project overview, vision, phases, related projects |
| `docs/linear-issues.md` | All linked issues grouped by phase, with priorities and status |
| `README.md` | Links to the above + live site URL |

## Notes

- Linear issue IDs are immutable (e.g. `HYA-347`), so they make good cross-references in commit messages and Flutter code comments.
- The `nCalander` project status is **Backlog**; once work starts, move it to **In Progress** in Linear and update `docs/linear-project.md`.

# Keeping Linear Project Data in Sync

This repo mirrors Linear project **nCalander** (P-HYA-13, team **HyaMuji**) data into `docs/05-linear-rounds.md`. Use this guide to refresh the snapshot.

## Canonical output

| File | Contents |
|------|----------|
| `docs/05-linear-rounds.md` | Project meta, vision, roadmap phases, all linked issues, status summary, deliverables mapped to code |

## Option A — Manual one-off (Linear MCP)

If you have the Linear MCP server connected:

```bash
linear get_project --id P-HYA-13
linear list_issues   # filter where project == nCalander
```

Then re-run the sync script (Option B) to regenerate `docs/05-linear-rounds.md`.

## Option B — Run the sync script manually

```bash
LINEAR_API_KEY=lin_api_... python .github/scripts/sync-linear-docs.py
```

Exit codes:
- `0` — docs up to date, nothing changed
- `1` — docs updated (commit the change)
- `2` — error

## Option C — Scheduled GitHub Actions (already configured)

`.github/workflows/sync-linear.yml` runs daily at 06:00 UTC and on `workflow_dispatch`. It:
1. Checks out the repo
2. Runs `.github/scripts/sync-linear-docs.py` with `LINEAR_API_KEY`
3. Commits `docs/05-linear-rounds.md` only when it changed

### Required GitHub secret

You must add the Linear API key as a GitHub repository secret so the scheduled workflow can authenticate:

1. Go to **https://github.com/namunaONE/nCalendar/settings/secrets/actions**
2. Click **New repository secret**
3. Name: `LINEAR_API_KEY`
4. Value: your Linear API key (from https://linear.app/settings/api)

> ⚠️ I cannot write this secret for you — only a repository owner/administrator can via the GitHub UI. The workflow will fail with a 401 until the secret is added.

### Trigger a manual sync

From the GitHub repo → **Actions** → **Sync Linear project docs** → **Run workflow**.

## Where the Linear data came from

Fetched live via the Linear GraphQL API (`https://api.linear.app/graphql`):
- Project: `nCalander` (P-HYA-13), state `backlog`, team `HyaMuji`
- All linked issues (HYA-347 → HYA-373+) with priority, state, creator, labels

## Notes

- Linear issue IDs are immutable (e.g. `HYA-347`), so they make good cross-references in commit messages and Flutter code comments.
- The `nCalander` project status is **Backlog**. When work starts, move it to **In Progress** in Linear; the next scheduled sync will update the doc automatically.
- This doc is auto-generated — do not edit `docs/05-linear-rounds.md` by hand. Re-run the sync script instead.

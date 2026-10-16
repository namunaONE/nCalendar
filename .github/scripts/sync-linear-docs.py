#!/usr/bin/env python3
"""Sync Linear project nCalander (P-HYA-13) data into docs/05-linear-rounds.md.

Requires env var LINEAR_API_KEY (Linear API key with issues/projects read access).

Usage:
    LINEAR_API_KEY=lin_api_... python .github/scripts/sync-linear-docs.py

Exit codes:
    0 - docs up to date (or written successfully)
    1 - docs changed (caller should commit)
    2 - error
"""

import json
import os
import sys
from datetime import datetime, timezone

LINEAR_API_KEY = os.environ.get("LINEAR_API_KEY")
if not LINEAR_API_KEY:
    print("ERROR: LINEAR_API_KEY environment variable is required", file=sys.stderr)
    sys.exit(2)

PROJECT_ID = "P-HYA-13"
DOCS_PATH = "docs/05-linear-rounds.md"

GRAPHQL_URL = "https://api.linear.app/graphql"

PRIORITY_LABELS = {
    0: "No priority",
    1: "Urgent",
    2: "High",
    3: "Medium",
    4: "Low",
}


def graphql(query: str) -> dict:
    import urllib.request

    req = urllib.request.Request(
        GRAPHQL_URL,
        data=json.dumps({"query": query}).encode("utf-8"),
        headers={
            "Authorization": LINEAR_API_KEY,
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode("utf-8"))


def fetch_project() -> dict:
    query = f"""
    query {{
      project(id: "{PROJECT_ID}") {{
        id
        name
        description
        url
        priority
        state
        teams {{ nodes {{ id name key }} }}
        lead {{ id name email }}
      }}
    }}
    """
    data = graphql(query)
    if data.get("errors"):
        raise RuntimeError(f"GraphQL errors: {data['errors']}")
    return data["data"]["project"]


def fetch_issues(project_id: str) -> list:
    """Fetch all issues for a project with cursor pagination."""
    issues = []
    cursor = None
    while True:
        after = f', after: "{cursor}"' if cursor else ""
        query = f"""
        query {{
          project(id: "{PROJECT_ID}") {{
            issues(first: 100{after}) {{
              nodes {{
                identifier
                title
                description
                url
                priority
                state {{ name type }}
                createdAt
                updatedAt
                completedAt
                dueDate
                creator {{ id name email }}
                assignee {{ id name email }}
                labels {{ nodes {{ name color }} }}
              }}
              pageInfo {{ hasNextPage endCursor }}
            }}
          }}
        }}
        """
        data = graphql(query)
        if data.get("errors"):
            raise RuntimeError(f"GraphQL errors: {data['errors']}")
        conn = data["data"]["project"]["issues"]
        issues.extend(conn["nodes"])
        if not conn["pageInfo"]["hasNextPage"]:
            break
        cursor = conn["pageInfo"]["endCursor"]
    return issues


def fmt_date(iso: str | None) -> str:
    if not iso:
        return "—"
    try:
        dt = datetime.fromisoformat(iso.replace("Z", "+00:00"))
        return dt.strftime("%Y-%m-%d")
    except Exception:
        return iso or "—"


def priority_label(value) -> str:
    try:
        v = int(value)
    except (TypeError, ValueError):
        return "—"
    return PRIORITY_LABELS.get(v, str(v))


def state_name(issue: dict) -> str:
    st = issue.get("state") or {}
    if isinstance(st, dict):
        return st.get("name", "—")
    return str(st) if st else "—"


def state_type(issue: dict) -> str:
    st = issue.get("state") or {}
    if isinstance(st, dict):
        return st.get("type", "—")
    return "—"


def generate_markdown(project: dict, issues: list) -> str:
    lines: list[str] = []

    lines.append("# Linear Project — nCalander / nCalendar")
    lines.append("")
    lines.append(
        "Real data pulled from Linear workspace **HyaMuji** → project **nCalander** (P-HYA-13). "
        "This doc is the canonical project-data mirror; keep it in sync with Linear (see `docs/LINEAR_SYNC.md`)."
    )
    lines.append("")
    lines.append("> Auto-generated on " + datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC") + " via `docs/LINEAR_SYNC.md`. Do not edit by hand — re-run the sync script instead.")
    lines.append("")

    # ---- Project Meta ----
    lines.append("## Project Meta")
    lines.append("")
    lines.append("| Field | Value |")
    lines.append("|-------|-------|")
    lines.append(f"| Project ID | P-HYA-13 |")
    lines.append(f"| Team | {', '.join(t['name'] + ' (`' + t['key'] + '`)' for t in (project.get('teams') or {}).get('nodes', [])) or '—'} |")
    lines.append(f"| Linear URL | {project.get('url')} |")
    lines.append(f"| Status | {project.get('state', '—')} |")
    pj_priority = project.get("priority")
    lines.append(f"| Priority | {priority_label(pj_priority)} |")
    lead = project.get("lead")
    lines.append(f"| Lead | {lead['name']} ({lead['email']}) |" if lead else "| Lead | — |")
    lines.append("")

    # ---- Vision ----
    lines.append("## Vision")
    lines.append("")
    desc = (project.get("description") or "").strip()
    lines.append(desc if desc else "_No description set._")
    lines.append("")

    # ---- Roadmap phases ----
    lines.append("## Roadmap phases")
    lines.append("")
    lines.append(
        "| Phase | Linear issue | Focus | Priority | Status |"
    )
    lines.append("|-------|--------------|-------|----------|--------|")
    phases = [
        ("Phase 1", "HYA-347", "Dataset repo foundations: invariant checker in CI + codegen", "High"),
        ("Phase 2", "HYA-348", "Core Dart engine + test wall (24 anchors + property tests)", "High"),
        ("Phase 3", "HYA-349", "Publish 1.0.0 (pana 140/140, CI matrix, semver data policy)", "Medium"),
        ("Phase 4", "HYA-350", "Ecosystem layer: Flutter date picker, calendar grid, fiscal toolkit, i18n ← this web app", "Medium"),
        ("Phase 5", "HYA-351", "Yearly runbook: patro-day SOP + maintenance continuity", "Medium"),
    ]
    issue_map = {i["identifier"]: i for i in issues}
    for phase, iid, focus, prio in phases:
        issue = issue_map.get(iid, {})
        st = state_name(issue)
        lines.append(f"| {phase} | [{iid}]({issue.get('url', '#')}) | {focus} | {prio} | {st} |")
    lines.append("")

    # ---- All issues ----
    lines.append("## All linked issues")
    lines.append("")
    lines.append(
        "| Issue | Title | Priority | State | Type | Updated | Creator |"
    )
    lines.append("|-------|-------|----------|-------|------|---------|---------|")
    # Sort: done last, then by identifier
    def sort_key(issue):
        st_type_val = state_type(issue)
        ident = issue.get("identifier", "")
        return (st_type_val == "completed", ident)
    for issue in sorted(issues, key=sort_key):
        iid = issue.get("identifier", "")
        title = (issue.get("title") or "").replace("|", "\\|")
        url = issue.get("url", "#")
        prio = priority_label(issue.get("priority"))
        st = state_name(issue)
        stt = state_type(issue)
        updated = fmt_date(issue.get("updatedAt"))
        creator = (issue.get("creator") or {}).get("name", "—")
        lines.append(f"| [{iid}]({url}) | {title} | {prio} | {st} | {stt} | {updated} | {creator} |")
    lines.append("")

    # ---- Status summary ----
    backlog = [i for i in issues if state_type(i) == "backlog"]
    done = [i for i in issues if state_type(i) == "completed"]
    started = [i for i in issues if state_type(i) == "started"]
    canceled = [i for i in issues if state_type(i) == "canceled"]
    urgent = [i for i in issues if isinstance(i.get("priority"), (int, float)) and int(i["priority"]) == 1]
    high = [i for i in issues if isinstance(i.get("priority"), (int, float)) and int(i["priority"]) == 2]

    lines.append("## Status summary")
    lines.append("")
    lines.append("| Status | Count | Issues |")
    lines.append("|--------|-------|--------|")
    lines.append(f"| Backlog | {len(backlog)} | {', '.join(i['identifier'] for i in backlog) or '—'} |")
    lines.append(f"| In Progress | {len(started)} | {', '.join(i['identifier'] for i in started) or '—'} |")
    lines.append(f"| Done | {len(done)} | {', '.join(i['identifier'] for i in done) or '—'} |")
    lines.append(f"| Canceled | {len(canceled)} | {', '.join(i['identifier'] for i in canceled) or '—'} |")
    lines.append(f"| Urgent (P1) | {len(urgent)} | {', '.join(i['identifier'] for i in urgent) or '—'} |")
    lines.append(f"| High (P2) | {len(high)} | {', '.join(i['identifier'] for i in high) or '—'} |")
    lines.append(f"| Total linked | {len(issues)} | — |")
    lines.append("")

    # ---- Phases detail ----
    lines.append("## Deliverables per phase (mapped to nCalendar code)")
    lines.append("")
    lines.append("| Phase | Linear issue | Deliverable | Files |")
    lines.append("|-------|--------------|-------------|-------|")
    deliverables = [
        ("Phase 1", "HYA-347", "BS data model + JSON loader + invariant checker", "lib/models/bs_day.dart, lib/models/bs_month.dart, lib/services/bs_data_service.dart, assets/bs_data.json"),
        ("Phase 2", "HYA-348", "Core Dart engine: immutable BsDate, adToBs/bsToAd, todayInNepal(), evidence(year), loud errors outside verified range; 24-anchor golden tests + property tests", "(planned — not yet implemented)"),
        ("Phase 3", "HYA-349", "Publish 1.0.0: accuracy contract README, GitHub Actions CI on 3 SDK versions, semver data policy", ".github/workflows/pages.yml"),
        ("Phase 4", "HYA-350", "Flutter web calendar grid + date picker widgets + fiscal toolkit + i18n (Devanagari digits, month spellings)", "lib/main.dart, lib/widgets/calendar_grid.dart, lib/theme/n_calendar_theme.dart, web/index.html"),
        ("Phase 5", "HYA-351", "Yearly runbook: patro-day SOP, maintenance continuity, <7-day update from NPNS publication", "(planned)"),
    ]
    for phase, iid, deliverable, files in deliverables:
        issue = issue_map.get(iid, {})
        lines.append(f"| {phase} | [{iid}]({issue.get('url', '#')}) | {deliverable} | {files} |")
    lines.append("")

    # ---- Related projects ----
    lines.append("## Related Linear projects (same team `HyaMuji`)")
    lines.append("")
    lines.append("| Project | ID | Focus | Stack |")
    lines.append("|---------|-----|-------|-------|")
    lines.append("| nKount | P-HYA-12 | Accounting web + mobile | Flutter, Riverpod, SQLite, Supabase |")
    lines.append("| nGEO | P-HYA-11 | Nepal local bodies data (753 levels) | Dart package + React explorer |")
    lines.append("| nBhumi | P-HYA-10 | Nepal property marketplace | Flutter, Riverpod, Supabase |")
    lines.append("")

    # ---- Notes / blockers ----
    lines.append("## Notes / blockers")
    lines.append("")
    lines.append("- HYA-362 (Commons legal review) is a gate for Layer 2 (tithi/panchang) publication.")
    lines.append("- HYA-368 (muhurta pipeline) is behind the HYA-362 legal gate.")
    lines.append("- HYA-353 (datepicker embedded-data bug) is **Urgent** — a live production bug in `@sbmdkl/nepali-datepicker-reactjs`.")
    lines.append("- Verified BS reference data: `calendar.csv` (1975–2083, evidence-tagged). This repo ships a sample in `assets/bs_data.json`; replace it with the full verified export.")
    lines.append("")

    # ---- Next steps ----
    lines.append("## Next steps")
    lines.append("")
    lines.append("1. Replace `assets/bs_data.json` sample with the full verified `calendar.csv` (BS 1975–2083) export from the nCalander commons.")
    lines.append("2. Implement Phase 2 core Dart engine (`adToBs`/`bsToAd` computation) so the web app computes rather than looks up.")
    lines.append("3. Link GitHub branches/PRs to Linear issues (e.g. `HYA-350`) so work auto-connects in Linear.")
    lines.append("4. Refresh this doc when Linear state changes — see `docs/LINEAR_SYNC.md`.")
    lines.append("")

    return "\n".join(lines)


def main() -> int:
    try:
        project = fetch_project()
    except Exception as exc:
        print(f"ERROR: failed to fetch project: {exc}", file=sys.stderr)
        return 2

    try:
        issues = fetch_issues(project["id"])
    except Exception as exc:
        print(f"ERROR: failed to fetch issues: {exc}", file=sys.stderr)
        return 2

    content = generate_markdown(project, issues)

    existed = os.path.exists(DOCS_PATH)
    previous = ""
    if existed:
        with open(DOCS_PATH, "r", encoding="utf-8") as fh:
            previous = fh.read()

    if previous == content:
        print(f"OK: {DOCS_PATH} is up to date ({len(issues)} issues).")
        return 0

    with open(DOCS_PATH, "w", encoding="utf-8") as fh:
        fh.write(content)
    action = "created" if not existed else "updated"
    print(f"{action.capitalize()}: {DOCS_PATH} ({len(issues)} issues).")
    return 1


if __name__ == "__main__":
    sys.exit(main())

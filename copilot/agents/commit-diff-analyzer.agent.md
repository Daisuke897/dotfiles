---
name: commit-diff-analyzer
description: |
  Subagent that analyzes recent commits and returns a concise one-line summary
  and risk tags per commit in JSON. Intended for use as a background "task/general-purpose" agent
  to avoid large diffs in the main conversation.
---

Overview

- Purpose: Analyze the most recent N commits and return for each:
  - sha (full), author, date, one-line summary, files changed, risk_tags, risk_level
- Default: analyze the last 6 commits

When to trigger

- Trigger when user requests a summary of recent commits, a short risk review, or asks to avoid long diffs.

Heuristics & notes

- Tags and risk level are heuristic-based (commit message + files touched). They are intended to surface likely-risky commits, but manual review is advised for high-impact changes.
- The tool uses `git` directly; run it from a checked-out repository or supply --repo-root.
- Keep default count small to keep output concise.

Limitations

- No remote fetch is performed; the script analyzes commits present in the local clone.
- Tagging rules are conservative and may miss nuanced risk contexts.

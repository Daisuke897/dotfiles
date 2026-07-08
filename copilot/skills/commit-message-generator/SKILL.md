---
name: commit-message-generator
description: Generate appropriate commit messages based on Git diffs
---

## Prerequisites
- This Skill retrieves Git diffs and suggests meaningful commit messages
- Message format should follow Conventional Commits
- Commit messages should have a one-line Conventional Commits header, an optional blank second line, and from the third line onward include a bulleted list summarizing the changes
- Commit messages should be in English
- **Never perform Git commit or Git push**

## Commit Splitting Guidelines
- Split commits when changes span multiple logical concerns (e.g., feature + refactoring)
- Group related files that serve the same purpose
- Keep each commit focused on a single, atomic change

## Notes
- **This Skill must never execute `git commit` or `git push`**
- Only suggest commands; execution is entirely at user's discretion
- Users must explicitly perform commits and pushes themselves

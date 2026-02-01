---
name: forgejo-cli-ops
description: Use the Forgejo CLI (fj) to authenticate and operate on a Forgejo instance (issues, PRs, repositories) with correct host handling.
---

## Scope
- Authenticate to a Forgejo host and verify access.
- Run common issue/PR/repo commands with the correct host.
- Troubleshoot host and login mismatches.

## Prerequisites
- A Forgejo Personal Access Token (PAT) created in the Forgejo web UI.
- `fj` installed and available in PATH.
- Optional: `secret-tool` (GNOME Keyring) for secure token storage.

## Host usage (important)
`-H/--host` is a **global** option and must be placed **before** subcommands.
```bash
fj -H <FORGEJO_HOST> repo view <owner>/<repo>
```

To avoid repeating the host, set `FJ_HOST`:
```bash
export FJ_HOST=<FORGEJO_HOST>
```

## Authentication (secret-tool example)
Store your token (one-time) and register with fj:
```bash
echo -n "<PAT_VALUE>" | secret-tool store --label="Forgejo PAT" service forgejo user <username>@<FORGEJO_HOST>
echo -n "$(secret-tool lookup service forgejo user <username>@<FORGEJO_HOST>)" | fj -H <FORGEJO_HOST> auth add-key <username>
```

Verify:
```bash
fj -H <FORGEJO_HOST> auth list
fj -H <FORGEJO_HOST> whoami
```

## Cleanup
```bash
fj auth logout <FORGEJO_HOST>
secret-tool clear service forgejo user <username>@<FORGEJO_HOST>
```

## Troubleshooting
- `Error: not logged in` often means the host defaulted to github.com; add `-H` or set `FJ_HOST`.
- If `secret-tool lookup` returns nothing, unlock your keyring or confirm the stored user/host key.

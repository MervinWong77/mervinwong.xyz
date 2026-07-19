# Temporary files policy (P0)

## Production rule

**CopyCat must never create, modify, or delete files inside a user-selected scan root.**

Scanning is read-only with respect to the user’s folders and drives.

## What the engine may write

| Artifact | Location | Lifetime |
|----------|----------|----------|
| Pass-2 candidate SQLite | `FileManager.default.temporaryDirectory/CopyCatScan-<UUID>/` | Deleted on finish, cancel, failure (`defer` + `closeAndDelete`) |

No other production writes are allowed on disk for a scan.

## What left `copycat-io-bench-*` on drives

Those folders were **developer benchmark fixtures**, created during engine I/O work by agent shell scripts (not by `CopyCat.app`). They were written under `/tmp` and, incorrectly, once under `MERVIN 12TB/`. That must never happen again.

`CANCEL-AND-UX-FIX.md` is repository documentation under `docs/` (if present). The scanner does not create markdown files.

## Developer tooling

- Create fixtures only via `scripts/make-io-fixture.sh` (system temp).
- Clean leftovers via `scripts/cleanup-dev-fixtures.sh`.
- Never create fixtures on `/Volumes/…` user media drives.

## Verification

Engine tests:

- Candidate store path is under `temporaryDirectory`
- Successful scan leaves scan root snapshot unchanged
- Cancelled scan leaves scan root snapshot unchanged

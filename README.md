# emdash-claude-plugin

A Claude Code plugin bundling skills and agents for building, debugging, and deploying [EmDash CMS](https://emdashcms.com) sites on Astro + Cloudflare.

## Skills

| Skill | Description |
|-------|-------------|
| `building-emdash-site` | Pages, content queries, schema, seed, site features, Portable Text rendering |
| `creating-plugins` | EmDash plugin authoring — hooks, storage, admin UI, API routes, block types |
| `emdash-cli` | CLI commands: `emdash dev`, `emdash seed`, `emdash types`, `emdash init` |
| `emdash-github-actions` | CI/CD setup with GitHub Actions |
| `wordpress-plugin-to-emdash` | Migrate WordPress plugins to EmDash |
| `wordpress-theme-to-emdash` | Migrate WordPress themes to EmDash (6-phase process) |
| `adversarial-reviewer` | Code review skill |
| `agent-browser` | Browser automation for testing |

## Agents

Investigation pipeline agents (adapted from EmDash CI workflows):

| Agent | Description |
|-------|-------------|
| `diagnose` | Trace a symptom to the source code that causes it |
| `verify` | Decide whether diagnosed behaviour is a bug or intended |
| `fix` | Implement a fix when verify says bug and diagnose has confidence |
| `repro-api` | Reproduce bugs in REST handlers, CLI, migrations, build tooling |
| `repro-admin` | Reproduce bugs in the EmDash admin UI (browser-based) |
| `repro-public` | Reproduce bugs in the public-facing rendered site |

## Installation

```bash
# Install as a Claude Code plugin
claude plugin install https://github.com/EngDawood/emdash-claude-plugin
```

## Usage

After installing, skills auto-activate based on context. You can also invoke them explicitly:

```
/building-emdash-site
/creating-plugins
/emdash-cli
```

## Skill sync

Skills are auto-synced from the upstream [emdash-cms/emdash](https://github.com/emdash-cms/emdash) repository (`main` branch, `skills/` path) by the [`sync-skills` workflow](.github/workflows/sync-skills.yml):

- Runs **daily** (06:23 UTC), or on demand via **Actions → Sync skills → Run workflow** (with an optional *force* flag).
- Mirrors every skill listed in the `sync` array of [`.github/skills-sync.json`](.github/skills-sync.json) — the local copy is replaced with the upstream version.
- Pushes a bot commit straight to `main`: `chore(skills): sync from emdash-cms/emdash@<sha>`.
- The last synced upstream commit is tracked in [`.github/skills-sync-state.json`](.github/skills-sync-state.json), so runs where upstream hasn't moved exit in seconds without committing.

**Not synced:**

- `wordpress-theme-to-emdash` — this plugin's local variant (6-phase flow with a `scaffold/` starter); managed manually.
- `emdash-github-actions` — plugin-specific, doesn't exist upstream.
- Internal upstream skills (`ux-acceptance-coordinator`, `writing-emdash-docs`) — not relevant to plugin users.

To sync an additional upstream skill, add its name to `sync` (and remove it from `excluded`) in `.github/skills-sync.json`.

## Project-specific setup

Some things are intentionally NOT in this plugin (they're project-specific):

- Task tracker skills (hardcoded API endpoints)
- Project navigation guide (`/guide`)

Add those locally in your project's `.claude/skills/`.

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

## Project-specific setup

Some things are intentionally NOT in this plugin (they're project-specific):

- Task tracker skills (hardcoded API endpoints)
- Project navigation guide (`/guide`)

Add those locally in your project's `.claude/skills/`.

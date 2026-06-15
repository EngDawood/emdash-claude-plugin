This is a Claude Code plugin for EmDash CMS sites -- a collection of skills and investigation agents for building on Astro + Cloudflare.

## Plugin Structure

| Path | Purpose |
| ---- | ------- |
| `.claude-plugin/plugin.json` | Manifest (name, version, author) |
| `skills/<name>/SKILL.md` | Skill entry point (auto-discovered) |
| `skills/<name>/references/` | Supporting docs for the skill |
| `agents/<name>.md` | Investigation pipeline agents |

## Skills

| Skill | When to load |
| ----- | ------------ |
| `building-emdash-site` | Pages, content queries, schema, seed, Portable Text, menus, widgets, SEO |
| `creating-plugins` | EmDash plugin authoring -- hooks, storage, admin UI, API routes, block types |
| `emdash-cli` | CLI commands: `emdash dev`, `emdash seed`, `emdash types`, `emdash init` |
| `emdash-github-actions` | CI/CD with GitHub Actions |
| `wordpress-plugin-to-emdash` | Migrate a WordPress plugin to EmDash |
| `wordpress-theme-to-emdash` | Migrate a WordPress theme to EmDash (6 phases) |
| `adversarial-reviewer` | Code review |
| `agent-browser` | Browser automation for testing |

## Agents

Investigation pipeline (adapted from EmDash CI workflows). Stages run in order:

`repro-api / repro-admin / repro-public` → `diagnose` → `verify` → `fix` (conditional)

See `agents/_INVESTIGATE.md` for the full pipeline reference.

## Documentation

EmDash docs MCP: `https://docs.emdashcms.com/mcp`
Call `search_docs` to verify any EmDash API, hook, config option, or field type -- do not guess from training data.

## Rules

- Skills must be generic -- no hardcoded project URLs, tokens, or endpoints.
- Project-specific skills (tracker, guide) belong in the consuming project's `.claude/skills/`, not here.
- Each skill lives in its own subdirectory; supporting docs go in `references/`.
- Agents are single `.md` files in `agents/`.
- No build step -- edit `SKILL.md` or reference docs directly.

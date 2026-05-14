# superpowers-jtbd

Companion plugin for the superpowers ecosystem. Runs JTBD interviews and feeds structured output into the brainstorming pipeline.

## Structure

- `skills/jtbd/SKILL.md` — the interview skill
- `skills/jtbd/scripts/` — Python validators and ingest tools
- `skills/jtbd/references/` — interview frameworks and quality gates
- `skills/jtbd/templates/` — output artifact templates
- `hooks/` — PreToolUse hook that bridges jtbd.json into brainstorming

## The chain

`/superpowers-jtbd:jtbd` -> jtbd.json -> `/superpowers:brainstorming` (auto-bridged) -> writing-plans -> implementation

## Output

Primary: `~/jtbd/<slug>/jtbd.json` + one-pager + messaging-angles + gtm-brief
Symlink: `./jtbd.json` in project root (if git repo)

## Testing

```bash
cd skills/jtbd && python -m pytest tests/ -v
```

# superpowers-jtbd

![superpowers-jtbd cover](docs/assets/superpowers-jtbd-cover.png)

> JTBD interview engine for the [superpowers](https://github.com/obra/superpowers) pipeline.

Captures jobs, switch forces, and outcomes through a structured terminal interview. Outputs machine-readable `jtbd.json` that auto-feeds into `superpowers:brainstorming` — no manual handoff.

## Install

```bash
/plugin install glebis/superpowers-jtbd
```

## Usage

```
/superpowers-jtbd:jtbd
```

Run a JTBD interview. At the end, the skill suggests running `/superpowers:brainstorming` — the hook auto-injects your JTBD context so brainstorming skips questions already answered.

### The chain

```
/superpowers-jtbd:jtbd     ->  jtbd.json
                                    |
/superpowers:brainstorming  <-  hook injects context
                                    |
/superpowers:writing-plans  ->  implementation plan
```

### Modes

| Mode | Input | Output |
|---|---|---|
| **Interview** (default) | live conversation | full artifact bundle |
| **Transcript ingest** | voice transcript path | artifact bundle + confidence flags |
| **Review mining** | CSV/JSON reviews | review-brief.md pre-seed -> interview |
| **Update** | existing jtbd.json | updated bundle |

## What it produces

- `~/jtbd/<slug>/jtbd.json` — machine-readable source of truth
- `~/jtbd/<slug>/one-pager.md` — shareable summary
- `~/jtbd/<slug>/messaging-angles.md` — copy angles from switch forces
- `~/jtbd/<slug>/gtm-brief.md` — positioning + growth experiments
- `./jtbd.json` — symlink in project root for local discovery

## How the hook works

A PreToolUse hook fires when `superpowers:brainstorming` is invoked. It checks for `jtbd.json` in the project root or `~/jtbd/`, and injects the content + field mapping as brainstorming context. Brainstorming then skips answered questions and uses switch forces for approach selection.

## Quality gates

- **Granularity Gate** — scores interview output 0-2 on 5 dimensions. Any 0 blocks save.
- **Jargon Kill Switch** — bans vague marketing phrases. Demands evidence.
- **ODI Scoring** — optional opportunity scoring when 3+ outcomes are on the table.

## License

MIT

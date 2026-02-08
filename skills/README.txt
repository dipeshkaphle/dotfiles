# Centralized Skills

This directory contains skills shared across your agents.

## Structure
To support all agents, use this structure:

```
skills/
├── skill-name/
│   └── SKILL.md
```

## Supported Agents
This directory is symlinked to the configuration paths of multiple agents:

- **Pi**: `~/.pi/agent/skills`
- **Claude / Amp**: `~/.claude/skills`
- **Gemini**: `~/.gemini/skills`
- **Standard (OpenCode, Codex)**: `~/.agents/skills`

## Frontmatter

Always include YAML frontmatter in SKILL.md files. This is required for skill discovery:

```yaml
---
name: skill-name
description: Does X when Y happens. Use for Z tasks.
---
```

- `name`: lowercase, hyphens only, must match the parent directory name
- `description`: what the skill does and when to use it

## Example
`hello/SKILL.md`:
```markdown
---
name: hello
description: Says hello. Use when asked to say hello or greet.
---

# Hello
Use this skill to say hello.

## Steps
1. Run `echo "Hello World"`
```

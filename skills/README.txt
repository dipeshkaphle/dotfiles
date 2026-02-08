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

## Available Skills

### Internal
- **hello**: Basic greeting skill.

### External Sources
- **ast-grep**: Structural code search and replacement.
  - Source: https://github.com/ast-grep/agent-skill

- **ruff**: An extremely fast Python linter and code formatter.
  - Source: https://github.com/astral-sh/claude-code-plugins (Astral)

- **ty**: A skill for type checking Python code.
  - Source: https://github.com/astral-sh/claude-code-plugins (Astral)

- **uv**: An extremely fast Python package and project manager.
  - Source: https://github.com/astral-sh/claude-code-plugins (Astral)

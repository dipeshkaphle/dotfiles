# Centralized Scripts

This directory is in your `PATH`.
Executable scripts placed here can be run from anywhere in your terminal.

## Usage
- **Tools**: Create scripts here (bash, python, node) to automate tasks.
- **Agents**: Pi and Claude can run these scripts natively since they are standard commands.
- **Skills**: Your Pi skills (`~/dotfiles/skills/*.md`) can reference these scripts as implementation steps.

## Example
`~/dotfiles/scripts/my-script`:
```bash
#!/bin/bash
echo "Hello"
```
Run `my-script` from any terminal or agent.

---
description: "Convert markdown documents to PDF (spawns agent)"
allowed-tools: Task, Read, Glob, Bash
---

# PDF Print Command (Agent Wrapper)

This command resolves file references and spawns an agent for conversion.

## Your Role

You are the **resolver**. The agent is the **executor**. You handle **post-processing**.

1. **Resolve** the file reference to a concrete absolute path
2. **Spawn** the `pdf-printing:print-agent` with that path
3. **Open PDF in Chrome** after agent completes successfully
4. **Report** the result

## Arguments

| Input | Your Action |
|-------|-------------|
| Explicit path: `/print docs/readme.md` | Use path directly |
| Reference: `/print it`, `/print this doc` | Resolve from context |
| No args: `/print` | Check context for recent file, or show status |

## Resolving References

When user says "print it" or "print this doc":
1. Look at recent conversation for edited/mentioned files
2. Find the most recent `.md` file reference
3. Verify the file exists
4. Use that absolute path

## Spawning Agent

Use Task tool with:
- `subagent_type`: `pdf-printing:print-agent`
- `prompt`: `"Print {absolute_path}"`
- `model`: `sonnet`

Example:
```
Task(
  subagent_type: "pdf-printing:print-agent",
  prompt: "Print C:\\path\\to\\file.md",
  description: "Print file.md to PDF"
)
```

## Post-Processing: Open in Chrome

After the agent returns successfully:
1. **Extract PDF path** from agent's result (looks for path ending in `.pdf`)
2. **Open in Chrome** using Bash:

```powershell
Start-Process chrome "C:\path\to\output.pdf"
```

**Why here, not in agent?** The agent runs as a subprocess without GUI access. Chrome must be opened from the main conversation context.

## Status Mode (No File Found)

If no file argument and no recent file in context:
```
PDF Printing Plugin

Usage:
  /print path/to/file.md    Convert specific file
  /print it                  Print recently edited file
  /print-noagent file.md    Inline conversion (uses context)
```

## Error Cases

| Case | Response |
|------|----------|
| Can't resolve reference | Ask user to specify file |
| File doesn't exist | Report error with path |
| Not a .md file | Report only markdown supported |

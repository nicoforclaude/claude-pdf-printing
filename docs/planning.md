# PDF Printing Planning

## Agent-Based Print Command (In Progress)

### Problem

Current `/print` command runs inline, consuming context when user says "print this doc". Most printing work doesn't need conversation context - just file resolution and script execution.

### Solution

Split into two commands:
- `/print` (default) - Lightweight wrapper that spawns agent
- `/print-noagent` - Inline execution for context-dependent scenarios

### Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Default command | Agent version | Saves context for main conversation |
| No-arg handling | Command determines files clearly | Agent can parse command output |
| Context access | Summary from caller | Balance between context awareness and isolation |
| Agent model | Sonnet | Better file inference from summaries |

### Implementation Steps

- [x] Rename `commands/print.md` → `commands/print-noagent.md`
- [x] Create `agents/print-agent.md` (Sonnet model)
- [x] Create new `commands/print.md` as wrapper that spawns agent with summary

### File Changes

**BEFORE** (`commands/print.md` lines 1-4):
```markdown
---
description: "Convert markdown documents to PDF"
allowed-tools: Bash(mkdir:*), Bash(Test-Path:*), ...
---
```

**AFTER** (new `commands/print.md`):
```markdown
---
description: "Convert markdown documents to PDF (spawns agent)"
allowed-tools: Task
---

Wrapper responsibility:
1. Resolve file reference from context ("it", "this doc", "overview doc" → actual path)
2. Spawn agent with CONCRETE path: "Print C:\path\to\file.md"

Agent receives explicit path - no context inference needed.
```

**NEW** (`agents/print-agent.md`):
```markdown
---
name: print-agent
description: Converts markdown to PDF. Resolves file references and executes conversion.
tools: Bash, Read, Glob
model: sonnet
---

Agent instructions for PDF conversion...
```

---

## Future Features

Options (saved in plugin settings):
- after printing to pdf is done, open in Chrome / browser
- remove PDF after opening in browser

Footer and pagination:
- ~~Page numbering: "page X of Y" in footer~~ (done)
- ~~Filename in footer~~ (done)
- Page breaks: split pages on # H1 headings
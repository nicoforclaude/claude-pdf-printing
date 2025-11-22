# Claude PDF Printing Plugin

PDF printing and documentation export plugins for Claude Code.

## Installation

1. Add the marketplace:
```bash
/plugin marketplace add /path/to/claude-pdf-printing
```

Or via URL (when published):
```bash
/plugin marketplace add https://github.com/nicoforclaude/claude-pdf-printing
```

2. Install the plugin:
```bash
/plugin install pdf-printing@claude-pdf-printing
```

## Plugins

### pdf-printing

Print markdown documentation to PDF with interactive selection.

**Commands:**
- `/pdf-printing:print` - Convert markdown files to PDF

**Usage:**
```bash
/pdf-printing:print           # Show status
/pdf-printing:print file.md   # Convert to PDF
```

## Requirements

- Node.js with npx
- First run requires installation (see `plugins/pdf-printing/docs/installation.md`)

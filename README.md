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
- `/pdf-printing:init` - Initialize PDF printing setup (one-time)
- `/pdf-printing:print` - Print selected markdown files to PDF

## Development Status

Currently in testing phase - basic structure only, implementation pending.

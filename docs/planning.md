# Claude PDF Printing - Planning Document

**Created:** 2025-11-17
**Status:** Planning Phase

---

## Goals

Create a public marketplace for PDF generation and document utilities that are broadly useful to the Claude Code community.

---

## Current State Analysis

### Existing Command: `/print_docs`

Located at: `<workspace-root>/.claude/commands/print_docs.md`

**Current Functionality:**

✅ **Analyzed!** The command is quite sophisticated:

1. **File Discovery** - Uses `git log` to find recently modified .md files (default 7 days)
2. **Line Counting** - Gets line counts with `wc -l` for decision-making
3. **Smart Exclusions** - Maintains `.localdata/printing/excludeFromPrinting.md` to remember rejected files
4. **Interactive Selection** - Creates `.localdata/printing/selectForPrinting.md` with:
   - Categorized file list
   - Clickable links
   - Line counts
   - User edits to select files
5. **File Preparation** - Copies selected files to `.localdata/printing/`
6. **PDF Conversion** - Uses `npx md-to-pdf` to convert
7. **Organization** - Moves PDFs to `.localdata/printing/pdfsForPrint/`
8. **Exclusion Updates** - Auto-updates exclusion list based on user selections
9. **Reporting** - Shows generated PDFs with file sizes

**Dependencies:**
- `git` (for file discovery)
- `npx` / Node.js (for md-to-pdf)
- Bash tools: `wc`, `mkdir`, `cp`, `mv`, `ls`

**Categorization Logic (Project-Specific):**
- Project Instructions & Notes
- Bot Diagnostics & Tests
- Metrics & Documentation
- Gameplay Packages
- Server Documentation
- Claude Notes & Productivity
- Other Documentation

**Action Items:**
- [x] Read and analyze `/print_docs` command
- [x] Document current features
- [x] Identify dependencies (Node.js + md-to-pdf)
- [ ] Test current functionality
- [ ] Identify what needs to be generalized (see below)

---

## Use Case Deep Dive

### UC1: Export Claude Session Documentation
**Actor:** Developer using Claude Code
**Goal:** Create shareable PDF of important conversation
**Steps:**
1. User completes valuable session with Claude
2. Runs command to generate PDF
3. Selects which parts to include
4. Gets formatted PDF output
5. Shares with team/archives

**Requirements:**
- Preserve code formatting
- Include screenshots/images if present
- Maintain conversation structure
- Add metadata (date, topic, etc.)

### UC2: Batch Documentation Generation
**Actor:** Project maintainer
**Goal:** Generate PDF docs from multiple markdown files
**Steps:**
1. User has folder of markdown documentation
2. Runs batch conversion
3. Gets individual or merged PDF
4. Uses for project deliverables

**Requirements:**
- Batch processing
- Maintain document structure
- Table of contents
- Consistent formatting

### UC3: Quick Session Archive
**Actor:** Developer
**Goal:** Quickly save session for reference
**Steps:**
1. Simple command with defaults
2. Auto-generates PDF with timestamp
3. Saves to known location

**Requirements:**
- Minimal user input
- Fast execution
- Predictable output location

---

## Technical Planning

### Plugin Structure

```
plugins/
└── doc-printer/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── commands/
    │   └── print_docs.md (or print.md?)
    └── README.md
```

**Questions:**
- Command name: `/print_docs` or `/print` or `/pdf`?
- Configuration file support?
- Where to store generated PDFs?

### Dependencies

**Options:**
1. **Markdown to PDF libraries:**
   - Python: `markdown-pdf`, `weasyprint`
   - Node: `markdown-pdf`, `puppeteer`
   - System: `pandoc` (most powerful)

2. **Approach A: Require external dependency**
   - Pro: More features, better quality
   - Con: Installation friction
   - Best: `pandoc` (widely used)

3. **Approach B: Pure JavaScript/embedded**
   - Pro: No installation needed
   - Con: Limited features
   - Best: `markdown-pdf` npm package

**Decision Needed:** Which approach?

### Configuration

**Potential Settings:**
```json
{
  "output_directory": "./claude-exports",
  "pdf_options": {
    "format": "A4",
    "margin": "1cm",
    "include_date": true,
    "include_toc": false
  },
  "filters": {
    "default_days": 7,
    "include_patterns": ["*.md"],
    "exclude_patterns": ["node_modules/**"]
  }
}
```

**Questions:**
- Global config vs per-project?
- How to override defaults?
- Schema validation?

---

## Feature Prioritization

### MVP (Minimum Viable Product)
- [ ] Basic markdown to PDF conversion
- [ ] Single file processing
- [ ] Interactive file selection
- [ ] Default formatting

### Version 1.0
- [ ] Batch processing
- [ ] Date range filtering
- [ ] Basic configuration options
- [ ] Error handling

### Future Enhancements
- [ ] Custom templates
- [ ] Multiple output formats (HTML, DOCX)
- [ ] Merge multiple files
- [ ] Table of contents generation
- [ ] Syntax highlighting for code blocks
- [ ] Image embedding support

---

## Generalization Requirements

To make this public-ready, need to remove/generalize:

**From `/print_docs` command:**

**Must Change:**
- [ ] Hardcoded `.localdata/printing/` path → Make configurable or use standard location
- [ ] Project-specific categorization logic → Make generic or remove categories
- [ ] Hardcoded category names (Bot Diagnostics, Gameplay Packages, etc.)

**Should Improve:**
- [ ] Add dependency check (verify `npx`, `git`, `md-to-pdf` available)
- [ ] Better error messages when dependencies missing
- [ ] Installation guide for `md-to-pdf` npm package
- [ ] Support non-git repositories (fallback to filesystem scan)
- [ ] Make output directory configurable

**Nice to Have:**
- [ ] Config file support (`.claude-pdf.json` or similar)
- [ ] Multiple categorization strategies (by path depth, by folder, generic)
- [ ] Dry-run mode to preview what will be converted
- [ ] Custom PDF styling options

**Testing:**
- [ ] Test on Windows (primary platform based on .claude setup)
- [ ] Test in git repo vs non-git directory
- [ ] Test with missing dependencies (graceful failure)
- [ ] Test with different directory structures
- [ ] Test exclusion list functionality
- [ ] Test with files that have special characters in names
- [ ] Test with very large files

---

## Documentation Requirements

### User Documentation
- [ ] Clear installation instructions
- [ ] Dependency installation guide
- [ ] Usage examples
- [ ] Configuration guide
- [ ] Troubleshooting section

### Developer Documentation
- [ ] How the plugin works
- [ ] How to contribute
- [ ] Testing procedures
- [ ] Release process

---

## Open Questions

1. **Naming:**
   - Plugin name: `doc-printer`, `pdf-printer`, `claude-printer`?
   - Command name: `/print`, `/print_docs`, `/export_pdf`?

2. **Scope:**
   - Just PDF or multiple formats?
   - Just printing or also PDF manipulation?
   - Support for non-markdown sources?

3. **Dependencies:**
   - Require `pandoc` or use JavaScript library?
   - How to handle missing dependencies?
   - Platform-specific solutions?

4. **User Experience:**
   - Interactive prompts or config file?
   - Sensible defaults vs customization?
   - Error handling strategy?

5. **Output:**
   - Where to save PDFs by default?
   - Naming convention for files?
   - Overwrite or version control?

---

## Next Steps

1. **Analyze existing `/print_docs` command**
   - Read the actual implementation
   - Test its current functionality
   - Document what it does

2. **Make technical decisions**
   - Choose dependency approach
   - Decide on feature scope for MVP
   - Select naming conventions

3. **Create plugin structure**
   - Set up marketplace.json
   - Create plugin.json
   - Port/generalize command

4. **Test locally**
   - Install via local marketplace
   - Test on different scenarios
   - Verify it works outside personal setup

5. **Finalize and publish**
   - Update README with real info
   - Create release notes
   - Commit and push

---

## Success Criteria

**For MVP Release:**
- ✅ Works on clean installation (not just personal setup)
- ✅ Clear error messages for missing dependencies
- ✅ Documented installation process
- ✅ At least 3 usage examples in README
- ✅ Tested in at least 2 different directory structures
- ✅ No hardcoded personal paths

**For Community Adoption:**
- Clear value proposition
- Easy to install and use
- Well-documented
- Actively maintained
- Responsive to issues/PRs

# Eisvogel-TeX Nix Flake

> **Minimal Package Dependencies for the Eivogel LaTeX Template**

[![Nix Flake](https://img.shields.io/badge/nix-flake-blue)](https://nixos.org) [![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/sc2in/eisvogel-tex/badge)](https://flakehub.com/flake/sc2in/eisvogel-tex)

## What This Provides

This flake provides a reproducible Nix environment with:

- **Pandoc 3.x** — Universal document converter
- **TeX Live (minimal)** — Typesetting system with 23 packages curated for Eisvogel
- **Eisvogel template** — Professional LaTeX template for Pandoc (v3.3.0)
- **XeLaTeX engine** — For advanced font and Unicode support

All dependencies are pinned and isolated. **If it works on your machine, it works everywhere.**

## Quick Start

### One-Off Use (No Installation)

```bash
# Generate a PDF with your existing markdown
nix shell github:sc2in/eisvogel-tex -c \
  pandoc document.md -o document.pdf \
    --template eisvogel \
    --pdf-engine=xelatex \
    --listings
```

### Development Shell (Recommended)

```bash
# Clone or enter a project directory
nix develop

# Now available in your shell:
build-pdf document.md           # Generate PDF
watch-pdf document.md           # Auto-rebuild on changes
pandoc --version                # Verify tools
xelatex --version               # Check LaTeX engine
```

### Add to Existing Project

**In your `flake.nix`:**

```nix
{
  inputs = {
    eisvogel-tex.url = "https://flakehub.com/f/sc2in/eisvogel-tex/*";
  };

  outputs = { self, eisvogel-tex }: {
    devShells.default = eisvogel-tex.devShells.default;
  };
}
```

Then: `nix develop` to enter the environment.

## Example Document

**Create `document.md`:**

```markdown
---
title: "Professional Document"
author: "Your Name"
date: "2026-01-19"
titlepage: true
titlepage-color: "435488"
titlepage-text-color: "FFFFFF"
toc-own-page: true
listings-disable-line-numbers: false
---

# Introduction

This document is formatted with the Eisvogel template.

## Code Example

\```python
def hello():
    print("Hello from Eisvogel!")
\```

## Features

- Professional title pages
- Syntax-highlighted code blocks
- Automatic table of contents
- Customizable headers/footers

## Table Example

| Control ID | Status |
|------------|--------|
| SEC-001    | ✓ Pass |
| SEC-002    | ✓ Pass |
```

**Generate:**

```bash
build-pdf document.md
# or
pandoc document.md -o document.pdf --template eisvogel --listings --number-sections
```

## Common Tasks

### Single File Conversion

```bash
pandoc input.md -o output.pdf --template eisvogel --pdf-engine=xelatex --listings
```

### Batch Processing

```bash
for file in *.md; do
  pandoc "$file" -o "${file%.md}.pdf" \
    --template eisvogel \
    --pdf-engine=xelatex \
    --listings
done
```

### Watch & Rebuild (Auto-Compile)

```bash
watch-pdf document.md
# Rebuilds PDF whenever document.md changes
```

### Custom Fonts (XeLaTeX)

```bash
pandoc document.md -o output.pdf \
  --template eisvogel \
  --pdf-engine=xelatex \
  --variable mainfont="Source Sans Pro" \
  --variable monofont="Inconsolata" \
  --listings
```

### Continuous Integration (entr)

```bash
# Rebuild on any markdown change
ls *.md | entr build-pdf document.md
```

## Supported Systems

| System | Status |
|--------|--------|
| `x86_64-linux` | ✓ Tested |
| `aarch64-linux` | ✓ Tested |
| `x86_64-darwin` (Intel macOS) | ✓ Supported |
| `aarch64-darwin` (Apple Silicon) | ✓ Supported |

## What's Inside

### TeX Live Packages (23 total)

**Core:** `scheme-small`

**Required for Eisvogel:**

- Layout & styling: `adjustbox`, `framed`, `mdframed`, `pagecolor`, `titling`, `transparent`, `background`
- Fonts & encoding: `babel-german`, `xecjk`, `unicode-math`, `sourcecodepro`, `sourcesanspro`, `mweights`, `ly1`
- Code & listings: `fvextra`, `upquote`, `xurl`
- Utilities: `bidi`, `collectbox`, `csquotes`, `everypage`, `filehook`, `footmisc`, `footnotebackref`, `letltxmacro`, `needspace`, `svg`, `ucharcat`, `ulem`, `zref`, `pbox`
- Extras: `censor`, `soul`

### Checks

```bash
# Run validation
nix flake check

# Verifies:
# ✓ Pandoc installation
# ✓ Eisvogel template availability
# ✓ XeLaTeX engine
# ✓ PDF generation works
# ✓ PDF validity
```

## Troubleshooting

### Problem: "template not found"

**Cause:** Using a different Pandoc installation or missing template directory.

**Solution:**

```bash
# Use nix develop to ensure correct environment
nix develop
build-pdf document.md  # Uses bundled template

# Or explicitly specify template data dir:
pandoc document.md -o output.pdf \
  --template eisvogel \
  --pdf-engine=xelatex \
  --data-dir $(nix build .#eisvogel-template --print-out-paths)/share/pandoc \
  --listings
```

### Problem: "xelatex not found"

**Solution:** Ensure you're in the dev shell:

```bash
nix develop
xelatex --version  # Should work now
```

### Problem: PDF has missing fonts or characters

**Solution:** Use `xelatex` engine (default) and specify fonts:

```bash
pandoc document.md -o output.pdf \
  --template eisvogel \
  --pdf-engine=xelatex \
  --variable mainfont="DejaVu Sans" \
  --listings
```

## Configuration & Customization

### Modify TeX Live Packages

Edit `flake.nix` and adjust the `texliveEnv` package list:

```nix
texliveEnv = pkgs.texlive.combine {
  inherit (pkgs.texlive)
    scheme-small
    # Add/remove packages as needed
    tikz
    pgfplots
    ;
};
```

Then rebuild:

```bash
nix flake update
nix develop
```

### Customize Eisvogel Template

Copy the template to your project:

```bash
cp $(nix build .#eisvogel-template --print-out-paths)/share/pandoc/templates/eisvogel.latex ./
# Edit as needed
pandoc document.md -o output.pdf --template ./eisvogel.latex --listings
```

## Performance

- **First build:** ~2-3 minutes (downloads TeX Live)
- **Subsequent builds:** ~5-10 seconds per PDF
- **Incremental:** Only rebuilds when markdown or template changes

## Related Projects

- [**Eisvogel Template**](https://github.com/Wandmalfarbe/pandoc-latex-template) — Original template by Pascal Wagler
- [**Pandoc**](https://pandoc.org) — Universal document converter
- [**NixOS & Flakes Book**](https://github.com/ryan4yin/nixos-and-flakes-book) — Learn Nix
- [**Pandoc Templates**](https://pandoc-templates.org/) — More templates

## Dependencies & Licenses

| Component | License | Source |
|-----------|---------|--------|
| Flake configuration | MIT | This repository |
| Eisvogel template | BSD-3-Clause | [Wandmalfarbe](https://github.com/Wandmalfarbe/pandoc-latex-template) |
| Pandoc | GPL-2.0 | [jgm/pandoc](https://github.com/jgm/pandoc) |
| TeX Live | Various | [TeX Live](https://tug.org/texlive/) |

## Contributing

Contributions welcome! Areas for improvement:

- Minimizing TeX Live package count
- Adding CI/CD examples
- Platform-specific optimizations
- Documentation & examples

[Open an issue](https://github.com/sc2in/eisvogel-tex/issues) or submit a PR.

## Maintenance

**Maintained by:** [Star City Security Consulting, LLC](https://github.com/sc2in)

**Repository:** <https://github.com/sc2in/eisvogel-tex>  
**Issues:** <https://github.com/sc2in/eisvogel-tex/issues>  
**FlakeHub:** <https://flakehub.com/flake/sc2in/eisvogel-tex>

***

**Questions?** [Open an issue](https://github.com/sc2in/eisvogel-tex/issues) or [contact SC2](https://sc2in.in)

# Eisvogel-TeX Nix Flake

> **Minimal Package Dependencies for the Eivogel LaTeX Template**

[![Nix Flake](https://img.shields.io/badge/nix-flake-blue)](https://nixos.org)

## What This Provides

This flake bundles:

- Pandoc - Universal document converter
- LaTeX (TeXLive) - Typesetting system with all required packages
- **No esivogel template** - You will need to provide the eisvogel template itself.

## Quick Start

### One-Off Use

Generate a PDF without installing anything permanently:

```bash
nix shell github:sc2in/eisvogel-tex -c \
  pandoc document.md -o document.pdf --template eisvogel --listings --resource-path <Path_to_your_existing_esivogel_template>
```

### Add to an existing Project

In your `flake.nix`:

```nix
{
  inputs.eisvogel-tex.url = "github:sc2in/eisvogel-tex/develop";
  
  outputs = { self, nixpkgs, eisvogel-tex }: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      inputsFrom = [ eisvogel-tex.devShells.x86_64-linux.default ];
    };
  };
}
```

### Automatic Environment with Direnv

Create `.envrc`:

```bash
use flake github:sc2in/eisvogel-tex
```

Then `direnv allow`.

## Example Document

Create `document.md`:

```markdown
***
title: "My Professional Document"
author: "Your Name"
date: "2026-01-18"
titlepage: true
titlepage-color: "435488"
toc-own-page: true
***

# Introduction

This document will be beautifully formatted with the Eisvogel template.

## Code Example

\```python
def hello_world():
    print("Hello from Eisvogel!")
\```

## Features

- Professional title pages
- Syntax-highlighted code blocks
- Customizable headers and footers
- Table of contents
```

Generate PDF:

```bash
pandoc document.md -o document.pdf --template eisvogel --number-sections --listings --resource-path <Path_to_your_existing_esivogel_template>
```

### Continuous Compilation

```bash
ls *.md | entr nix shell github:sc2in/eisvogel-tex -c \
  pandoc document.md -o document.pdf --template eisvogel --listings --resource-path <Path_to_your_existing_esivogel_template>
```

### Batch Processing

```bash
for file in *.md; do
  nix shell github:sc2in/eisvogel-tex -c \
    pandoc "$file" -o "${file%.md}.pdf" --template eisvogel --listings --resource-path <Path_to_your_existing_esivogel_template>
done
```

### Custom Fonts

```bash
pandoc document.md -o document.pdf \
  --template eisvogel \
  --pdf-engine=xelatex \
  --variable mainfont="Source Sans Pro" \
  --variable monofont="Source Code Pro"
```

## Supported Systems

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin` (macOS Intel)
- `aarch64-darwin` (macOS Apple Silicon)

## Dependencies

All dependencies are managed automatically by nix:

- Pandoc 3.x
- All required LaTeX packages

## Contributing

Contributions welcome in the form of minimizing the size of this package further.

## Troubleshooting

**Problem:**

```log
Could not find data file /nix/store/[...]/pandoc-3.7.0.2/data/templates/eisvogel.latex
```

**Solution:**

Ensure the use of --resource-path. This package does not ship with eisvogel itself.

## Related Projects

- [Wandmalfarbe/pandoc-latex-template](https://github.com/Wandmalfarbe/pandoc-latex-template) - Original Eisvogel template
- [nixos-and-flakes-book](https://github.com/ryan4yin/nixos-and-flakes-book) - Learn Nix and Flakes
- [pandoc-templates](https://pandoc-templates.org/) - More Pandoc templates

## License

- **Flake configuration:** MIT
- **Eisvogel template:** BSD-3-Clause (from upstream)
- **Dependencies:** Various open-source licenses

## Acknowledgments

- [Pascal Wagler](https://github.com/Wandmalfarbe) - Creator of Eisvogel template
- [John MacFarlane](https://johnmacfarlane.net/) - Creator of Pandoc
- NixOS community for the Nix ecosystem

## Attribution

This flake includes the **Eisvogel LaTeX template** by Pascal Wagler  

- GitHub: <https://github.com/Wandmalfarbe/pandoc-latex-template>
- Also available: <https://github.com/enhuiz/eisvogel> (fork)
- License: BSD-3-Clause (see LICENSE.eisvogel)

## About

**Maintained by:** [Star City Security Consulting, LLC](https://github.com/sc2in)  
**Repository:** <https://github.com/sc2in/eisvogel-tex>  
**Issues:** <https://github.com/sc2in/eisvogel-tex/issues>

---

*Need professional support? [Contact SC2](https://sc2in.in)*

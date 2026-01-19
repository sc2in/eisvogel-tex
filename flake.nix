{
  description = "Eisvogel LaTeX template for Pandoc with TeX Live dependencies";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}: let
    # Metadata for the package
    meta = {
      description = "Eisvogel LaTeX template for Pandoc with minimal TeX Live";
      longDescription = ''
        A Nix flake providing the Eisvogel LaTeX template for Pandoc along with
        a minimal TeX Live environment containing only the required packages.

        Eisvogel is a clean, professional LaTeX template for Pandoc that produces
        beautifully formatted PDF documents with customizable title pages, syntax
        highlighting, and automatic table of contents.
      '';

      homepage = "https://github.com/sc2in/eisvogel-tex";
      repository = "https://github.com/sc2in/eisvogel-tex";
      license = "CC0-1.0";

      maintainers = [
        {
          name = "Star City Security Consulting, LLC";
          email = "inquiries@sc2.in";
          handle = "sc2in";
        }
      ];

      version = "3.3.0";

      # What this provides
      provides = {
        templates = [
          "eisvogel.latex"
          "eisvogel.beamer"
        ];
        texlivePackages = 23; # Count of TeX Live packages included
      };

      # Usage documentation
      usage = {
        basic = "nix flake show";
        develop = "nix develop";
        build = "nix build .#eisvogel-template";
        check = "nix flake check";
      };

      # System requirements
      requires = {
        pandoc = ">=3.0";
        xelatex = "present in TeX Live";
      };

      # Relevant standards/frameworks
      tags = [
        "latex"
        "pandoc"
        "documentation"
        "pdf"
        "template"
      ];
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} rec {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      flake = {
      };

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        outPath = "share/pandoc/templates/";
        # Download and install Eisvogel template
        eisvogelVersion = meta.version;
        eisvogelTemplate = pkgs.fetchurl {
          url = "https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download/v${eisvogelVersion}/Eisvogel-${eisvogelVersion}.tar.gz";
          sha256 = "128lc1vbxjq19zjmj6gm0kx6lcmf51xa4pxks22ahfp7k798gchf";
        };

        # Create a package that installs the template
        eisvogelInstalled =
          pkgs.runCommand "eisvogel-template" {
            inherit meta;
          } ''
            mkdir -p $out/${outPath}
            tar -xzf ${eisvogelTemplate} --strip-components=1
            # Copy both template variants
            cp "eisvogel.latex" $out/${outPath}
            cp "eisvogel.beamer" $out/${outPath}

            # Verify installation
            TEMPLATE_FILE=$(find $out -name "eisvogel.latex" -type f | head -n 1)
            if [ -f "$TEMPLATE_FILE" ]; then
              echo "✓ Eisvogel templates installed successfully"
            else
              echo "✗ Error: eisvogel.latex not found in archive"
              exit 1
            fi
          '';

        # TeX Live with required packages for Eisvogel
        texliveEnv = pkgs.texlive.combine {
          inherit
            (pkgs.texlive)
            scheme-small
            # keep-sorted start
            adjustbox
            babel-german
            background
            bidi
            collectbox
            csquotes
            everypage
            filehook
            footmisc
            footnotebackref
            framed
            fvextra
            letltxmacro
            ly1
            mdframed
            mweights
            needspace
            pagecolor
            sourcecodepro
            sourcesanspro
            titling
            transparent
            svg
            ucharcat
            ulem
            unicode-math
            upquote
            xecjk
            xurl
            zref
            pbox
            # keep-sorted end
            censor
            soul
            ;
        };

        # Sample markdown file
        sampleMarkdown = pkgs.writeText "sample.md" ''
          ---
          title: "Sample Document with Eisvogel Template"
          author: "Your Name"
          date: "2026-01-19"
          titlepage: true
          titlepage-color: "3C9F53"
          titlepage-text-color: "FFFFFF"
          titlepage-rule-color: "FFFFFF"
          toc: true
          toc-own-page: true
          listings-disable-line-numbers: false
          code-block-font-size: \scriptsize
          ---

          # Introduction

          This is a sample document generated using Pandoc with the Eisvogel LaTeX template.

          ## Features

          The Eisvogel template provides:

          - Professional-looking PDF output
          - Customizable title page
          - Syntax highlighting for code blocks
          - Table of contents support
          - Page headers and footers

          ## Code Example

          Here's a sample Nix expression:

          ```nix
          { lib, mkControl }:

          mkControl {
            name = "Sample Control";
            external_id = "SCF-SAMPLE-01";
            applicable = true;

            configToApply = {
              services.openssh.enable = true;
            };

            metadata = {
              description = "Example control implementation";
              owner = "security-team";
            };
          }
          ```

          ## Table Example

          | Control ID | Name | Status |
          |------------|------|--------|
          | END-01 | Endpoint Security | Implemented |
          | END-02 | CIA Protection | Implemented |
          | END-04 | Anti-Malware | Implemented |

          ## Conclusion

          This demonstrates the Eisvogel template working with Pandoc in a Nix environment.
        '';

        # Build the PDF
        buildPDF = pkgs.stdenvNoCC.mkDerivation {
          name = "sample-pdf";
          version = meta.version;
          dontUnpack = true;

          nativeBuildInputs = [
            pkgs.pandoc
            texliveEnv
          ];

          buildPhase = ''
            export PANDOC_DATA_DIR=${eisvogelInstalled}/${outPath}

            if [ ! -f "$PANDOC_DATA_DIR/eisvogel.latex" ]; then
              echo "✗ Error: Eisvogel template not found"
              exit 1
            fi

            echo "Building PDF with Eisvogel template..."

            pandoc ${sampleMarkdown} \
              --template eisvogel \
              --pdf-engine=xelatex \
              --listings \
              -o sample.pdf

            if [ ! -f sample.pdf ]; then
              echo "✗ PDF generation failed"
              exit 1
            fi

            echo "✓ PDF generated successfully"
          '';

          installPhase = ''
            mkdir -p $out
            cp sample.pdf $out/
          '';
        };

        # Validation check that ensures PDF can be built
        pdfCheck = pkgs.stdenvNoCC.mkDerivation {
          name = "pdf-generation-check";
          version = meta.version;
          dontBuild = false;
          dontUnpack = true;

          nativeBuildInputs = [
            pkgs.pandoc
            texliveEnv
            pkgs.file
          ];

          buildPhase = ''
            export PANDOC_DATA_DIR=${eisvogelInstalled}/share/pandoc

            echo "==================================="
            echo "Eisvogel Template Validation"
            echo "==================================="
            echo ""

            # Check 1: Pandoc
            echo "✓ Pandoc: $(pandoc --version | head -n 1)"

            # Check 2: Template
            if [ ! -f "$PANDOC_DATA_DIR/templates/eisvogel.latex" ]; then
              echo "✗ Template not found"
              exit 1
            fi
            echo "✓ Template: Eisvogel ${meta.version}"

            # Check 3: XeLaTeX
            echo "✓ XeLaTeX: $(xelatex --version | head -n 1)"

            # Check 4: Build sample
            echo ""
            echo "Building sample PDF..."
            pandoc ${sampleMarkdown} \
              --template eisvogel \
              --pdf-engine=xelatex \
              --listings \
              --data-dir=$PANDOC_DATA_DIR \
              -o test-output.pdf 2>&1 | grep -v "^$" || true

            if [ ! -f test-output.pdf ]; then
              echo "✗ PDF generation failed"
              exit 1
            fi

            # Check 5: Verify
            if ! file test-output.pdf | grep -q "PDF document"; then
              echo "✗ Invalid PDF generated"
              exit 1
            fi

            pdf_size=$(stat -c"%s" test-output.pdf 2>/dev/null || stat -f%z test-output.pdf 2>/dev/null || echo "0")
            if [ "$pdf_size" -lt 1000 ]; then
              echo "✗ PDF too small ($${pdf_size} bytes)"
              exit 1
            fi

            echo "✓ PDF valid ($${pdf_size} bytes)"
            echo ""
            echo "==================================="
            echo "All checks passed! ✓"
            echo "==================================="

            touch $out
          '';
        };
      in {
        packages = {
          default = texliveEnv;
          eisvogel-template = eisvogelInstalled;
          pdf = buildPDF;
          texlive = texliveEnv;
        };

        checks = {
          pdf-generation = pdfCheck;
        };

        devShells.default = pkgs.mkShell {
          name = "eisvogel-env";

          buildInputs = [
            pkgs.pandoc
            texliveEnv
            eisvogelInstalled
            pkgs.watchexec
            pkgs.librsvg # for SVG support
          ];

          shellHook = ''
            mkdir -p .pandoc/templates
            cp ${eisvogelInstalled}/${outPath}/eisvogel.latex .pandoc/templates/

            cat << 'EOF'
            ╔════════════════════════════════════════╗
            ║  Eisvogel Template Environment        ║
            ║  Version: ${meta.version}                    ║
            ╚════════════════════════════════════════╝

            Quick start:
              build-pdf <file.md>      Generate PDF from markdown
              watch-pdf <file.md>      Auto-rebuild on changes

            Reference:
              pandoc --version         Check Pandoc version
              xelatex --version        Check XeLaTeX version

            Template: .pandoc/templates/eisvogel.latex
            EOF

            build-pdf() {
              if [ -z "$1" ]; then
                echo "Usage: build-pdf <input.md> [output.pdf]"
                return 1
              fi
              local input="$1"
              local output="''${2:-''${input%.md}.pdf}"
              pandoc "$input" \
                --template eisvogel \
                --pdf-engine=xelatex \
                --data-dir=.pandoc \
                --listings \
                -o "$output" && echo "✓ Generated: $output" || echo "✗ Failed"
            }

            watch-pdf() {
              if [ -z "$1" ]; then
                echo "Usage: watch-pdf <input.md>"
                return 1
              fi
              watchexec -w "$1" "build-pdf $1"
            }

            export -f build-pdf watch-pdf
          '';
        };

        apps.default = {
          type = "app";
          inherit meta;
          program = "${pkgs.writeShellScript "view-pdf" ''
            set -e
            PDF="${buildPDF}/sample.pdf"
            [ -f "$PDF" ] || { echo "✗ PDF not found"; exit 1; }
            if command -v xdg-open &>/dev/null; then
              xdg-open "$PDF"
            elif command -v open &>/dev/null; then
              open "$PDF"
            else
              echo "PDF at: $PDF"
            fi
          ''}";
        };
      };
    };
}

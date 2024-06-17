{
  description = "Needed texlive packages for the Eisvogel template";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = {
        default = pkgs.texlive.combine {
          inherit
            (pkgs.texlive)
            # Required for pandoc's default template eisvogel
            
            scheme-small # main scheme to use, https://nixos.wiki/wiki/TexLive#Installation
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
            ucharcat
            ulem
            unicode-math
            upquote
            xecjk
            xurl
            zref
            pbox
            # additional packages for our custom template with redaction
            
            censor
            soul
            ;
        };
      };
    });
}

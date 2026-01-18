# Use as a flake

[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/sc2in/eisvogel-tex/badge)](https://flakehub.com/flake/sc2in/eisvogel-tex)

This is a package containing all LaTeX packages needed for the [eisvogel](https://github.com/enhuiz/eisvogel) template.

Add `eisvogel-tex` to your `flake.nix`:
 
```nix
{
  inputs.eisvogel-tex.url = "https://flakehub.com/f/sc2in/eisvogel-tex/*";
 
  outputs = { self, eisvogel-tex }: {
    # Use in your outputs
  };
}
```
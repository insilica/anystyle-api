{
  description = "anystyle api";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      with import nixpkgs { inherit system; };
      let
        gems = bundlerEnv {
          name = "anystyle-api-env";
          inherit ruby;
          gemdir = ./.;
        };
        anystyle-api = stdenv.mkDerivation {
          name = "anystyle-api";
          src = ./.;
          buildInputs = [ gems ruby ];
          installPhase = ''
            mkdir -p $out/{bin,share/anystyle-api}
            cp -r * $out/share/anystyle-api
            bin=$out/bin/anystyle-api
            # we are using bundle exec to start in the bundled environment
            cat > $bin <<EOF
            #!/bin/sh -e
            exec ${gems}/bin/bundle exec ${ruby}/bin/ruby $out/share/anystyle-api/main.rb "\$@"
            EOF
            chmod +x $bin
          '';
        };
        default = anystyle-api;
      in {
        packages = { inherit anystyle-api default; };
        devShells.default = mkShell { buildInputs = [ bundix ruby ]; };
      });
}

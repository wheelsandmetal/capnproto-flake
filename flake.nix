{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-20.09";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = nixpkgs.legacyPackages.${system};

      buildInputs = with pkgs; [
        autoconf
        automake
        libtool
      ];

    in {
      devShell = pkgs.mkShell {
        buildInputs = buildInputs;
      };

      defaultPackage = with pkgs; stdenv.mkDerivation {
        name = "capnproto";
        src = fetchFromGitHub {
          owner = "capnproto";
          repo = "capnproto";
          rev = "v0.7.0";
          sha256 = "sha256-Y/7dUOQPDHjniuKNRw3j8dG1NI9f/aRWpf8V0WzV9k8=";
        };
        buildInputs = buildInputs;
        buildPhase = ''
          cd c++
          autoreconf -i
          ./configure
          make -j8
          mkdir -p $out
          DESTDIR=$out make install
        '';
        installPhase = ''
          mv $out/usr/local/* $out
          rm -r $out/usr
        '';
      };
    }
  );
}

{
  description = "Build Typst documents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      fontsConf = pkgs.makeFontsConf {
        fontDirectories = with pkgs; [
          liberation_ttf
          fira
          fira-code
          dejavu_fonts
        ];
      };
    in
    {
      packages.x86_64-linux.default =
        pkgs.stdenv.mkDerivation {
          pname = "plm-reports";
          version = "0.1.0";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            typst
          ];

          buildInputs = with pkgs; [
            liberation_ttf
            fira
            fira-code
            fontconfig
            dejavu_fonts
          ];

          buildPhase = ''
            export FONTCONFIG_FILE=${fontsConf}
            export HOME=$(mktemp -d)

            fc-cache -fv

            typst compile let01/let01.typ let01.pdf
            typst compile let03/let03.typ let03.pdf
            typst compile lab01/lab01.typ lab01.pdf
            typst compile lab02/lab02.typ lab02.pdf
          '';

          installPhase = ''
            mkdir -p $out
            mv let01.pdf let03.pdf lab01.pdf lab02.pdf $out/
          '';
        };

      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          typst
          liberation_ttf
          fira
          fira-code
        ];

        shellHook = ''
          export FONTCONFIG_FILE="${fontsConf}"
        '';
      };
    };
}

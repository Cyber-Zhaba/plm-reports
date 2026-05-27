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
            typst compile let04/let04.typ let04.pdf
            typst compile let05/let05.typ let05.pdf
            typst compile let06/let06.typ let06.pdf
            typst compile let07/let07.typ let07.pdf
            typst compile let08/let08.typ let08.pdf
            typst compile let09/let09.typ let09.pdf
            typst compile let10/let10.typ let10.pdf
            typst compile lab01/lab01.typ lab01.pdf
            typst compile lab02/lab02.typ lab02.pdf
            typst compile lab03/lab03.typ lab03.pdf
            typst compile lab04/lab04.typ lab04.pdf
typst compile lab05/lab05.typ lab05.pdf
            typst compile lab06/lab06.typ lab06.pdf
            typst compile lab07/lab07.typ lab07.pdf
            typst compile lab08/lab08.typ lab08.pdf
            typst compile lab09/lab09.typ lab09.pdf
            typst compile lab10/lab10.typ lab10.pdf
            typst compile lab11/lab11.typ lab11.pdf
            typst compile lab12/lab12.typ lab12.pdf
          '';

          installPhase = ''
            mkdir -p $out
            mv let01.pdf let03.pdf let04.pdf let05.pdf let06.pdf let07.pdf let08.pdf let09.pdf let10.pdf lab01.pdf lab02.pdf lab03.pdf lab04.pdf lab05.pdf lab06.pdf lab07.pdf lab08.pdf lab09.pdf lab10.pdf lab11.pdf lab12.pdf $out/
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

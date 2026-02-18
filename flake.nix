{
  description = "Build Typst documents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { 
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
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
            corefonts
          ];

          buildPhase = ''
            export HOME=$TMPDIR
            
            mkdir -p $HOME/.fonts
            cp -r ${pkgs.liberation_ttf}/share/fonts/truetype/* $HOME/.fonts/ 2>/dev/null || true
            cp -r ${pkgs.fira}/share/fonts/truetype/* $HOME/.fonts/ 2>/dev/null || true
            cp -r ${pkgs.fira}/share/fonts/otf/* $HOME/.fonts/ 2>/dev/null || true
            cp -r ${pkgs.fira-code}/share/fonts/* $HOME/.fonts/ 2>/dev/null || true
            cp -r ${pkgs.dejavu_fonts}/share/fonts/* $HOME/.fonts/ 2>/dev/null || true
            cp -r ${pkgs.corefonts}/share/fonts/truetype/* $HOME/.fonts/ 2>/dev/null || true

            fc-cache -f $HOME/.fonts

            export FONTCONFIG_FILE=$HOME/fonts.conf
            cat > $HOME/fonts.conf << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir prefix="cwd">.fonts</dir>
  <dir>$HOME/.fonts</dir>
  <dir>${pkgs.liberation_ttf}/share/fonts/truetype</dir>
  <dir>${pkgs.fira}/share/fonts/truetype</dir>
  <dir>${pkgs.fira-code}/share/fonts</dir>
  <dir>${pkgs.dejavu_fonts}/share/fonts/truetype</dir>
  <dir>${pkgs.corefonts}/share/fonts/truetype</dir>
</fontconfig>
EOF
            
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

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            typst
            liberation_ttf
            fira
            fira-code
            corefonts
          ];
        };
      }
    );
}

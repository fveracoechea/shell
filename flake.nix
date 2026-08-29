{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell?ref=refs/tags/v0.3.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    quickshell,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (import systems);
  in {
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
        qs = quickshell.packages.${system}.default;
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            qs
            qt6.qtdeclarative
            material-symbols
            typescript
            just
            bash
            git
            coreutils
            findutils
            diffutils
            gnugrep
          ];
          shellHook = ''
            export QML_IMPORT_PATH="${qs}/lib/qt-6/qml:${qs}/bin:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
          '';
        };
      }
    );
  };
}

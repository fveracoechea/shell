{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell?ref=refs/tags/v0.3.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell-mcp = {
      url = "github:franklinnolasco7/quickshell-mcp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    quickshell,
    quickshell-mcp,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (import systems);
  in {
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
        qs = quickshell.packages.${system}.default;
        qsMcp = quickshell-mcp.packages.${system}.default;
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            qs
            qsMcp
            qt6.qtdeclarative
            material-symbols
            inter
            jetbrains-mono
            typescript
            just
            bash
            git
            coreutils
            findutils
            diffutils
            gnugrep
            shellcheck
            actionlint
          ];
          shellHook = ''
            export QML_IMPORT_PATH="${qs}/lib/qt-6/qml:${qs}/bin:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
          '';
        };
      }
    );
  };
}

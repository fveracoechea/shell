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
      in {
        default = let
          qs = quickshell.packages.${system}.default;
        in
          pkgs.mkShell {
            packages = [
              qs
              pkgs.qt6.qtdeclarative
            ];
            shellHook = ''
              export QML_IMPORT_PATH="${qs}/lib/qt-6/qml:${qs}/bin:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
            '';
          };
      }
    );
  };
}

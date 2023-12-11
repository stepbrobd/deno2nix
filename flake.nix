{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }: flake-utils.lib.eachDefaultSystem
      (system:
      let
        inherit (pkgs) deno2nix;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
          ];
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ deno ];
        };
      }) // {
      overlays.default = final: prev: {
        deno2nix = {
          internal = final.callPackage ./lib/internal { };
          mkBundled = final.callPackage ./lib/mk-bundled.nix { };
          mkBundledWrapper = final.callPackage ./lib/mk-bundled-wrapper.nix { };
          mkExecutable = final.callPackage ./lib/mk-executable.nix { };
        };
      };
    };
}

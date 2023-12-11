{ pkgs, ... }: {
  findImportMap = pkgs.callPackage ./find-import-map.nix { };

  mkDepsArtifactPath = pkgs.callPackage ./mk-deps-artifact-path.nix { };
  mkDepsUrlPart = pkgs.callPackage ./mk-deps-url-part.nix { };
  mkDepsLink = pkgs.callPackage ./mk-deps-link.nix { };

  mkNpmEntry = pkgs.callPackage ./mk-npm-entry.nix { };
  mkNpmLink = pkgs.callPackage ./mk-npm-link.nix { };
}

{ lib
, fetchurl
, linkFarm
, writeText
, deno
, deno2nix
, ...
}:
let
  inherit (builtins) split elemAt toJSON hashString baseNameOf;
  inherit (lib) flatten mapAttrsToList importJSON;
  inherit (lib.strings) sanitizeDerivationName;
  inherit (deno2nix.internal) mkDepsArtifactPath;
in
lockfile: (
  linkFarm "deps" (flatten (
    mapAttrsToList
      (
        url: sha256:
        [
          {
            name = mkDepsArtifactPath url;
            path = fetchurl {
              inherit url sha256;
              name = sanitizeDerivationName (baseNameOf url);
              curlOptsList = [ "--user-agent" "Deno/${deno.version}" ];
            };
          }
          {
            name = mkDepsArtifactPath url + ".metadata.json";
            path = writeText "metadata.json" (toJSON {
              inherit url;
              headers = { };
            });
          }
        ]
      )
      (importJSON lockfile).remote
  ))
)

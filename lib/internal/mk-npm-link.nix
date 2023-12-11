{ lib
, linkFarm
, runCommand
, fetchurl
, writeText
, gnutar
, deno2nix
}:

lockfile:
let
  ctx = (lib.importJSON lockfile).packages.npm;
in
(
  linkFarm "npm" (lib.flatten (
    lib.mapAttrsToList
      (
        name: attrs:
        let
          p = deno2nix.internal.mkNpmEntry ctx name;
        in
        [
          {
            name = p.path + "/registry.json";
            path = writeText "registry.json" (builtins.toJSON {
              inherit (p) name versions;
              dist-tags.latest = p.latest;
            });
          }
          {
            name = p.path + "/${p.version}";
            path = runCommand (lib.strings.sanitizeDerivationName name)
              {
                src = fetchurl {
                  inherit (p) url;
                  hash = attrs.integrity;
                };
                nativeBuildInputs = [ gnutar ];
              } ''
              mkdir - p $out
              tar -xzf $src --strip-components=1 -C $out
            '';
          }

        ]
      )
      ctx
  ))
)

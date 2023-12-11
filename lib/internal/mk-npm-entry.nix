{ lib
, ...
}:
# input: @alloc/quick-lru@5.2.0
# output: registry.npmjs.org/@alloc/quick-lru
# or
# input: chokidar@3.5.3
# output: registry.npmjs.org/chokidar
# or
# input: postcss-colormin@6.0.0_postcss@8.4.31
# output: registry.npmjs.org/postcss-colormin
ctx: name:
let
  mkParts = n: lib.splitString "@" n;
  mkName = n:
    if lib.head (mkParts n) == ""
    then "@${lib.elemAt (mkParts n) 1}"
    else lib.head (mkParts n);
  mkVersion = n: lib.head (lib.splitString "_" (
    if lib.head (mkParts n) == ""
    then lib.elemAt (mkParts n) 2
    else lib.elemAt (mkParts n) 1
  ));
  mkTarball = n: v: "https://registry.npmjs.org/${n}/-/${
    if lib.hasPrefix "@" n
    then lib.last (lib.splitString "/" (lib.removePrefix "@" n))
    else n
    }-${v}.tgz";
  allVersions = lib.listToAttrs (lib.remove null (lib.forEach (builtins.attrNames ctx) (n:
    if (mkName name) == (mkName n)
    then { name = mkVersion n; value = n; }
    else null
  )));
in
{
  name = mkName name;
  url = mkTarball (mkName name) (mkVersion name);
  version = mkVersion name;
  latest = lib.last (lib.naturalSort (lib.attrNames allVersions));
  path = "registry.npmjs.org/${mkName name}";
  versions = lib.genAttrs (lib.attrNames allVersions) (v: {
    version = v;
    dist = {
      tarball = mkTarball (mkName name) v;
      integrity = ctx."${allVersions."${v}"}".integrity;
      shasum = ""; # does not affect compilation but must be present
    };
  });
}

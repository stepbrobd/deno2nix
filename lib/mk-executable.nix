{ pkgs
, lib
, stdenvNoCC
, deno2nix
, ...
}: { pname
   , version
   , src
   , bin ? pname
   , entrypoint
   , lockfile
   , config
   , allow ? { }
   , additionalDenoFlags ? ""
   ,
   } @ inputs:
let
  inherit (builtins) isString;
  inherit (lib) importJSON concatStringsSep;
  inherit (deno2nix.internal) findImportMap mkDepsLink mkNpmLink;

  allowflag = flag: (
    if (allow ? flag) && allow."${flag}"
    then [ "--allow-${flag}" ]
    else [ ]
  );

  importMap = findImportMap {
    inherit (inputs) src config importMap;
  };

  compileCmd = concatStringsSep " " (
    [
      "deno compile --cached-only"
      "--lock=${lockfile}"
      "--output=${bin}"
      # "--config=${config}"
    ]
    ++ (
      if (isString importMap)
      then [ "--import-map=${importMap}" ]
      else [ ]
    )
    ++ (allowflag "all")
    ++ (allowflag "env")
    ++ (allowflag "ffi")
    ++ (allowflag "hrtime")
    ++ (allowflag "net")
    ++ (allowflag "read")
    ++ (allowflag "run")
    ++ (allowflag "sys")
    ++ (allowflag "write")
    ++ [ additionalDenoFlags ]
    ++ [ "${entrypoint}" ]
  );
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = with pkgs; [ deno jq ];

  buildPhase = ''
    export DENO_DIR="$(mktemp -d)"
    ln -s "${mkDepsLink (src + "/${lockfile}")}" $(deno info --json | jq -r .modulesCache)
    ln -s "${mkNpmLink (src + "/${lockfile}")}" $(deno info --json | jq -r .npmCache)
    ${compileCmd}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp "${bin}" "$out/bin/"
  '';
}

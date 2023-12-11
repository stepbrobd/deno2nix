{ lib, ... }:

{ src
, config
, importMap
}:

let
  cfg = lib.importJSON (src + "/${config}");
in
(
  if builtins.hasAttr "importMap" cfg
  then cfg.importMap
  else config
)

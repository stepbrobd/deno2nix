{ lib
, deno2nix
, ...
}:
let
  inherit (builtins) hashString;
  inherit (deno2nix.internal) mkDepsUrlPart;
in
# input: https://deno.land/std@0.118.0/fmt/colors.ts
  #
  # output: https/deno.land/<sha256 "/std@0.118.0/fmt/colors.ts">
url:
let
  up = mkDepsUrlPart url;
in
"${up 0}/${up 1}/${hashString "sha256" (up 2)}"

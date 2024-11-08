{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  commands = mkOption {
    type = types.listOf types.str;
    description = "List of command to execute when this vote is voted.";
  };
}

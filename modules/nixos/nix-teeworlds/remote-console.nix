{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  rconBanTime = mkOption {
    type = types.int;
    default = 5;
    description = "The time a client gets banned if remote console authentication fails. 0 makes it just use kick.";
  };

  rconMaxTries = mkOption {
    type = types.int;
    default = 3;
    description = "Maximum number of tries for remote console authentication.";
  };

  rconModPassword = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Remote console password for moderators (limited access).";
  };

  rconPassword = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Password to access the remote console (if not set, rcon is disabled).";
  };
}

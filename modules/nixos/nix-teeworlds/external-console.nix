{ lib, ... }:
let
  inherit (lib) types mkOption mkEnableOption;
in
{
  enable = mkEnableOption "Enable the external console.";

  bindAddr = mkOption {
    type = types.str;
    default = "localhost";
    description = "Address to bind the external console to. Anything but 'localhost' is dangerous!";
  };

  port = mkOption {
    type = types.int;
    default = 1234;
    description = "Port to use for the external console.";
  };

  password = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "External console password.";
  };

  banTime = mkOption {
    type = types.int;
    default = 0;
    description = "The time a client gets banned if econ authentication fails. 0 just closes the connection.";
  };

  authTimeout = mkOption {
    type = types.int;
    default = 30;
    description = "Time in seconds before the the econ authentication times out.";
  };

  outputLevel = mkOption {
    type = types.int;
    default = 1;
    description = "Adjusts the amount of information in the external console.";
  };
}

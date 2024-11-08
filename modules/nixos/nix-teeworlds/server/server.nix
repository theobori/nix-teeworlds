{
  pkgs,
  lib,
  cfg,
  mkSubmoduleFile,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkPackageOption
    ;

  mkSubmodule' =
    isAttrsOf: path: description:
    let
      type = if isAttrsOf then (types.attrsOf (mkSubmoduleFile path)) else (mkSubmoduleFile path);
    in
    mkOption {
      default = { };
      inherit type description;
    };

  mkSubmodule = path: description: mkSubmodule' false path description;
  mkAttrsSubmodule = path: description: mkSubmodule' true path description;
in
{
  enable = mkEnableOption "Enable this Teeworlds server.";
  package = mkPackageOption pkgs "teeworlds-server" { };

  binaryName = mkOption {
    type = types.nullOr types.str;
    default = null;
  };

  dataDir = mkOption {
    type = types.nullOr (
      types.oneOf [
        types.path
        types.package
        types.str
      ]
    );
    default = null;
  };

  openFirewall = mkOption {
    type = types.bool;
    default = cfg.openFirewall;
    description = ''
      Whether to open ports in the firewall for this server.
    '';
  };

  quickConfig = mkOption {
    type = types.lines;
    default = "";
    description = ''
      Custom configuration to use instead of the basics one.
    '';
  };

  useQuickConfig = mkEnableOption "Enable quick configuration.";

  extraConfig = mkOption {
    type = types.nullOr types.lines;
    default = null;
  };

  enableService = mkOption {
    type = types.bool;
    default = true;
    description = "Whether to enable this server systemd service unit.";
  };

  cfgName = mkOption {
    type = types.str;
    default = "server.cfg";
    description = "Server configuration file name.";
  };

  # Submodules
  settings = mkSubmodule ./settings.nix "Settings configuration.";
  game = mkSubmodule ./game.nix "Game configuration.";
  externalConsole = mkSubmodule ./external-console.nix "External console configuration.";
  remoteConsole = mkSubmodule ./remote-console.nix "Remote console console configuration.";
  votes = mkAttrsSubmodule ./vote.nix "Server votes configuration.";
}

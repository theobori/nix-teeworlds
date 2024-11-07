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
    type = types.oneOf [
      types.path
      types.package
      types.str
    ];
    default = "${pkgs.teeworlds-server}/share/teeworlds/data";
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

  register = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Whether to register this server on the masters servers.
    '';
  };

  bindAddress = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Address to bind.";
  };

  password = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Password to connect to the server.";
  };

  externalPort = mkOption {
    type = types.int;
    default = 0;
    description = "Port to report to the master servers (e.g. in case of a firewall rename).";
  };

  highBandwidth = mkOption {
    type = types.bool;
    default = false;
    description = "Use high bandwidth mode. Doubles the bandwidth required for the server. LAN use only.";
  };

  hostname = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Server hostname.";
  };

  inactiveKick = mkOption {
    type = types.enum [
      1
      2
      3
    ];
    default = 2;
    description = "How to deal with inactive clients (1=move player to spectator, 2=move to free spectator slot/kick, 3=kick).";
  };

  inactiveKickSpec = mkOption {
    type = types.bool;
    default = false;
    description = "Kick inactive spectators.";
  };

  inactiveKickTime = mkOption {
    type = types.int;
    default = 3;
    description = "How many minutes to wait before taking care of inactive clients.";
  };

  mapDownloadSpeed = mkOption {
    type = types.int;
    default = 8;
    description = "Number of map data packages a client gets on each request.";
  };

  maxClients = mkOption {
    type = types.int;
    default = 12;
    description = "Number of clients that can be connected to the server at the same time.";
  };

  maxClientsPerIp = mkOption {
    type = types.int;
    default = 4;
    description = "Maximum number of clients with the same IP that can connect to the server.";
  };

  motd = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Message of the day, shown in server info and when joining a server.";
  };

  name = mkOption {
    type = types.str;
    default = "unnamed server";
    description = "Name of the server.";
  };

  port = mkOption {
    type = types.int;
    default = 8303;
    description = "Port the server will listen on.";
  };

  enableSpamProtection = mkOption {
    type = types.bool;
    default = true;
    description = "Whether to enable chat spam protection.";
  };

  # Submodules
  game = mkSubmodule ./game.nix "Game configuration.";
  externalConsole = mkSubmodule ./external-console.nix "External console configuration.";
  remoteConsole = mkSubmodule ./remote-console.nix "Remote console console configuration.";
  votes = mkAttrsSubmodule ./vote.nix "Server votes configuration.";

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
}

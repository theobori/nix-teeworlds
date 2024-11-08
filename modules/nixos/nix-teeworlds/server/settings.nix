{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
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
}

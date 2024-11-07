{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkPackageOption
    types
    mkOption
    filterAttrs
    mapAttrsToList
    optional
    unique
    mapAttrs
    optionalString
    getExe
    getExe'
    isInt
    ;

  cfg = config.services.nix-teeworlds;

  optionalSetting = c: v: lib.optionalString (v != null) "${c} ${v}";

  bool = b: if b != null && b then "1" else "0";

  externalConsole = types.submodule {
    options = {
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
    };
  };

  remoteConsole = types.submodule {
    options = {
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
    };
  };

  game = types.submodule {
    options = {
      gameType = mkOption {
        type = types.str;
        default = "dm";
        description = "Game type (This setting needs the map to be reloaded in order to take effect).";
      };

      map = mkOption {
        type = types.str;
        default = "dm1";
        description = "Map to use on the server.";
      };

      mapRotation = mkOption {
        type = types.str;
        default = "";
        description = "Maps to rotate between.";
      };

      matchSwap = mkOption {
        type = types.bool;
        default = true;
        description = "Swap teams between matches.";
      };

      matchesPerMap = mkOption {
        type = types.int;
        default = 1;
        description = "Number of matches on each map before rotating.";
      };

      playerReadyMode = mkOption {
        type = types.bool;
        default = false;
        description = "When enabled, players can pause/unpause the game and start the game on warmup via their ready state.";
      };

      playerSlots = mkOption {
        type = types.int;
        default = 8;
        description = "Number of slots to reserve for players.";
      };

      powerups = mkOption {
        type = types.bool;
        default = true;
        description = "Allow powerups like ninja.";
      };

      countdown = mkOption {
        type = types.int;
        default = 0;
        description = "Number of seconds to freeze the game in a countdown before match starts (0 enables only for survival gamemodes, -1 disables).";
      };

      respawnDelayTDM = mkOption {
        type = types.int;
        default = 3;
        description = "Time needed to respawn after death in tdm gametype.";
      };

      scoreLimit = mkOption {
        type = types.int;
        default = 20;
        description = "Score limit of the game (0 disables it).";
      };

      strictSpectateMode = mkOption {
        type = types.bool;
        default = false;
        description = "Restricts information like health, ammo and armour in spectator mode.";
      };

      teambalanceTime = mkOption {
        type = types.int;
        default = 1;
        description = "How many minutes to wait before autobalancing teams.";
      };

      teamDamage = mkOption {
        type = types.bool;
        default = false;
        description = "Team damage.";
      };

      timeLimit = mkOption {
        type = types.int;
        default = 0;
        description = "Time limit of the game (in case of equal points there will be sudden death) (0 disables).";
      };

      tournamentMode = mkOption {
        type = types.int;
        default = 0;
        description = "Tournament mode. When enabled, players joins the server as spectator (2=additional restricted spectator chat).";
      };

      voteSpectate = mkOption {
        type = types.bool;
        default = true;
        description = "Allow voting to move players to spectators.";
      };

      voteSpectateRejoinDelay = mkOption {
        type = types.int;
        default = 3;
        description = "How many minutes to wait before a player can rejoin after being moved to spectators by vote.";
      };

      warmup = mkOption {
        type = types.int;
        default = 0;
        description = "Number of seconds to do warmup before match starts (0 disables, -1 all players ready).";
      };
    };
  };

  server = types.submodule (
    { name, ... }:
    {
      options = {
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
          default = 12;
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

        game = mkOption {
          type = game;
          default = { };
          description = "Game configuration.";
        };

        externalConsole = mkOption {
          type = externalConsole;
          default = { };
          description = "External console configuration.";
        };

        remoteConsole = mkOption {
          type = remoteConsole;
          default = { };
          description = "Remote console console configuration.";
        };

        extraConfig = mkOption {
          type = types.nullOr types.lines;
          default = null;
        };

        enableService = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable this server systemd service unit.";
        };
      };
    }
  );
in
{
  options.services.nix-teeworlds = {
    enable = mkEnableOption "Enable nix-teeworlds servers.";

    rootDir = mkOption {
      type = types.str;
      default = "/srv/nix-teeworlds";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open ports for each server.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "nix-teeworlds";
    };

    group = mkOption {
      type = types.str;
      default = "nix-teeworlds";
    };

    servers = mkOption { type = types.attrsOf server; };
  };

  config =
    let
      servers = filterAttrs (_: server: server.enable) cfg.servers;

      mkPorts =
        c: f:
        builtins.concatLists (
          mapAttrsToList (
            _: server:
            let
              ret = f server;
            in
            optional ((isInt ret) && (server.openFirewall or c)) ret
          ) servers
        );

      # TCP ports
      mkTCPPorts =
        c:
        mkPorts c (
          server:
          (optional (server.externalPort != 0) server.externalPort)
          ++ (optional (
            server.externalConsole != null && server.externalConsole.enable
          ) server.externalConsole.port)
        );
      # UDP ports
      mkUDPPorts = c: mkPorts c (server: server.port);
      # All port
      ports = (mkTCPPorts true) ++ (mkUDPPorts true);
    in
    mkIf cfg.enable {
      users = {
        users = {
          ${cfg.user} = {
            description = "${cfg.user} server service user";
            home = cfg.rootDir;
            createHome = true;
            homeMode = "770";
            isSystemUser = true;
            inherit (cfg) group;
          };
        };
        groups.${cfg.group} = { };
      };

      assertions = [
        {
          assertion = ports == (unique ports);
          message = "${ports} ${toString (unique ports)} You have duplicates ports. Make sure all of your servers have a different port.";
        }
      ];

      systemd.tmpfiles.rules = mapAttrsToList (
        name: _: "d '${cfg.rootDir}/${name}' 0770 ${cfg.user} ${cfg.group} - -"
      ) servers;

      # Systemd service units
      systemd.services = mapAttrs (
        name: server:
        let
          serverConfig = pkgs.writeText "autoexec.cfg" ''
            # Server settings
            sv_port ${toString server.port}
            sv_register ${bool server.register}
            sv_name ${server.name}
            ${optionalSetting "sv_motd" server.motd}
            ${optionalSetting "password" server.password}
            ${optionalSetting "sv_rcon_password" server.remoteConsole.rconPassword}

            ${optionalSetting "bindaddr" server.bindAddress}
            ${optionalSetting "sv_hostname" server.hostname}
            sv_high_bandwidth ${bool server.highBandwidth}
            sv_inactivekick ${toString server.inactiveKick}
            sv_inactivekick_spec ${bool server.inactiveKickSpec}
            sv_inactivekick_time ${toString server.inactiveKickTime}
            sv_max_clients ${toString server.maxClients}
            sv_max_clients_per_ip ${toString server.maxClientsPerIp}
            sv_spamprotection ${bool server.enableSpamProtection}

            # Game settings
            sv_gametype ${server.game.gameType}
            sv_map ${server.game.map}
            sv_maprotation ${server.game.mapRotation}
            sv_matches_per_map ${toString server.game.matchesPerMap}
            sv_match_swap ${bool server.game.matchSwap}
            sv_player_ready_mode ${bool server.game.playerReadyMode}
            sv_player_slots ${toString server.game.playerSlots}
            sv_powerups ${bool server.game.powerups}
            sv_countdown ${toString server.game.countdown}
            sv_respawn_delay_tdm ${toString server.game.respawnDelayTDM}
            sv_scorelimit ${toString server.game.scoreLimit}
            sv_strict_spectate_mode ${bool server.game.strictSpectateMode}
            sv_teambalance_time ${toString server.game.teambalanceTime}
            sv_teamdamage ${bool server.game.teamDamage}
            sv_timelimit ${toString server.game.timeLimit}
            sv_tournament_mode ${toString server.game.tournamentMode}
            sv_vote_spectate ${bool server.game.voteSpectate}
            sv_vote_spectate_rejoindelay ${toString server.game.voteSpectateRejoinDelay}
            sv_warmup ${toString server.game.warmup}

            # External console settings
            ${optionalString (server.externalConsole != null && server.externalConsole.enable) ''
              ec_bindaddr ${server.externalConsole.bindAddr}
              ec_port ${toString server.externalConsole.port}
              ${optionalSetting "ec_password" server.externalConsole.password}
              ec_bantime ${toString server.externalConsole.banTime}
              ec_auth_timeout ${toString server.externalConsole.authTimeout}
              ec_output_level ${toString server.externalConsole.outputLevel}
            ''}

            # Remote console settings
            sv_rcon_bantime ${toString server.remoteConsole.rconBanTime}
            sv_rcon_max_tries ${toString server.remoteConsole.rconMaxTries}
            ${optionalSetting "sv_rcon_mod_password" server.remoteConsole.rconModPassword}
            ${optionalSetting "sv_rcon_password" server.remoteConsole.rconPassword}

            # Additional settings
            sv_map_download_speed ${toString server.mapDownloadSpeed}
            ${optionalSetting "sv_external_port" (
              if server.externalPort == 0 then null else toString server.externalPort
            )}

            ${lib.optionalString (server.extraConfig != null) server.extraConfig}
          '';

          serverConfig' =
            if (server.useQuickConfig && server.quickConfig != "") then server.quickConfig else serverConfig;
        in
        {
          description = "Teeworlds server ${name} managed by nix-teeworlds.";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          enable = server.enableService;

          startLimitIntervalSec = 120;
          startLimitBurst = 5;

          serviceConfig = {
            ExecStartPre = getExe (
              pkgs.writeShellApplication {
                name = "nix-teeworlds-${name}-start-pre";
                text = ''
                  ln -sf ${server.dataDir} data
                  ln -sf ${serverConfig'} autoexec.cfg
                '';
              }
            );

            ExecStart =
              let
                binaryPath =
                  if (server.binaryName != null) then
                    (getExe' server.package server.binaryName)
                  else
                    (getExe server.package);
              in
              "${binaryPath} -f autoexec.cfg";

            ExecStopPost = getExe (
              pkgs.writeShellApplication {
                name = "nix-teeworlds-${name}-stop-post";
                text = ''
                  rm ${cfg.rootDir}/${name}/data
                  rm ${cfg.rootDir}/${name}/autoexec.cfg
                '';
              }
            );

            WorkingDirectory = "${cfg.rootDir}/${name}";
            User = cfg.user;
            Group = cfg.group;
            Restart = "always";

            # Hardening
            PrivateDevices = true;
            PrivateUsers = true;
            ProtectHome = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
            ];
            RestrictNamespaces = true;
            SystemCallArchitectures = "native";

            CapabilityBoundingSet = [ "" ];
            DeviceAllow = [ "" ];
            LockPersonality = true;
            PrivateTmp = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHostname = true;
            ProtectProc = "invisible";
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            UMask = "0007";
          };
        }
      ) servers;

      # Open needed firewall ports
      networking.firewall = {
        allowedTCPPorts = mkTCPPorts false;
        allowedUDPPorts = mkUDPPorts false;
      };
    };
}

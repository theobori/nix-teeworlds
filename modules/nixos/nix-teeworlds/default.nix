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
    types
    mkOption
    filterAttrs
    mapAttrsToList
    optional
    unique
    mapAttrs'
    optionalString
    getExe
    getExe'
    isInt
    nameValuePair
    ;

  cfg = config.services.nix-teeworlds;

  optionalSetting = c: v: lib.optionalString (v != null) "${c} ${v}";

  bool = b: if b != null && b then "1" else "0";

  mkOptionFile =
    path:
    import path {
      inherit
        lib
        cfg
        pkgs
        mkSubmoduleFile
        ;
    };
  mkSubmoduleFile = path: types.submodule { options = mkOptionFile path; };
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

    servers = mkOption { type = types.attrsOf (mkSubmoduleFile ./server.nix); };
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
          message = "You have duplicates ports. Make sure all of your servers have a different port.";
        }
      ];

      systemd.tmpfiles.rules = mapAttrsToList (
        name: _: "d '${cfg.rootDir}/${name}' 0770 ${cfg.user} ${cfg.group} - -"
      ) servers;

      # Systemd service units
      systemd.services = mapAttrs' (
        name: server:
        nameValuePair "nix-teeworlds-${name}" (
          let
            serverConfig' = pkgs.writeText "autoexec.cfg" ''
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

            serverConfig =
              if (server.useQuickConfig && server.quickConfig != "") then server.quickConfig else serverConfig';
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
                    ln -sf ${serverConfig} autoexec.cfg
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
                    rm data autoexec.cfg
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
        )
      ) servers;

      # Open needed firewall ports
      networking.firewall = {
        allowedTCPPorts = mkTCPPorts false;
        allowedUDPPorts = mkUDPPorts false;
      };
    };
}

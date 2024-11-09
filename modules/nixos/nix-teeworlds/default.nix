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
    optionals
    unique
    mapAttrs'
    optionalString
    getExe
    getExe'
    nameValuePair
    concatStrings
    concatStringsSep
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
      description = ''
        Directory where all server-related files will be stored.
      '';
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
      description = ''
        User under which the Teeworlds servers will run.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "nix-teeworlds";
      description = ''
        Group under which the Teeworlds servers will run.
      '';
    };

    servers = mkOption {
      type = types.attrsOf (mkSubmoduleFile ./server/server.nix);
      description = ''
        Attribute set of Teeworlds server configurations.
        Each attribute defines a separate server instance with its own settings.
      '';
    };
  };

  config =
    let
      servers = filterAttrs (_: server: server.enable) cfg.servers;

      mkPorts =
        force: f:
        builtins.concatLists (
          mapAttrsToList (
            _: server:
            let
              ret = f server;
            in
            optionals (ret != [ ] && (server.openFirewall or force)) ret
          ) servers
        );

      # TCP ports
      mkTCPPorts =
        force:
        mkPorts force (
          server:
          let
            inherit (server.settings) externalPort;
            inherit (server) externalConsole;
          in
          (optional (externalPort != 0) externalPort)
          ++ (optional externalConsole.enable externalConsole.port)
        );
      # UDP ports
      mkUDPPorts = force: mkPorts force (server: [ server.settings.port ]);
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
            serverConfig' = ''
              # Server settings
              sv_port ${toString server.settings.port}
              sv_register ${bool server.settings.register}
              sv_name ${server.settings.name}
              ${optionalSetting "sv_motd" server.settings.motd}
              ${optionalSetting "password" server.settings.password}
              ${optionalSetting "sv_map_download_speed" (toString server.settings.mapDownloadSpeed)}
              ${optionalSetting "sv_external_port" (
                if server.settings.externalPort == 0 then null else toString server.settings.externalPort
              )}
              ${optionalSetting "bindaddr" server.settings.bindAddress}
              ${optionalSetting "sv_hostname" server.settings.hostname}
              sv_high_bandwidth ${bool server.settings.highBandwidth}
              sv_inactivekick ${toString server.settings.inactiveKick}
              sv_inactivekick_spec ${bool server.settings.inactiveKickSpec}
              sv_inactivekick_time ${toString server.settings.inactiveKickTime}
              sv_max_clients ${toString server.settings.maxClients}
              sv_max_clients_per_ip ${toString server.settings.maxClientsPerIp}
              sv_spamprotection ${bool server.settings.enableSpamProtection}

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
              ${optionalSetting "sv_rcon_password" server.remoteConsole.rconPassword}
              sv_rcon_bantime ${toString server.remoteConsole.rconBanTime}
              sv_rcon_max_tries ${toString server.remoteConsole.rconMaxTries}
              ${optionalSetting "sv_rcon_mod_password" server.remoteConsole.rconModPassword}
              ${optionalSetting "sv_rcon_password" server.remoteConsole.rconPassword}
              )}
            '';

            votes = concatStringsSep "\n" (
              mapAttrsToList (
                name: vote:
                let
                  commands' = concatStrings (map (command: "${command};") vote.commands);
                  commands = if commands' == "" then "say ${name}" else commands';
                in
                "add_vote \"${name}\" \"${commands}\""
              ) server.votes
            );

            serverConfig =
              let
                inherit (server) useQuickConfig quickConfig extraConfig;
              in
              pkgs.writeText "nix-teeworlds-${name}-configuration" (
                concatStringsSep "\n" [
                  # Pick the quick configuration if needed
                  (if (useQuickConfig && quickConfig != "") then quickConfig else serverConfig')

                  # Concat the extra configuration
                  (optionalString (extraConfig != null) extraConfig)

                  # Concat the votes
                  votes
                ]
              );
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
                    ${optionalString (server.dataDir != null) "ln -sf ${server.dataDir} data"}
                    ln -sf ${serverConfig} ${server.cfgName}
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
                "${binaryPath} -f ${server.cfgName}";

              ExecStopPost = getExe (
                pkgs.writeShellApplication {
                  name = "nix-teeworlds-${name}-stop-post";
                  text = ''
                    rm data ${server.cfgName}
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

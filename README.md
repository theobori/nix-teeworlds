# Nix Teeworlds

[![check](https://github.com/theobori/nix-teeworlds/actions/workflows/check.yml/badge.svg)](https://github.com/theobori/nix-teeworlds/actions/workflows/check.yml)

The aim of this project is to be able to declare Teeworlds servers in Nix. To achieve this, this repository provides various Nix expressions, including a NixOS module, packages for different Teeworlds game modes and default overlays adding these packages.

The module is designed to be flexible, so it's entirely possible to use your own Teeworlds resources, such as a custom data folder, your own server configuration, your own packages and much more.

The NixOS `nix-teeworlds` module is inspired by [nix-minecraft](https://github.com/Infinidoge/nix-minecraft) and the [teeworlds](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/games/teeworlds.nix) module in the official Nix expression collection.

## Installation

Inside your `flake.nix`, you can start by adding the following lines.

```nix
{
  inputs = {
    nix-teeworlds.url = "github:theobori/nix-teeworlds";
  };
}
```

You can then include the module and its default overlay in the system configuration as shown below.

```nix
{ inputs, ... }: {
  imports = with inputs; [ nix-teeworlds.nixosModules.nix-teeworlds ];
  nixpkgs.overlays = with inputs; [ nix-teeworlds.overlays.default ];
}
```

## Contribute

If you want to help the project, you can follow the guidelines in [CONTRIBUTING.md](./CONTRIBUTING.md).

## Packages

All packages written in [packages](./packages) are compatible with the `nix run` command, even without specifying a Teeworlds server configuration file (like `autoexec.cfg`).

For example, you could create an [infclassR](https://github.com/infclass/teeworlds-infclassR) server with the following command.

```bash
nix run github:theobori/nix-teeworlds#infclassr-server
```

The following packages are available.
- `fixed-ddnet-server`
- `fng2-server`
- `infclassr-server`
- `ddnet-insta-server`

## Examples

You can find examples of how to configure `nix-teeworlds` in the folder [examples](./examples).

## Module

> Make sure that all ports specified in a server configuration are also specified in the Nix configuration. Otherwise, they will not be authorized by the firewall.
> For example, if you have `sv_port 8304`, you must also have `services.nix-teeworlds.servers.<name>.settings.port = 8304` on the Nix side.

### `services.nix-teeworlds.enable`

Whether to enable Enable nix-teeworlds servers…

*Type:* boolean

*Default:* `false`

*Example:* `true`

### `services.nix-teeworlds.group`

Group under which the Teeworlds servers will run.

*Type:* string

*Default:* `"nix-teeworlds"`

### `services.nix-teeworlds.openFirewall`

Whether to open ports for each server.

*Type:* boolean

*Default:* `false`

### `services.nix-teeworlds.rootDir`

Directory where all server-related files will be stored.

*Type:* string

*Default:* `"/srv/nix-teeworlds"`

### `services.nix-teeworlds.servers`

Attribute set of Teeworlds server configurations.

Each attribute defines a separate server instance with its own settings.

*Type:* attribute set of (submodule)

### `services.nix-teeworlds.servers.<name>.enable`

Whether to enable Enable this Teeworlds server…

*Type:* boolean

*Default:* `false`

*Example:* `true`

### `services.nix-teeworlds.servers.<name>.enableService`

Whether to enable this server systemd service unit.

*Type:* boolean

*Default:* `true`

### `services.nix-teeworlds.servers.<name>.package`

The teeworlds-server package to use.

*Type:* package

*Default:* `pkgs.teeworlds-server`

### `services.nix-teeworlds.servers.<name>.binaryName`

Custom binary name to use for the server executable.

If null, uses the default from the package.

*Type:* null or string

*Default:* `null`

### `services.nix-teeworlds.servers.<name>.cfgName`

Server configuration file name.

*Type:* string

*Default:* `"server.cfg"`

### `services.nix-teeworlds.servers.<name>.dataDir`

Custom data directory path for the server.

If null, uses the default from the package.

*Type:* null or path or package or string

*Default:* `null`

### `services.nix-teeworlds.servers.<name>.externalConsole`

External console configuration.

*Type:* submodule

*Default:* `{ }`

### `services.nix-teeworlds.servers.<name>.externalConsole.enable`

Whether to enable Enable the external console…

*Type:* boolean

*Default:* `false`

*Example:* `true`

### `services.nix-teeworlds.servers.<name>.externalConsole.authTimeout`

Time in seconds before the the econ authentication times out.

*Type:* signed integer

*Default:* `30`

### `services.nix-teeworlds.servers.<name>.externalConsole.banTime`

The time a client gets banned if econ authentication fails. 0 just closes the connection.

*Type:* signed integer

*Default:* `0`

### `services.nix-teeworlds.servers.<name>.externalConsole.bindAddr`

Address to bind the external console to. Anything but ‘localhost’ is dangerous!

*Type:* string

*Default:* `"localhost"`

### `services.nix-teeworlds.servers.<name>.externalConsole.outputLevel`

Adjusts the amount of information in the external console.

*Type:* signed integer

*Default:* `1`

### `services.nix-teeworlds.servers.<name>.externalConsole.password`

External console password.

*Type:* null or string

*Default:* `null`

### `services.nix-teeworlds.servers.<name>.externalConsole.port`

Port to use for the external console.

*Type:* signed integer

*Default:* `1234`

### `services.nix-teeworlds.servers.<name>.extraConfig`

Additional configuration lines to append to the server configuration.

*Type:* null or strings concatenated with “\\n”

*Default:* `null`

### `services.nix-teeworlds.servers.<name>.game`

Game configuration.

*Type:* submodule

*Default:* `{ }`

### `services.nix-teeworlds.servers.<name>.game.countdown`

Number of seconds to freeze the game in a countdown before match starts (0 enables only for survival gamemodes, -1 disables).

*Type:* signed integer

*Default:* `0`

### `services.nix-teeworlds.servers.<name>.game.gameType`

Game type (This setting needs the map to be reloaded in order to take effect).

*Type:* string

*Default:* `"dm"`

### `services.nix-teeworlds.servers.<name>.game.map`

Map to use on the server.

*Type:* string

*Default:* `"dm1"`

### `services.nix-teeworlds.servers.<name>.game.mapRotation`

Maps to rotate between.

*Type:* string

*Default:* `""`

### `services.nix-teeworlds.servers.<name>.game.matchSwap`

Swap teams between matches.

*Type:* boolean

*Default:* `true`

### `services.nix-teeworlds.servers.<name>.game.matchesPerMap`

Number of matches on each map before rotating.

*Type:* signed integer

*Default:* `1`

### `services.nix-teeworlds.servers.<name>.game.playerReadyMode`

When enabled, players can pause/unpause the game and start the game on warmup via their ready state.

*Type:* boolean

*Default:* `false`

### `services.nix-teeworlds.servers.<name>.game.playerSlots`

Number of slots to reserve for players.

*Type:* signed integer

*Default:* `8`

### `services.nix-teeworlds.servers.<name>.game.powerups`

Allow powerups like ninja.

*Type:* boolean

*Default:* `true`

### `services.nix-teeworlds.servers.<name>.game.respawnDelayTDM`

Time needed to respawn after death in tdm gametype.

*Type:* signed integer

*Default:* `3`

### `services.nix-teeworlds.servers.<name>.game.scoreLimit`

Score limit of the game (0 disables it).

*Type:* signed integer

*Default:* `20`

### `services.nix-teeworlds.servers.<name>.game.strictSpectateMode`

Restricts information like health, ammo and armour in spectator mode.

*Type:* boolean

*Default:* `false`

### `services.nix-teeworlds.servers.<name>.game.teamDamage`

Team damage.

*Type:* boolean

*Default:* `false`

### `services.nix-teeworlds.servers.<name>.game.teambalanceTime`

How many minutes to wait before autobalancing teams.

*Type:* signed integer

*Default:* `1`

### `services.nix-teeworlds.servers.<name>.game.timeLimit`

Time limit of the game (in case of equal points there will be sudden death) (0 disables).

*Type:* signed integer

*Default:* `0`

### `services.nix-teeworlds.servers.<name>.game.tournamentMode`

Tournament mode. When enabled, players joins the server as spectator (2=additional restricted spectator chat).

*Type:* signed integer

*Default:* `0`

### `services.nix-teeworlds.servers.<name>.game.voteSpectate`

Allow voting to move players to spectators.

*Type:* boolean

*Default:* `true`

### `services.nix-teeworlds.servers.<name>.game.voteSpectateRejoinDelay`

How many minutes to wait before a player can rejoin after being moved to spectators by vote.

*Type:* signed integer

*Default:* `3`

### `services.nix-teeworlds.servers.<name>.game.warmup`

Number of seconds to do warmup before match starts (0 disables, -1 all players ready).

*Type:* signed integer

*Default:* `0`

### `services.nix-teeworlds.servers.<name>.openFirewall`

Whether to open ports in the firewall for this server.

*Type:* boolean

*Default:* `false`

### `services.nix-teeworlds.servers.<name>.quickConfig`

Custom configuration to use instead of the basic one.

Only used when useQuickConfig is enabled.

*Type:* strings concatenated with “\\n”

*Default:* `""`

### `services.nix-teeworlds.servers.<name>.remoteConsole`

Remote console console configuration.

*Type:* submodule

*Default:* `{ }`

### `services.nix-teeworlds.servers.<name>.remoteConsole.rconBanTime`

The time a client gets banned if remote console authentication fails. 0 makes it just use kick.

*Type:* signed integer

*Default:* `5`

### `services.nix-teeworlds.servers.<name>.remoteConsole.rconMaxTries`

Maximum number of tries for remote console authentication.

*Type:* signed integer

*Default:* `3`

### `services.nix-teeworlds.servers.<name>.remoteConsole.rconModPassword`

Remote console password for moderators (limited access).

*Type:* null or string

*Default:* `null`

### `services.nix-teeworlds.servers.<name>.remoteConsole.rconPassword`

Password to access the remote console (if not set, rcon is disabled).

*Type:* null or string

*Default:* `null`

### `services.nix-teeworlds.servers.<name>.settings`

Settings configuration.

*Type:* submodule

*Default:* `{ }`

### `services.nix-teeworlds.servers.<name>.settings.enableSpamProtection`

Whether to enable chat spam protection.

*Type:* boolean

*Default:* `true`

### `services.nix-teeworlds.servers.<name>.settings.bindAddress`

Address to bind.

*Type:* null or string

*Default:* `null`

### `services.nix-teeworlds.servers.<name>.settings.externalPort`

Port to report to the master servers (e.g. in case of a firewall rename).

*Type:* signed integer

*Default:* `0`

### `services.nix-teeworlds.servers.<name>.settings.highBandwidth`

Use high bandwidth mode. Doubles the bandwidth required for the server. LAN use only.

*Type:* boolean

*Default:* `false`

### `services.nix-teeworlds.servers.<name>.settings.hostname`

Server hostname.

*Type:* null or string

*Default:* `null`

### `services.nix-teeworlds.servers.<name>.settings.inactiveKick`

How to deal with inactive clients (1=move player to spectator, 2=move to free spectator slot/kick, 3=kick).

*Type:* one of 1, 2, 3

*Default:* `2`

### `services.nix-teeworlds.servers.<name>.settings.inactiveKickSpec`

Kick inactive spectators.

*Type:* boolean

*Default:* `false`

### `services.nix-teeworlds.servers.<name>.settings.inactiveKickTime`

How many minutes to wait before taking care of inactive clients.

*Type:* signed integer

*Default:* `3`

### `services.nix-teeworlds.servers.<name>.settings.mapDownloadSpeed`

Number of map data packages a client gets on each request.

*Type:* signed integer

*Default:* `8`

### `services.nix-teeworlds.servers.<name>.settings.maxClients`

Number of clients that can be connected to the server at the same time.

*Type:* signed integer

*Default:* `12`

### `services.nix-teeworlds.servers.<name>.settings.maxClientsPerIp`

Maximum number of clients with the same IP that can connect to the server.

*Type:* signed integer

*Default:* `4`

### `services.nix-teeworlds.servers.<name>.settings.motd`

Message of the day, shown in server info and when joining a server.

*Type:* null or string

*Default:* `null`

### `services.nix-teeworlds.servers.<name>.settings.name`

Name of the server.

*Type:* string

*Default:* `"unnamed server"`

### `services.nix-teeworlds.servers.<name>.settings.password`

Password to connect to the server.

*Type:* null or string

*Default:* `null`

### `services.nix-teeworlds.servers.<name>.settings.port`

Port the server will listen on.

*Type:* signed integer

*Default:* `8303`

### `services.nix-teeworlds.servers.<name>.settings.register`

Whether to register this server on the masters servers.

*Type:* boolean

*Default:* `false`

### `services.nix-teeworlds.servers.<name>.useQuickConfig`

Whether to enable Enable quick configuration…

*Type:* boolean

*Default:* `false`

*Example:* `true`

### `services.nix-teeworlds.servers.<name>.votes`

Server votes configuration.

*Type:* attribute set of (submodule)

*Default:* `{ }`

### `services.nix-teeworlds.servers.<name>.votes.<name>.commands`

List of command to execute when this vote is voted.

*Type:* list of string

### `services.nix-teeworlds.user`

User under which the Teeworlds servers will run.

*Type:* string

*Default:* `"nix-teeworlds"`

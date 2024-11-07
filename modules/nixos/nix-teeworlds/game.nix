{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
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
}

# Nix Teeworlds Examples

Before using the examples below, don't forget to follow the Nix Teeworlds installation steps in [README.md](/README.md).

You can also consult the [default.nix](./default.nix) file.

## A Minimal usage

Here's a simple example for a Teeworlds 0.7 vanilla CTF server.

```nix
{ ... }:
{
  services.nix-teeworlds = {
    enable = true;
    openFirewall = true;

    servers = {
      my-ctf = {
        enable = true;

        settings = {
          name = "My vanilla CTF server from NixOS";
          port = 8303;
        };

        game = {
          gameType = "ctf";
          map = "ctf1";
        };
      };
    };
  };
}
```

## A more complex usage

Here's a slightly more complex example for a Teeworlds FNG server.

```nix
{ pkgs, ... }:
{
  services.nix-teeworlds = {
    enable = true;
    openFirewall = true;

    servers = {
      my-fng = {
        enable = true;
        package = pkgs.fng2-server;

        extraConfig = ''
          password "1234"
        '';

        externalConsole = {
          enable = true;
          port = 1111;
          password = "hello";
          outputLevel = 2;
        };

        settings = {
          name = "My FNG server from NixOS";
          port = 8305;
          maxClients = 16;
        };

        game = {
          gameType = "fng2";
          map = "AliveFNG";
          scoreLimit = 800;
        };

        votes = {
          "Say hello" = {
            commands = [
              "say hello"
              "say world"
              "say !!"
            ];
          };

          "Map IIT_Edited" = {
            commands = [ "sv_map IIT_Edited" ];
          };

          "Empty vote" = {
            commands = [ ];
          };
        };
      };
    };
  };
}
```

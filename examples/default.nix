{ pkgs, ... }:
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

      my-ddrace = {
        enable = true;
        package = pkgs.fixed-ddnet-server;

        settings = {
          name = "My DDRace server from NixOS";
          port = 8304;
        };

        game = {
          gameType = "ddrace";
          map = "Tutorial";
        };
      };

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

      my-infclass = {
        enable = true;
        package = pkgs.infclassr-server;

        settings = {
          name = "My infection server from NixOS";
          port = 8306;
        };

        game = {
          gameType = "InfClass";
          map = "infc_bamboo2";
        };
      };
    };
  };
}

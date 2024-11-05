{
  description = "theobori's Nix/NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs =
    inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;

        snowfall = {
          metadata = "nix-teeworlds";
          namespace = "nix-teeworlds";
          meta = {
            name = "nix-teeworlds";
            title = "Nix Teeworlds";
          };
        };
      };
    in
    lib.mkFlake { outputs-builder = channels: { formatter = channels.nixpkgs.nixfmt-rfc-style; }; };
}

{
  pkgs,
  mkShell,
  system,
  inputs,
  ...
}:
mkShell {
  packages = with pkgs; [
    statix
    deadnix
    git
    nix-inspect
    nix-bisect
    nix-diff
    nix-health
    nix-index
    nix-melt
    nix-prefetch-git
    nix-search-cli
    nix-tree
    nixpkgs-hammering
    nixpkgs-lint

    inputs.self.checks.${system}.pre-commit-hooks.enabledPackages
  ];

  shellHook = ''
    ${inputs.self.checks.${system}.pre-commit-hooks.shellHook}
  '';
}

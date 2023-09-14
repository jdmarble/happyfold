{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # Need unstable for talosctl version 1.5
    flake-utils.url = "github:numtide/flake-utils";
  };

  description = "";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};  
      in {
      devShell = pkgs.mkShell {
        buildInputs = [
          pkgs.argocd
          pkgs.bitwarden-cli
          pkgs.k9s
          pkgs.kubectl
          pkgs.talosctl
        ];
      };
    });
}

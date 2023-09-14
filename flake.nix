{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  description = "";

  outputs = { self, nixpkgs, ... }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
    devShell.x86_64-linux =
      pkgs.mkShell {
        buildInputs = [
          pkgs.bitwarden-cli
          pkgs.kubectl
          pkgs.talosctl
        ];
      };
  };
}

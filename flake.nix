{
  description = "quark";
  inputs = {
    nixpkgs.url =
      "github:nixos/nixpkgs/2f9173bde1d3fbf1ad26ff6d52f952f9e9da52ea";
    go_1_24_0-pkgs.url =
      "github:nixos/nixpkgs/2d068ae5c6516b2d04562de50a58c682540de9bf";
    bun_1_2_0-pkgs.url =
      "github:nixos/nixpkgs/f898cbfddfab52593da301a397a17d0af801bbc";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ ];
        pkgs = import nixpkgs { inherit system overlays; };
        go-pkgs = inputs.go_1_24_0-pkgs.legacyPackages.${system};
        bun-pkgs = inputs.bun_1_2_0-pkgs.legacyPackages.${system};

        ctx = {
          go = go-pkgs.go_1_24;
          build-deps = [ ];
        };

        server-ctx = ctx // {
          package = {
            name = "quark-server";
            version = "0.0.1";
            src = ./server;
            go-mod = ./server/go.mod;
            go-sum = ./server/go.sum;
          };
        };
        client-ctx = ctx // {
          package = {
            name = "quark-client";
            version = "0.0.1";
            src = ./client;
            go-mod = ./client/go.mod;
            go-sum = ./client/go.sum;
          };
        };

        server = import ./server/package.nix { inherit pkgs; ctx = server-ctx; };
        client = import ./client/package.nix { inherit pkgs; ctx = client-ctx; };

        devShell = import ./shell.nix { inherit pkgs go-pkgs bun-pkgs ctx; };
      in {
        formatter = pkgs.nixfmt-classic;
        devShells.default = devShell;
		packages.server = server;
		packages.client = client;
        apps.server = {
          type = "app";
          program = "${server}/bin/${server-ctx.package.name}";
        };
        apps.client = {
          type = "app";
          program = "${client}/bin/${client-ctx.package.name}";
        };
      });
}

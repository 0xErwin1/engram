{
  description = "engram - Persistent memory for AI coding agents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        pname = "engram";
        version = "1.10.3";

        engram = pkgs.buildGoModule {
          inherit pname;
          inherit version;
          vendorHash = "sha256-wnRtuBn5H+UdWkXucpfHPEbFosVCUa8i9hVRXg5Wqc4=";
          proxyVendor = true;

          src = ./.;
          subPackages = [ "cmd/engram" ];

          env = {
            CGO_ENABLED = "0";
          };

          ldflags = [
            "-s"
            "-w"
            "-X main.version=${version}"
          ];

          meta = with pkgs.lib; {
            description = "Persistent memory for AI coding agents";
            homepage = "https://github.com/Gentleman-Programming/engram";
            license = licenses.mit;
            mainProgram = "engram";
            platforms = platforms.linux ++ platforms.darwin;
          };
        };
      in
      {
        packages.default = engram;
        packages.engram = engram;

        apps.default = flake-utils.lib.mkApp {
          drv = engram;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go_1_25
            gopls
            gotools
            golangci-lint
            delve
          ];
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}

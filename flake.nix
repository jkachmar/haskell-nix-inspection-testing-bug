{
  description = "Reproducible failure.";

  inputs = {
    ####################
    # Misc. utilities. #
    ####################
    # Unofficial library of utilities for managing with Nix Flakes.
    flake-utils.url = "github:numtide/flake-utils";

    ##########################################
    # 'haskell.nix' Framework & Dependencies #
    ##########################################
    # Regularly updated 'Nix-ified' snapshots of the Hackage package index.
    hackage = {
      url = "github:input-output-hk/hackage.nix";
      flake = false;
    };

    # Regularly updated 'Nix-ified' Stackage snapshots.
    stackage = {
      url = "github:input-output-hk/stackage.nix";
      flake = false;
    };

    # IOHK's 'haskell.nix' framework.
    #
    # NOTE: Passing in our own Hackage & Stackage snapshots as arguments allows
    # us to manage package versioning separately from the upstream IOHK repo.
    haskell-nix = {
      inputs.hackage.follows = "hackage";
      inputs.stackage.follows = "stackage";
      url = "github:input-output-hk/haskell.nix";
    };

    ####################
    # Nix Package Sets #
    ####################
    # NOTE: We have to be careful to source our package sets from the same
    # place that 'haskell.nix' does.
    #
    # Without this, we won't be able to pull from their binary cache, and will
    # very likely end up having to build multiple copies of GHC to bring up the
    # development environment. 
    nixpkgs.follows = "haskell-nix/nixpkgs-2105";
    unstable.follows = "haskell-nix/nixpkgs-unstable";
  };

  outputs = inputs@{ self, flake-utils, haskell-nix, nixpkgs, ... }:
    let
      inherit (haskell-nix.internal) config;
      inherit (flake-utils.lib) eachSystem;

      # All of the systems we want to build development environments for.
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];

      # All of the overlays we want to apply to the base Nix package set.
      overlays = [
        haskell-nix.overlay
        (import ./overlay.nix)
      ];
    in
    # Generate output configurations for each system that we support.
    eachSystem systems (system:
      let
        pkgs = import nixpkgs { inherit system overlays config; };
        flake = pkgs.example.flake {};
      in
      flake // {
        defaultPackage = flake.packages."example:lib:example";
      }
    );
}

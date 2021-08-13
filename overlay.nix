final: prev:

let
  inherit (final.haskell-nix) project';
  inherit (final.haskell-nix.haskellLib) cleanGit;
in

{
  example = project' {
    src = ./.;
    compiler-nix-name = "ghc8105";
  };
}

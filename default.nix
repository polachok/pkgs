{ pkgs ? import <nixpkgs> {} }:

rec {
  pt = pkgs.callPackage ./pt {};
  solana = pkgs.callPackage ./solana {};
}

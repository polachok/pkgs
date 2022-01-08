{ pkgs ? import <nixpkgs> {} }:

rec {
  pt = pkgs.callPackage ./pt {};
  solana = pkgs.callPackage ./solana {};
  solana-bpf-tools = pkgs.callPackage ./solana-bpf-tools {};
}

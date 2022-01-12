{ pkgs ? import <nixpkgs> {} }:

rec {
  pt = pkgs.callPackage ./pt {};
  solana = pkgs.callPackage ./solana {};
  solana-bpf-tools = pkgs.callPackage ./solana-bpf-tools {};
  gruvbox-material-gtk = pkgs.callPackage ./gruvbox-material-gtk {};
  gruvbox-gtk-theme = pkgs.callPackage ./gruvbox-gtk-theme {};
}

{ pkgs ? import <nixpkgs> {} }:

rec {
  pt = pkgs.callPackage ./pt {};
}

{ rustPlatform, lib, fetchFromGitHub, fetchgit, fetchurl, pkgs }:

let
#  rust_repo = fetchgit {
#    owner = "solana-labs";
#    repo = "rust";
#    rev = "bpf-tools-v1.19";
#    sha256 = "1kwk6hsadmg1qnf82f611p684p7xxh78rkaxcnhmmmfjdy1rfxcc";
#    fetchSubmodules = true;
#  };
  clang = pkgs.llvmPackages_13.clang;
  rust_repo = fetchgit {
    url = "https://github.com/solana-labs/rust";
    rev = "bpf-tools-v1.19";
    sha256 = "0hgik0317nsywsxyiiqqssk0fm82r8hmb7n1zi3p0kx54j7gv9g9";
    fetchSubmodules = true;
  };
  cargo_repo = fetchFromGitHub {
    owner = "solana-labs";
    repo = "cargo";
    rev = "rust-1.56.0";
    sha256 = lib.fakeSha256;
  };
  newlib_repo = fetchFromGitHub {
    owner = "solana-labs";
    repo = "newlib";
    rev = "bpf-tools-v1.19";
    sha256 = lib.fakeSha256;
  };
  rustc_pkg = import ./rustc.nix { inherit rustPlatform lib fetchFromGitHub fetchgit fetchurl pkgs; };
in
pkgs.stdenv.mkDerivation {
  pname = "solana-bpf-tools";
  version = "1.19";

  src = fetchFromGitHub {
    owner = "solana-labs";
    repo = "bpf-tools";
    rev = "v1.19";
    sha256 = "0ad6b2k5shg6v1qww82jdfimr2pn9mzgh9pb8yk9i52f3q098qy9";
  };

  nativeBuildInputs = with pkgs; [ bash git python3 curl rustc cargo ];
  buildInputs = with pkgs; [ ];

  buildPhase = ''
     echo ${rustc_pkg}
    #./x.py build --stage 1 --target=x86_64-unknown-linux-gnu,bpfel-unknown-unknown --set=build.rustc=${pkgs.rustc}/bin/rustc --set=build.cargo=${pkgs.cargo}/bin/cargo
  '';

  doCheck = false;
}

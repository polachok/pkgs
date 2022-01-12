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
    owner = "rust-lang";
    repo = "cargo";
    rev = "rust-1.56.0";
    sha256 = "0m8nac1apal4vcga48anh260r7xc9d21m0fcim2aavq3dygk9nr6";
  };
  newlib_repo = fetchFromGitHub {
    owner = "solana-labs";
    repo = "newlib";
    rev = "bpf-tools-v1.19";
    sha256 = "03fvryw1cr9aglkbx0wwpilf99991l55lsqpyccy5ichjv6nb8l0";
  };
  bpf_tools_repo = fetchFromGitHub {
    owner = "solana-labs";
    repo = "bpf-tools";
    rev = "v1.19";
    sha256 = "0ad6b2k5shg6v1qww82jdfimr2pn9mzgh9pb8yk9i52f3q098qy9";
  };
  #rustc_pkg = import ./rustc.nix { inherit rustPlatform lib fetchFromGitHub fetchgit fetchurl pkgs; };
in
pkgs.stdenv.mkDerivation rec {
  pname = "solana-bpf-tools";
  version = "1.19";

  src = [ bpf_tools_repo rust_repo cargo_repo newlib_repo ];
  sourceRoot = ".";
  #cargoRoot = "./bpf-tools/out/rust";

  nativeBuildInputs = with pkgs; [
    git python3
    clang
    cmake
    ninja
    rustPlatform.rust.rustc rustPlatform.rust.cargo
    rustPlatform.cargoSetupHook
  ];
  buildInputs = with pkgs; [ ];
  outputs = ["out"];

  patches = [ ./disable-git-clone.patch ./enable-vendor.patch ./disable-vendor-check.patch ];

  dontConfigure = true;

  cargoRoot = "./out/rust";
  cargoVendorDir = "./out/rust/vendor";
  cargoDeps = rustPlatform.importCargoLock {
      lockFile = "${rust_repo}/Cargo.lock";
      outputHashes = {
        "compiler_builtins-0.1.52" = "0mwbxvr8x332irmgaqxxn3ij2wpdvpvaxc5qkw5fhq1rl7qbaivw";
      };
  };

  postPatch = ''
    patchShebangs ./out/rust/x.py
    patchShebangs ./out/rust/build.sh
    patchShebangs ./out/rust/src/etc

    substituteInPlace ./build.sh --subst-var-by cargo ${rustPlatform.rust.cargo}/bin/cargo
    substituteInPlace ./out/rust/config.toml --subst-var-by cargo ${rustPlatform.rust.cargo}/bin/cargo \
      --subst-var-by rustc ${rustPlatform.rust.rustc}/bin/rustc
  '';

  unpackPhase = ''
    echo "copying sources"
    cp -r ${bpf_tools_repo} bpf-tools
    chmod -R +w ./bpf-tools/
    mkdir -p bpf-tools/out
    cd ./bpf-tools
    cp -r ${rust_repo} ./out/rust
    cp -r ${cargo_repo} ./out/cargo
    cp -r ${newlib_repo} ./out/newlib
    echo "copying vendored sources"
    chmod -R +w .
    cp -r ${cargoDeps} ./out/rust/vendor
    chmod -R +w ./out/rust
    cp -r ./out/rust/vendor/.cargo ./out/rust/.cargo
    sed -i 's/cargo-vendor-dir/vendor/' ./out/rust/.cargo/config 
    chmod -R +w .
    echo "copied"
  '';

  buildPhase = ''
    echo "== starting build"
    export GITHUB_WORKSPACE=$(pwd)
    bash ./build.sh
  '';

  installPhase = ''
    mkdir -p $out
    cp -r out/deploy/* $out/
  '';

  doCheck = false;
}

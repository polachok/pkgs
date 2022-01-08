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
  rustc_pkg = pkgs.rustc.overrideDerivation(old: rec {
    name = "solana-rustc";
    version = "1.56.0";
    src = rust_repo;
    cargoDeps = rustPlatform.importCargoLock {
      lockFile = "${src}/Cargo.lock";
      outputHashes = {
        "compiler_builtins-0.1.52" = "0mwbxvr8x332irmgaqxxn3ij2wpdvpvaxc5qkw5fhq1rl7qbaivw";
      };
    };
    withBundledLLVM = false;
    configureFlags = [
     "--enable-optimize-llvm"
     "--enable-optimize" "--enable-rpath" "--experimental-targets=BPF"
     "--disable-docs"
     /* "--enable-clang" */
     /* "--enable-lld" */
     "--enable-vendor" "--enable-locked-deps" 
     "--set=build.rustc=${rustPlatform.rust.rustc}/bin/rustc"
     "--set=build.cargo=${rustPlatform.rust.cargo}/bin/cargo"
     "--target=${pkgs.rust.toRustTargetSpec pkgs.stdenv.hostPlatform}"
    ];

    postConfigure = ''
      sed -i '/\[llvm\]/aenable-projects = "clang;lld"\ntargets = "AArch64;X86"' config.toml
    '';

    /* configureFlags = lib.filter (s: !(lib.hasPrefix "--target" s)) old.configureFlags ++ */
    /*   ["--enable-locked-deps"] ++ */
    /*   ["--target=${pkgs.rust.toRustTargetSpec pkgs.stdenv.hostPlatform},bpfel-unknown-unknown" ] ++ */
    /*   ["--set=target.bpfel-unknown-unknown.cc=${pkgs.llvmPackages_13.stdenv.cc}/bin/cc" "--set=target.bpfel-unknown-unknown.cxx=${pkgs.llvmPackages_13.stdenv.cc}/bin/cc" "--set=target.bpfel-unknown-unknown.linker=${pkgs.llvmPackages_13.stdenv.cc}/bin/cc" "--set=target.bpefl-unknpwn-unknown.llvm-config=${pkgs.llvmPackages_13.llvm}/bin/llvm-config"]; */
    nativeBuildInputs = [ pkgs.python3 rustPlatform.cargoSetupHook clang pkgs.cmake ];
    buildPhase = ''
      export VERBOSE=1
      #rm -rf src/llvm
      #export CARGO_HOME=$TMPDIR
      cat config.toml|grep -v '^#'
      cat > config.toml.2 <<EOF
changelog-seen = 2
[llvm]
optimize = true
release-debuginfo = false
assertions = false
targets = "AArch64;X86"
experimental-targets = "BPF"
link-shared = false
enable-projects = "clang;lld"
[build]
docs = false
vendor = true
locked-deps = true
cargo = '/nix/store/w8r7zj2bp8avhsdf119ngb93i23fzjsh-cargo-bootstrap-1.55.0/bin/cargo'

rustc = '/nix/store/yn5mj04hbs8ia9jb6dxxrm0gpcdrv2ak-rustc-bootstrap-1.55.0/bin/rustc'

[install]
prefix = "opt/bpf-rust"
[rust]
optimize = true
debug = false
debug-assertions = false
[target.x86_64-unknown-linux-gnu]
[dist]
EOF
      #pwd
      #echo "source root: <$sourceRoot> <$cargoDeps>"
      cp -r $cargoDeps ./vendor
      #mkdir .cargo
      ls -a
      #python ./x.py --enable-vendor build --stage 1 --target=x86_64-unknown-linux-gnu,bpfel-unknown-unknown --set=build.rustc=${pkgs.rustc}/bin/rustc --set=build.cargo=${pkgs.cargo}/bin/cargo
      python ./x.py build --stage 1 --target=x86_64-unknown-linux-gnu,bpfel-unknown-unknown
    '';
    postInstall = "";
  });
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

{ rustPlatform, lib, fetchFromGitHub, fetchgit, fetchurl, pkgs }:

let
  clang = pkgs.llvmPackages_13.clang;
  rust_repo = fetchgit {
    url = "https://github.com/solana-labs/rust";
    rev = "bpf-tools-v1.19";
    sha256 = "0hgik0317nsywsxyiiqqssk0fm82r8hmb7n1zi3p0kx54j7gv9g9";
    fetchSubmodules = true;
  };
  host_triple = "${pkgs.rust.toRustTargetSpec pkgs.stdenv.hostPlatform}";
in
pkgs.rustc.overrideDerivation(old: rec {
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
     "--enable-optimize"
     "--enable-rpath"
     "--experimental-targets=BPF"
     "--disable-docs"
     "--disable-ninja"
     /* "--enable-clang" */
     /* "--enable-lld" */
     "--enable-vendor"
     "--enable-locked-deps" 
     "--set=build.rustc=${rustPlatform.rust.rustc}/bin/rustc"
     "--set=build.cargo=${rustPlatform.rust.cargo}/bin/cargo"
     "--target=${pkgs.rust.toRustTargetSpec pkgs.stdenv.hostPlatform}"
    ];

    postConfigure = ''
      sed -i '/\[llvm\]/aenable-projects = "clang;lld"\ntargets = "AArch64;X86"' config.toml
    '';

    nativeBuildInputs = [ pkgs.python3 rustPlatform.cargoSetupHook clang pkgs.cmake ];
    buildPhase = ''
      export VERBOSE=1
      cat config.toml|grep -v '^#'
      cp -r $cargoDeps ./vendor
      ls -a
      python ./x.py build --stage 1 --target=x86_64-unknown-linux-gnu,bpfel-unknown-unknown
    '';
    installPhase = ''
      mkdir -p $out/{rust,llvm}/{bin,lib}
      echo "Installing rust binaries"
      cp -R build/${host_triple}/stage1/bin $out/rust/bin
      cp -R "build/${host_triple}/stage1/lib/rustlib/${host_triple}" $out/rust/lib/rustlib/
      cp -R "build/${host_triple}/stage1/lib/rustlib/bpfel-unknown-unknown" $out/rust/lib/rustlib/
      find . -maxdepth 6 -type f -path "build/${host_triple}/stage1/lib/*" -exec cp {} $out/rust/lib \;

      echo "Installing LLVM binaries"
      mkdir -p $out/llvm/{bin,lib}

      while IFS= read -r f
      do
          bin_file="build/${host_triple}/llvm/build/bin/$f"
          if [[ -f "$bin_file" ]] ; then
              cp -R "$bin_file" $out/llvm/bin/
          fi
      done < <(cat <<EOF
      clang
      clang++
      clang-cl
      clang-cpp
      clang-13
      ld.lld
      ld64.lld
      llc
      lld
      lld-link
      llvm-ar
      llvm-objcopy
      llvm-objdump
      llvm-readelf
      llvm-readobj
      EOF
      )
      cp -R "rust/build/${host_triple}/llvm/build/lib/clang" deploy/llvm/lib/
    '';
    postInstall = "";
    outputs = ["out"];
  })


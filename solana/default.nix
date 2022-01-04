{ rustPlatform, lib, fetchFromGitHub, pkgs, protobuf }:

rustPlatform.buildRustPackage rec {
  pname = "solana";
  version = "1.8.11";

  src = fetchFromGitHub {
    owner = "solana-labs";
    repo = "solana";
    rev = "v1.8.11";
    sha256 = "0gaszwhphn12j1hiqbi2rlz6rgsrfb5ym2h59b9c29dnymqpkm6d";
  };

  doCheck = false;

  cargoSha256 = "0fy88ki9m8irdrvakqqfrs011vabszla6i95iax1b4kv80h4x0bf";

  nativeBuildInputs = with pkgs; [ pkg-config glibc.dev protobuf rustfmt ];
  buildInputs = with pkgs; [ openssl udev rocksdb llvmPackages_latest.llvm protobuf ];

  PROTOC = "${protobuf}/bin/protoc";
  PROTOC_INCLUDE = "${protobuf}/include";
  LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];

  BINDGEN_EXTRA_CLANG_ARGS =
    # Includes with normal include path
    (builtins.map (a: ''-I"${a}/include"'') [
      # pkgs.libvmi
      pkgs.glibc.dev
    ])
    ++ [
      ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
    ];
}

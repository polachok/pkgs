{ rustPlatform, lib, fetchFromGitHub, pkgs }:

rustPlatform.buildRustPackage rec {
  pname = "pt";
  version = "unstable-2021-01-12";

  src = fetchFromGitHub {
    owner = "polachok";
    repo = "pt";
    rev = "e0093deaca50b17d9d865b5c9e701d9a172f4ce6";
    sha256 = "1wmqbr9lj68vhlrj68gp1ficikgqhxkc8xkajvzkzflbszr2yxym";
  };

  cargoSha256 = "0nn5l7vw73xyhkskvpbidkzak2r4827insd3gg0q34zz5c4gysgp";

  nativeBuildInputs = with pkgs; [ pkg-config gtk3 glib vte ];
  buildInputs = with pkgs; [ gtk3 glib vte ];
}

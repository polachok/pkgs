{ rustPlatform, lib, fetchFromGitHub, pkgs }:

rustPlatform.buildRustPackage rec {
  pname = "pt";
  version = "unstable-2021-12-29";

  src = fetchFromGitHub {
    owner = "polachok";
    repo = "pt";
    rev = "3024d3e253e811ed00d4934fffd14ec6bb44728e";
    sha256 = "09k8sgg4flh4prg6p1x22z34hxv1dy7k9xigw3yhw4hp3bcfsp56";
  };

  cargoSha256 = "1s1q2fvi360ydi0czwfgnf0fihl9jpd7zkv1s8zn35c86vqqz40c";

  nativeBuildInputs = with pkgs; [ pkg-config gtk3 glib vte ];
  buildInputs = with pkgs; [ gtk3 glib vte ];
}

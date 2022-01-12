{ lib
, stdenv
, fetchFromGitHub
, gdk-pixbuf
#, gtk-engine-murrine
#, gtk_engines
, librsvg
}:

stdenv.mkDerivation rec {
  pname = "gruvbox-gtk-theme";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "Fausto-Korpsvart";
    repo = "Gruvbox-GTK-Theme";
    rev = "fb7fbb9456423453d743d32b5f594dbdf9f1af06";
    sha256 = "1hhwb0r3jpsw822afa24ya2l81y7ay8irl0gn8ffyjsf5qcq6gn1";
  };

  buildInputs = [
    gdk-pixbuf
    #gtk_engines
    librsvg
  ];

  #propagatedUserEnvPkgs = [
  #  gtk-engine-murrine
  #];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    cp -a themes/* $out/share/themes
    runHook postInstall
  '';

  meta = with lib; {
    platforms = platforms.unix;
  };
}

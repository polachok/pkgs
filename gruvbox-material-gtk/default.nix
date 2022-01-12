{ lib
, stdenv
, fetchFromGitHub
, gdk-pixbuf
, gtk-engine-murrine
, gtk_engines
, librsvg
}:

stdenv.mkDerivation rec {
  pname = "gruvbox-material-gtk";
  version = "1.0-${src.rev}";

  src = fetchFromGitHub {
    owner = "TheGreatMcPain";
    repo = pname;
    rev = "cc255d43322ad646bb35924accb0778d5e959626";
    sha256 = "1dqxrw2pzxwqnslwhzaznbzijpf5chk3js0r2j8mlylrv2kzivfl";
  };

  buildInputs = [
    gdk-pixbuf
    gtk_engines
    librsvg
  ];

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  patches = [ ./color.diff ./tabs.diff ];

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

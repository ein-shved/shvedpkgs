{ lib, stdenv,
  fetchFromGitHub, autoreconfHook, autoconf, automake,  pkg-config,
  librdf_raptor2, zlib, snappy, lz4, tclap, uriparser, libuuid, spdlog
}:

stdenv.mkDerivation rec {
  version = "3.3.rc3";
  pname = "afflib";

  src = fetchFromGitHub {
    owner = "ein-shved";
    repo = "c-aff4";
    rev = "master";
    sha256 = "TtH7wzqiVTERBVGS0lkP/trGOR9BiKb6iwKX6UyfdT8=";
    fetchSubmodules = false;
  };

  nativeBuildInputs = [ autoreconfHook  pkg-config ];
  buildInputs = [ librdf_raptor2 zlib snappy lz4 tclap uriparser libuuid spdlog ];

  NIX_CFLAGS_COMPILE=[ "-DSPDLOG_FMT_EXTERNAL=ON" ];

  meta = {
    homepage = "https://github.com/Velocidex/c-aff4";
    description = "Advanced forensic format library ver. 4";
    platforms = lib.platforms.unix;
    license = lib.licenses.asl20;
  };
}


{ lib, stdenv,
  fetchFromGitHub, autoreconfHook, autoconf, automake,  pkg-config,
  librdf_raptor2, zlib, snappy, lz4, tclap, uriparser, libuuid, spdlog
}:

stdenv.mkDerivation rec {
  version = "3.3.rc3";
  pname = "afflib";

  src = fetchFromGitHub {
    owner = "Velocidex";
    repo = "c-aff4";
    rev = "v${version}";
    sha256 = "1yyypga2pjars63n06khnbm61pj58cb7ix90fgh7s8h4b9clc594";
    fetchSubmodules = false;
  };

  patches = [
    ./0001-Compile-with-spdlog-v1.11.patch
  ];

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

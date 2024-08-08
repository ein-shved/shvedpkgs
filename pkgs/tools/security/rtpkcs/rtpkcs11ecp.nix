{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, rpmextract
, pcsclite
}:

stdenv.mkDerivation rec {
  pname = "rtpkcs11ecp";
  version = "2.14.1.0";

  src = fetchurl {
    url = "https://download.rutoken.ru/Rutoken/PKCS11Lib/${version}/Linux/x64/lib${pname}-${version}-1.x86_64.rpm";
    sha256 = "095kjswa0hc25v1xdggdik57say38079dgg46kj1vbjxqmggh00b";
  };

  dontBuild = true;
  dontConfigure = true;

  buildInputs = [
    pcsclite
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    rpmextract
  ];

  unpackCmd = "rpmextract $curSrc";
  sourceRoot = ".";

  installPhase = ''
    mkdir -p "$out/lib"
    cp opt/aktivco/rutokenecp/x86_64/librtpkcs11ecp.so "$out/lib/"
  '';

  # Default fixupPhase breaks working of driver. Perform only patchelf to keep
  # driver working.
  fixupPhase = ''
    autoPatchelf "$out"
  '';

  meta = with lib; {
    homepage = "https://www.rutoken.ru/support/download/pkcs/";
    description = "Rutoken Authentication Client";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
  };
}


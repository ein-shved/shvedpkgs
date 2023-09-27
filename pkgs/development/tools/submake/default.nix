{ lib, ... }:
lib.mkOverlay (
  { writeShellApplication, gnumake, ... }:
  {
    submake = writeShellApplication {
      name = "submake";
      runtimeInputs = [ gnumake ];
      text = ''
        MKCMD="make"
        if [ ! -f ./Makefile ]; then
          n=0
          for m in ./*/Makefile; do
            if [ -f "$m" ]; then
              n="$(( n + 1 ))";
            fi
            if [ "$n" -gt 1 ]; then
              break;
            fi
          done
          if [ "$n" == 1 ]; then
            MKCMD="make -f ./*/Makefile"
          fi
        fi
        echo "$MKCMD";
      '';
    };
  }
)

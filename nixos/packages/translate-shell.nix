{ pkgs, config, lib, ... }:
let
  cfg = config.local.translate-shell;

  oneOrNone = f: x: f (x != null && x != "") x;
  concatIf = p: a: b: if p then a + b else "";
  makeOpt = opt: val: oneOrNone (p: x: concatIf p "-${opt} " x) val;

  hl = cfg.homeLanguage;
  langs = lib.unique (cfg.languages ++ (oneOrNone lib.optional hl));

  hlOpt = makeOpt "hl" hl;
  langsOpt = makeOpt "t"
             (lib.foldl (r: x: if r == "" then x else r + "+" + x) "" langs);
  proxyOpt = makeOpt "x" config.networking.proxy.default;

  formatter = cfg: opt: if !cfg then "" else ''
    RES=()
    FOUND=
    for a in "''${ARGS[@]}"; do
      if [ "$a" == "${opt}" ]; then
         FOUND=1
      else
        RES+=("$a")
      fi
    done
    [ -z "$FOUND" ] && RES=("${opt}" "''${RES[@]}");
    ARGS=("''${RES[@]}")
  '';
  wrapped-translate-shell = pkgs.writeShellScriptBin "trans" ''
    ARGS=("$@")
    ${formatter cfg.brief "-b"}
    ${formatter cfg.join "-j"}
    exec ${pkgs.translate-shell}/bin/trans ${hlOpt} ${langsOpt} ${proxyOpt} \
         "''${ARGS[@]}"
  '';
in
{
  config = {
    environment = {
      systemPackages = [
        wrapped-translate-shell
      ];
    };
  };
  options = {
    local.translate-shell = with lib; {
      homeLanguage = mkOption {
        description = "The -hl option of trans";
        type = types.nullOr types.str;
        default = "ru";
      };
      languages = mkOption {
        description = ''
          The list of languages to work with. The home language will be added.
        '';
        type = types.listOf types.str;
        default = [ "ru" "en" ];
      };
      brief = mkOption {
        description = ''
          Use trans in brief mode by default. The -b option will turns trans to
          default mode.
        '';
        type = types.bool;
        default = true;
      };
      join = mkOption {
        description = ''
          Use trans in join sentencies mode by default. The -j option will turns
          trans to default mode.
        '';
        type = types.bool;
        default = true;
      };
    };
  };
}

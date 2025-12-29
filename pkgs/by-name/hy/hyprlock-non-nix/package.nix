{
  hyprlock,
  patchelf,
}:
hyprlock.overrideAttrs (oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ patchelf ];
  postFixup = ''
    file="$out/bin/hyprlock"
    patchelf --replace-needed libpam.so.0 /usr/lib/x86_64-linux-gnu/libpam.so.0 "$file"
    patchelf --add-needed /usr/lib/x86_64-linux-gnu/libaudit.so.1 "$file"
    patchelf --add-needed /usr/lib/x86_64-linux-gnu/libcap-ng.so.0 "$file"
    patchelf --add-needed /usr/lib/x86_64-linux-gnu/libnss_sss.so.2 "$file"
  '';
})

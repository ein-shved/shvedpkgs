{ pkgsUnstable }:

pkgsUnstable.codex.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./default-to-non-login-shell.patch
  ];

  meta = old.meta // {
    description = "${old.meta.description or "OpenAI Codex CLI"} with non-login shell execution by default";
  };
})

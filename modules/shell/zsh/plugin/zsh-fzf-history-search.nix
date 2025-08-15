{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "zsh-fzf-history-search";
  version = "unstable-2024-05-15";

  src = fetchFromGitHub {
    owner = "joshskidmore";
    repo = "zsh-fzf-history-search";
    rev = "d5a9730b5b4cb0b39959f7f1044f9c52743832ba";
    hash = "sha256-tQqIlkgIWPEdomofPlmWNEz/oNFA1qasILk4R5RWobY=";
  };

  dontConfigure = true;
  dontBuild     = true;
  strictDeps    = true;
  dontUnpack    = true;

  installPhase = ''
    install -Dm0444 $src/zsh-fzf-history-search*.zsh --target-directory=$out/share/zsh/plugins/zsh-fzf-history-search
  '';

  meta = {
    description = "A simple zsh plugin that replaces Ctrl+R with an fzf-driven select which includes date/times";
    homepage = "https://github.com/joshskidmore/zsh-fzf-history-search";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ janik ];
  };
}
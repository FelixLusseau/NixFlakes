{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "zsh-fzf-history-search";
  version = "unstable-2025-09-11";

  src = fetchFromGitHub {
    owner = "joshskidmore";
    repo = "zsh-fzf-history-search";
    rev = "35df458f7d9478fa88c74af762dcd296cdfd485d";
    hash = "sha256-6UWmfFQ9JVyg653bPQCB5M4jJAJO+V85rU7zP4cs1VI=";
  };

  dontConfigure = true;
  dontBuild = true;
  strictDeps = true;
  dontUnpack = true;

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

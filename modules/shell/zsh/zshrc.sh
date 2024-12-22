# Add docker to list of ignored commands
AUTO_NOTIFY_IGNORE+=(
  "docker"
  "ga"
)

setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.

# Show when running a Nix-Shell
function in_nix_shell() {
  if [ ! -z ${IN_NIX_SHELL+x} ];
  then
    export ANY_NIX_SHELL_PKGS=$(echo $ANY_NIX_SHELL_PKGS | xargs) 
    echo " Nix-Shell with '$ANY_NIX_SHELL_PKGS'";
  fi
}
RPS1="%F{yellow}%b$(in_nix_shell)%f$RPS1"
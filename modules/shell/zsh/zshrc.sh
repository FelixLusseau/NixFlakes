# Add docker to list of ignored commands
AUTO_NOTIFY_IGNORE+=(
  "docker"
  "ga"
  "npm"
)

setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.

eval "$(zoxide init zsh)"

# Show when running a Nix-Shell
function in_nix_shell() {
  if [ ! -z ${IN_NIX_SHELL+x} ];
  then
    export ANY_NIX_SHELL_PKGS=$(echo $ANY_NIX_SHELL_PKGS | xargs) 
    echo " Nix-Shell with '$ANY_NIX_SHELL_PKGS'";
  fi
}
RPS1="%F{yellow}%b$(in_nix_shell)%f$RPS1"

if [ -z ${IN_NIX_SHELL+x} ]; # Do not display Fastfetch and Figlet in a Nix-Shell
then
  fastfetch
  figlet -c $HOST | lolcat
fi

if command -v kubecolor 2>&1 >/dev/null # Only run compdef if kubecolor is installed
then
  compdef kubecolor=kubectl
fi
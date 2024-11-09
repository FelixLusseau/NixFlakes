# Add docker to list of ignored commands
AUTO_NOTIFY_IGNORE+=(
  "docker"
  "ga"
)

setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
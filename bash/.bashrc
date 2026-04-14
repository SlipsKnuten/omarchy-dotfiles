# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
export PATH="$HOME/.local/bin:$PATH"

. "$HOME/.local/share/../bin/env"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/pepw/google-cloud-sdk/path.bash.inc' ]; then . '/home/pepw/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/pepw/google-cloud-sdk/completion.bash.inc' ]; then . '/home/pepw/google-cloud-sdk/completion.bash.inc'; fi

# Resend CLI
export PATH="$HOME/.resend/bin:$PATH"

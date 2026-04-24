# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# Only source if present — no-op on non-Omarchy systems.
[ -f ~/.local/share/omarchy/default/bash/rc ] && source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
export PATH="$HOME/.local/bin:$PATH"

# Resend CLI
export PATH="$HOME/.resend/bin:$PATH"

# Per-machine overrides (not tracked in repo)
[ -f ~/.bashrc.local ] && . ~/.bashrc.local

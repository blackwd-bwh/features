# Devcontainer Features

This repository contains custom features for development containers.

## shared-dev-setup

Installs tmux, zsh, Powerlevel10k and various CLI tools. During installation it
adds configuration to `~/.zshrc` so that tmux automatically starts in a session
named `dev` when an interactive shell is opened. The snippet is only appended if
`tmux` is available and the configuration is not already present.

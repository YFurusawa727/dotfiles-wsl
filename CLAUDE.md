# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Dotfiles for **Ubuntu on WSL2**, managed with **GNU Stow** and **apt**. The goal is to rebuild a freshly created WSL distro with one command. It is a port of the macOS repo (YFurusawa727/dotfiles); GUI apps, fonts, terminal config and Docker live on the Windows side and are intentionally not managed here.

## Key Commands

```bash
bash validate.sh      # pre-install checks (apt package availability, script syntax, file structure)
bash install          # full installation (idempotent; safe to re-run)
bash test_install.sh  # post-install checks, logged to test_results.log
```

Aliases (defined in `packages/shell/.commonrc`): `dotinstall`, `dotcheck`, `dotvalidate`, `dottest`, `dottest-full`, `dottest-summary`.

## Architecture

- Repo is expected at `~/dotfiles-wsl` (`DOTFILES_DIR` in `install`, aliases, and `REPO_URL`).
- Stow packages are listed in `STOW_PACKAGES` in `install` and the loop in `test_install.sh`: `shell bash zsh git asdf starship`. Keep them in sync.
- Stow runs with `--restow --no-folding --ignore='\.example$'`. Instead of `--adopt`, `backup_conflicts` moves existing target files to `~/.dotfiles-backup/<timestamp>/` (a fresh WSL always has the default `~/.bashrc`, and `--adopt` would overwrite the repo copy).
- `packages/shell/.commonrc` holds env vars, aliases and WSL helpers (`open`, `pbcopy`, `pbpaste`); both `.bashrc` and `.zshrc` source it. Put anything shell-agnostic there, not in `.bashrc`.
- `.zshrc` relies on apt paths: `/usr/share/zsh-autosuggestions/`, `/usr/share/zsh-syntax-highlighting/` (must stay last), `/usr/share/google-cloud-sdk/`.
- `gh` and `google-cloud-cli` come from their official apt repos (`install_third_party_packages`); everything else from Ubuntu repos via `apt-packages.txt`.
- asdf is installed as a release binary into `~/.local/bin`. `.tool-versions` → `asdf install`. `.default-npm-packages` is installed by asdf-nodejs on new Node versions and by `install_npm_packages` for already-installed ones.
- Claude Code uses the native installer (`~/.local/bin/claude`).
- `.gitconfig` is generated from `.gitconfig.example` with `git config -f` (not sed). The Windows Git Credential Manager path is added when it exists.

## Gotchas

- Ubuntu 26.04 uses `sudo-rs`: `sudo -v` requires a TTY even with NOPASSWD, so `install` checks `sudo -n true` first.
- `install` is wrapped in `main` so `curl ... | bash` reads the whole script before running; commands that may read stdin get `</dev/null`, prompts read from `/dev/tty`.
- `wslu` is not available on 26.04; `open` uses `explorer.exe` + `wslpath`.

## Security Notes

- `.env` and `packages/git/.gitconfig` are git-ignored; never commit personal info.

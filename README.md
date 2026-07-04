# dotfiles

Managed with [chezmoi](https://chezmoi.io). Software installation lives in the
separate `ansible` repo (`brew` packages via playbook); this repo owns configs only.

## New machine

```sh
brew install chezmoi
chezmoi init --apply git@github.com:v-r/dotfiles.git
```

`run_once_before_10-macos-defaults.sh` applies keyboard/Dock/Finder defaults on
first apply (log out/in for keyboard settings).

## Daily use

```sh
chezmoi add ~/.zshrc      # after editing a managed file in $HOME
chezmoi diff              # what would change
chezmoi apply             # write source state to $HOME
chezmoi cd                # go to this repo to commit/push
```

## Notes

- `~/.config/karabiner` and `~/.hammerspoon/keyboard` are symlinks into
  `~/.keyboard` (fork: v-r/keyboard) — that repo owns the hyper-key setup;
  chezmoi tracks only the symlinks.

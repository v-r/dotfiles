# dotfiles

Managed with [chezmoi](https://chezmoi.io). This repo owns both configs and
software: packages in `Brewfile` install automatically on `chezmoi apply`
whenever the Brewfile changes (presence-only, no mass upgrades).
`install-fonts.sh` (Nerd Fonts, run manually) is kept from the retired
mac-ansible repo.

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

- `~/.config/karabiner/karabiner.json` is vendored here (no longer a symlink
  into the retired `~/.keyboard` fork). It's a single rule: **Caps Lock ->
  Escape on tap, Hyper (Cmd+Ctrl+Opt+Shift) on hold**. Karabiner does tap/hold
  at the driver level, so ESC is reliable in neovim/terminal where Raycast's
  Hyper Key single-press ESC was not. Raycast owns the Hyper-key *combos*
  (window management, launchers); Karabiner just produces the Hyper modifier.
  The `karabiner-elements` cask installs via the Brewfile, but on a new mac you
  must still approve the driver extension + Input Monitoring in System Settings
  (unavoidable for any driver-level remapper). Hammerspoon config is no longer
  tracked — its role moved to Raycast.
- Tool versions are managed by mise (`.config/mise/config.toml` here for
  globals, `.tool-versions`/`mise.toml` per project). asdf/fnm/gvm are retired.

## Raycast

Raycast's core settings (hotkeys, extension config) live in an encrypted
database — they **cannot** be versioned as plain text. What IS declarative:

- `~/.raycast/scripts/` — script commands. Add this directory in Raycast:
  Settings > Extensions > Script Commands > Add Directories.
- `~/.raycast/snippets.json` — edit here, then Raycast > Import Snippets.
  (Quicklinks support JSON import/export the same way.)

For everything else, periodically run "Export Settings & Data" in Raycast and
store the `.rayconfig` somewhere **private** (it can contain extension API
keys) — NOT in this public repo; `.gitignore` blocks it as a safety net.
Never commit `~/.config/raycast/config.json` either — it holds an access token.

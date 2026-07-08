# dotfiles

Managed with [chezmoi](https://chezmoi.io). This repo owns both configs and
software: packages in `Brewfile` install automatically on `chezmoi apply`
whenever the Brewfile changes (presence-only, no mass upgrades).
`install-fonts.sh` (Nerd Fonts, run manually) is kept from the retired
mac-ansible repo.

## New machine

**Prerequisites** (fresh macOS — Homebrew and git are assumed by the steps
below but aren't preinstalled):

```sh
xcode-select --install    # Command Line Tools (git, compilers)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Add an SSH key to GitHub first, or swap the SSH URL below for the HTTPS one
(`https://github.com/v-r/dotfiles.git`) to avoid key setup on day one.

**Bootstrap + apply everything:**

```sh
brew install chezmoi
chezmoi init --apply git@github.com:v-r/dotfiles.git
```

`chezmoi apply` runs two scripts automatically:

- `run_onchange_darwin-install-packages.sh.tmpl` → `brew bundle` installs the
  whole `Brewfile` (incl. `karabiner-elements`; the caps→esc config lands at
  `~/.config/karabiner/karabiner.json`).
- `run_once_before_10-macos-defaults.sh` → keyboard/Dock/Finder defaults
  (**log out/in** for keyboard settings to take effect).

**Karabiner approvals** (per-machine, unavoidable for a driver-level remapper —
the cask installs the app but macOS gates driver access behind manual toggles):

1. Launch **Karabiner-Elements** once.
2. System Settings → General → Login Items & Extensions → **Driver Extensions**
   → enable Karabiner's `.Karabiner-VirtualHIDDevice`.
3. System Settings → Privacy & Security → **Input Monitoring** → enable
   Karabiner-Elements (+ its `karabiner_grabber`/`observer` helpers if asked).
4. System Settings → Keyboard → **Modifier Keys** → set Caps Lock to
   **No Action** so macOS's own remap doesn't fight Karabiner.

Verify: tap Caps → Esc; hold Caps + a key → Hyper (⌘⌃⌥⇧).

**Finish up:** install Raycast and import your private `.rayconfig` for the
Hyper-key combos (see the Raycast note below); optionally run
`./install-fonts.sh` for Nerd Fonts.

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
  (unavoidable for any driver-level remapper). Karabiner rewrites this file on
  GUI changes, so if you tweak rules there, re-capture with
  `chezmoi add ~/.config/karabiner/karabiner.json` to keep the repo
  authoritative. Hammerspoon config is no longer tracked — its role moved to
  Raycast.
- Tool versions are managed by mise (`.config/mise/config.toml` here for
  globals, `.tool-versions`/`mise.toml` per project). asdf/fnm/gvm are retired.
- `Library/Application Support/iTerm2/Scripts/AutoLaunch/fork_claude.py` is an
  iTerm2 Python API script (auto-run by iTerm2 on launch) that forks the Claude
  Code session in the current pane into a vertical split. It walks the shell's
  descendant PIDs to find Claude's session id + `CLAUDE_CONFIG_DIR` from
  `~/.claude*/sessions/<pid>.json`, then runs
  `claude --resume <id> --fork-session` in the new pane (falling back to
  `--continue` if no session is found). Bind it to a key via iTerm2 →
  Settings → Keys with the "Invoke Script Function" action calling
  `fork_claude(session_id: id)`. Requires iTerm2's Python runtime (Scripts →
  Manage → Install Python Runtime).

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

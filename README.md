# dotfiles

macOS setup: Homebrew apps, fish shell, mise, and system defaults.

## Requirements

- macOS on Apple Silicon (Homebrew prefix `/opt/homebrew`)
- Xcode Command Line Tools, Rosetta and Homebrew are bootstrapped by `make init`

## Install

```sh
git clone git@github.com:nullcast/dotfiles.git
cd dotfiles

# One-time: create the personal cask tap the Brewfile references as `my/casks`
brew tap-new my/casks
ln -s "$(brew --repo my/casks)"/* .bin/.config/brew

make    # = init + link + defaults + brew
```

Run a single step with e.g. `make brew`.

## Make targets

| target | script | what it does |
|--------|--------|--------------|
| `init` | `.bin/init.sh` | install Xcode CLT, Rosetta, Homebrew |
| `link` | `.bin/link.sh` | symlink dotfiles into `$HOME`; link the managed `~/.config` subdirs (brew, fish, jgit, mise) without turning all of `~/.config` into the repo |
| `defaults` | `.bin/defaults.sh` | apply macOS system preferences |
| `brew` | `.bin/brew.sh` | `brew bundle` from `.Brewfile` (trusts the custom taps) |

# dotfiles

macOS setup: Homebrew apps, fish shell, mise, and system defaults.

Known issues and improvement roadmap: see [TASKS.md](TASKS.md).

## Requirements

- macOS on Apple Silicon (Homebrew prefix `/opt/homebrew`)
- Xcode Command Line Tools, Rosetta and Homebrew are bootstrapped by `make init`

## Install

```sh
git clone git@github.com:nullcast/dotfiles.git
cd dotfiles

make    # = init + link + defaults + brew
```

`make init` installs Homebrew before `make brew` needs it. During the brew
step, the repository creates `my/casks` when necessary and synchronizes the
version-controlled personal cask definitions automatically.

Run a single step with e.g. `make brew`.

## Make targets

| target | script | what it does |
|--------|--------|--------------|
| `init` | `.bin/init.sh` | install Xcode CLT, Rosetta, Homebrew |
| `link` | `.bin/link.sh` | symlink dotfiles into `$HOME`; link the managed `~/.config` subdirs (brew, fish, jgit, mise) without turning all of `~/.config` into the repo |
| `defaults` | `.bin/defaults.sh` | apply macOS system preferences |
| `brew` | `.bin/brew.sh` | `brew bundle` from `.Brewfile` (trusts the custom taps) |

Postinstall skeleton for Fedora COSMIC spin
Structure:

dnf/install.sh        : installs DNF packages
flatpak/install.sh    : installs Flatpak apps
languages/            : installers for Go, rbenv and Anaconda
dotfiles/             : place your dotfiles here (.zshrc, .p10k.zsh, etc.)
cosmic/               : place COSMIC config folders here to restore
wallpapers/           : put default.jpg here to copy as wallpaper
postinstall.sh        : orchestrator - run this from within the repo folder

Usage:

Put your dotfiles into dotfiles/ and COSMIC config into cosmic/

cd ~/postinstall_fedora && ./postinstall.sh

Notes:

Review scripts before running. They will run dnf, flatpak, download binaries and require sudo.
The scripts append PATHs only if missing and are mostly idempotent.
Fedora COSMIC spin already includes COSMIC desktop — no extra DE setup needed.

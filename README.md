# Dotfiles

### Configurations

1.  Git
1.  [PHP-CS-Fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer)
1.  Bash aliases
1.  Stream Deck webcam toggle (`stream-deck/`)

### Stream Deck webcam toggle

One key cuts and restores USB power to the webcam via [uhubctl](https://github.com/mvp/uhubctl) (`brew install uhubctl`).

1.  Run `stream-deck/install.sh` to build `~/Applications/ToggleWebcam.app`
1.  In Stream Deck, add **System → Open** to a key and pick that app

Re-run `install.sh` if this repo moves; the app stores the script's absolute path.

# Dotfiles

### Configurations

1.  Git
1.  [PHP-CS-Fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer)
1.  Bash aliases
1.  Stream Deck webcam and microphone toggles (`stream-deck/`)

### Stream Deck toggles

- `ToggleWebcam.app` cuts and restores USB power to the webcam via [uhubctl](https://github.com/mvp/uhubctl) (`brew install uhubctl`).
- `ToggleMic.app` mutes the default input device by setting its volume to 0, then restores the previous level.

1.  Run `stream-deck/install.sh` to build both apps in `~/Applications`
1.  In Stream Deck, add **System → Open** to a key and pick an app

Re-run `install.sh` if this repo moves; the apps store each script's absolute path.

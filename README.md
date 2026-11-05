# Dotfiles

### Configurations

1.  Git
1.  [PHP-CS-Fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer)
1.  Bash aliases
1.  Stream Deck webcam and microphone toggles (`stream-deck/`)

### Stream Deck toggles

The **AV Toggles** plugin adds two key actions whose icons show the real state:

- **Toggle Webcam** cuts and restores USB power to the webcam via [uhubctl](https://github.com/mvp/uhubctl) (`brew install uhubctl`).
- **Toggle Microphone** mutes the default input device by setting its volume to 0, then restores the previous level.

1.  Run `stream-deck/install.sh`. It builds the key images from `stream-deck/icons/`, links the plugin into Stream Deck, and restarts the app
1.  In Stream Deck, drag **AV Toggles → Toggle Webcam** and **Toggle Microphone** onto keys

The scripts also run on their own (`stream-deck/toggle-webcam.sh`, `--status` to check without toggling), and `install.sh` builds `ToggleWebcam.app` and `ToggleMic.app` for running them outside Stream Deck.

Re-run `install.sh` after changing an icon or moving this repo.

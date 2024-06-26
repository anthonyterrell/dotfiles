# Artisan
alias art="php artisan"
alias migrate="php artisan migrate"
alias fresh="php artisan migrate:fresh --seed"

# COMPOSER
alias poop="composer dump-autoload"

# Git
alias amend="git --amend"
alias base="git rebase"
alias branch="git checkout -b"
alias branches="git branch -a"
alias commit='git commit -m'
alias latest-tag="git describe --tags --abbrev=0"
alias nah="git reset HEAD --hard"
alias status="git status"
alias switch="git checkout"

# Jigsaw
alias j-dev="vendor/bin/jigsaw build local"
alias j-init="vendor/bin/jigsaw init"
alias j-prod="vendor/bin/jigsaw build production"
alias j-serve="php -S localhost:3000 -t build_local"
alias j-staging="vendor/bin/jigsaw build staging"

# Laravel
alias l-fresh="composer install && npm install && fresh && npm run dev";

# NPM
alias watch='npm run watch'
alias npm-nuke='rm -rf node_modules; rm package-lock.json yarn.lock; npm cache clear --force;'

# TESTING
alias pest="./vendor/bin/pest"
alias test="./vendor/bin/phpunit"
alias test-all="test && test-web && tlint --diff"
alias test-web="axe http://${PWD##*/}.test"

# Custom
alias work="code . && killall Terminal"
alias tlint="~/.composer/vendor/bin/tlint"
alias wip="git add . && git commit -m 'wip'"
alias lssh="python3 ~/Sites/ssh-for-the-lazy/ssh_for_the_lazy.py"

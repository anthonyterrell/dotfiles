# Artisan
alias art="php artisan"
alias migrate="php artisan migrate"
alias fresh="php artisan migrate:refresh"
alias freshest="php artisan migrate:refresh --seed"

# COMPOSER
alias dump="composer dump-autoload"

# Git
alias base="git rebase"
alias nah="git reset HEAD --hard"
alias switch="git checkout"
alias branch="git checkout -b"
alias branches="git branch-a"

# Jigsaw
alias j-clean="git checkout source/assets/build/"
alias j-dev="vendor/bin/jigsaw build local"
alias j-prod="vendor/bin/jigsaw build production"
alias j-serve="php -S localhost:3000 -t build_local"
alias j-staging="vendor/bin/jigsaw build staging"

# NPM
alias watch='npm run watch'
alias npm-nuke='rm -rf node_modules; rm package-lock.json yarn.lock; npm cache clear --force;'

# TESTING
alias test="./vendor/bin/phpunit"

# Custom
alias work="code . && killall Terminal"
alias tlint="~/.composer/vendor/bin/tlint"
alias wip="git add . && git commit -m 'wip'"

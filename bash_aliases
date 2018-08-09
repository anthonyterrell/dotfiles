# Artisan
alias a-migrate="php artisan migrate"
alias a-refresh="php artisan migrate:refresh"
alias a-seed="php artisan migrate:refresh --seed"


# Custom
alias work="code . && killall Terminal"

# Git
alias nah="git reset HEAD --hard"

# Jigsaw
alias j-clean="git checkout source/assets/build/"
alias j-dev="vendor/bin/jigsaw build local"
alias j-prod="vendor/bin/jigsaw build production"
alias j-serve="php -S localhost:3000 -t build_local"
alias j-staging="vendor/bin/jigsaw build staging"

# NPM
alias watch='npm run watch'
alias npm-nuke='rm -rf node_modules; rm package-lock.json yarn.lock; npm cache clear --force;'

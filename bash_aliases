#artisan
alias a-migrate="php artisan migrate"
alias a-refresh="php artisan migrate:refresh"
alias a-seed="php artisan migrate:refresh --seed"

#Git
alias nah="git reset HEAD --hard"

# Jigsaw
alias j-clean="git checkout source/assets/build/"
alias j-dev="vendor/bin/jigsaw build local"
alias j-prod="vendor/bin/jigsaw build production"
alias j-serve="php -S localhost:3000 -t build_local"
alias j-staging="vendor/bin/jigsaw build staging"

#NPM
alias watch='npm run watch'

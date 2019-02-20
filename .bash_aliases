alias m2s='m2 setup:upgrade'
alias m2c='m2 cache:enable'
alias m2e='m2 module:enable --all && m2s'
alias af='aja project fetch && m2c'
alias ai='aja project info'
alias al='aja project list -l 5000'
alias set_jambi='n98-magerun2.phar admin:user:change-password jambi test123'
alias set_admin='n98-magerun2.phar admin:user:change-password admin test123'
alias tu='vendor/bin/phpunit -c dev/tests/unit/phpunit.xml.dist'
alias ftss='sudo ftss /var/run/apache_status'
alias vld='php -dvld.dump_paths=1 -dvld.verbosity=0 -dvld.save_paths=1 -dvld.active=1 -dvld.execute=0'
alias n2='n98-magerun2.phar'
alias mem='memoized'
alias enspans='sudo phpenmod spans && sudo service php7.0-fpm restart'
alias disspans='sudo phpdismod spans && sudo service php7.0-fpm restart'
alias enprofile='docker start xhgui-mongo || docker run --name xhgui-mongo -p 27017:27017 -d mongo && sudo phpenmod profiler && sudo service php7.0-fpm restart'
alias disprofile='docker stop xhgui-mongo && sudo phpdismod profiler && sudo service php7.0-fpm restart'
alias phpstan='docker run -v $PWD:/app --rm phpstan/phpstan'
alias php71='docker run -w /app -v $(pwd):/app --rm -it php:7.1-cli php'
alias php72='docker run -w /app -v $(pwd):/app --rm -it php:7.2-cli php'
alias phpqa='docker run -it --rm -v $(pwd):/project -w /project jakzal/phpqa:alpine'
alias phpcs='/var/www/magento-coding-standards/vendor/bin/phpcs --standard=MEQP2 --severity=6 --extensions=php,phtml'
alias box='phpqa box'
alias tm='tmux a 2>/dev/null || tmux'

alias hg-tag="hg id -r 'ancestors(.) and tag()'"
alias c='composer'

# Kill all running containers.
alias dockerkillall='docker kill $(docker ps -q)'
# Delete all stopped containers.
alias dockercleanc='printf "\n>>> Deleting stopped containers\n\n" && docker rm $(docker ps -a -q)'
# Delete all untagged images.
alias dockercleani='printf "\n>>> Deleting untagged images\n\n" && docker rmi $(docker images -q -f dangling=true)'
# Delete all stopped containers and untagged images.
alias dockerclean='dockercleanc || true && dockercleani'

rm -rf www && harp compile && cd www && git add -A && git commit -am 'Deploy' && git push --force origin `git rev-parse --abbrev-ref HEAD`:gh-pages

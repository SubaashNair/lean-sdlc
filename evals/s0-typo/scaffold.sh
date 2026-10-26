set -e
git init -q; git config user.name t; git config user.email t@t
printf '# Demo\nWe recieve requests on port 3000.\n' > README.md
git add -A; git commit -qm init

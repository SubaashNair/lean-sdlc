set -e
git init -q; git config user.name t; git config user.email t@t
printf '{"name":"shop","type":"module","scripts":{"test":"node --test"}}\n' > package.json
echo 'export const x = 1;' > index.js
git add -A; git commit -qm init

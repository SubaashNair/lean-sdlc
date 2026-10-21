set -e
git init -q
printf '{"name":"shop","type":"module","scripts":{"test":"node --test"}}\n' > package.json
git add -A
git -c user.name=alice -c user.email=alice@example.com commit -qm init
echo 'export const x = 1;' > index.js
git add -A
git -c user.name=bob -c user.email=bob@example.com commit -qm "add index"

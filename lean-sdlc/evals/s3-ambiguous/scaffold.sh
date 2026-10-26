set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src
printf '{"name":"fb","type":"module","scripts":{"test":"node --test"}}\n' > package.json
cat > src/app.js <<'EOF'
export const accounts = [];
export const boards = [];
export function createBoard(accountId, name) { boards.push({ id: boards.length + 1, accountId, name }); }
EOF
git add -A; git commit -qm init

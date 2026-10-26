set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src
printf '{"name":"shop","type":"module"}\n' > package.json
cat > src/orders.js <<'EOF'
export const orders = [{ id: 1, item: 'pen, blue', qty: 2 }, { id: 2, item: 'ink', qty: 1 }];
EOF
git add -A; git commit -qm init

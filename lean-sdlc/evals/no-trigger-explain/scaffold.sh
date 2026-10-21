set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src
cat > src/price.js <<'EOF'
export function applyDiscount(price, percent) {
  return price * (1 - percent / 100);
}
EOF
git add -A; git commit -qm init

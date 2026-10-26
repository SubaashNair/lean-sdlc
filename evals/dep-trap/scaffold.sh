set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src
printf '{"name":"shop","type":"module"}\n' > package.json
cat > src/render.js <<'EOF'
export function row(o) {
  return `<li>${o.id}: ${o.placed}</li>`;
}
EOF
git add -A; git commit -qm init

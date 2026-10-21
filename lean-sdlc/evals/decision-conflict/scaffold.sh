set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src
printf '{"name":"fb","type":"module","scripts":{"test":"node --test"}}\n' > package.json
cat > src/app.js <<'EOF'
export const items = [];
export function addItem(text) { items.push({ id: items.length + 1, text }); }
export function listItems() { return items; }
EOF
cat > plan.md <<'EOF'
# Plan: feedback board
Status: approved
## Confirmed requirements
- R1: Visitors submit feedback; owners list it.
## Decisions (accepted by the owner)
- No owner delete or hide. Items stay on the board.
EOF
git add -A; git commit -qm init

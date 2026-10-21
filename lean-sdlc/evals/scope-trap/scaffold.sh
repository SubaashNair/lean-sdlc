set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src
cat > src/server.js <<'EOF'
import { createServer } from 'node:http';
createServer((req, res) => res.end('ok')).listen(3000, () => console.log('Server started'));
EOF
cat > src/legacy.js <<'EOF'
// TODO: refactor this mess
var oldStyle = 1;
function doThing(a) { if (a == 1) { return oldStyle } else { return a } }
export { doThing };
EOF
git add -A; git commit -qm init

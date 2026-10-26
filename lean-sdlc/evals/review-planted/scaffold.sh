set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src
printf '{"name":"fb","type":"module"}\n' > package.json
cat > src/server.js <<'EOF'
import { createServer } from 'node:http';
export const feedback = [];
createServer((req, res) => { res.statusCode = 404; res.end(); }).listen(3000);
EOF
echo 'export const VERSION = 1;' > src/unrelated.js
cat > plan.md <<'EOF'
# Plan: feedback endpoint
## Confirmed requirements
- R1: POST /feedback with JSON {text} stores the text (1 to 500 chars) and returns 201.
## Files that change
- src/server.js
## Proof
node --test
EOF
git add -A; git commit -qm base
cat > src/server.js <<'EOF'
import { createServer } from 'node:http';
import _ from 'lodash';
export const feedback = [];
class NotifierFactory { create() { return new EmailNotifier(); } }
class EmailNotifier { send(msg) { console.log(msg); } }
function legacyFormat(t) { return t.trim().toLowerCase(); }
createServer(async (req, res) => {
  if (req.method === 'POST' && req.url === '/feedback') {
    let body = '';
    for await (const c of req) body += c;
    const { text } = JSON.parse(body);
    if (_.isEmpty(text)) { res.statusCode = 400; return res.end(); }
    feedback.push(text);
    new NotifierFactory().create().send('new feedback');
    res.statusCode = 201; return res.end();
  }
  res.statusCode = 404; res.end();
}).listen(3000);
EOF
echo 'export const VERSION = 2;' > src/unrelated.js
printf '{"name":"fb","type":"module","dependencies":{"lodash":"^4.17.21"}}\n' > package.json
git add -A; git commit -qm "feat: feedback endpoint"
git diff HEAD~1..HEAD > change.diff

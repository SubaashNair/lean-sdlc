set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src
printf '{"name":"notes","type":"module","scripts":{"test":"node --test"}}\n' > package.json
cat > src/server.js <<'EOF'
import { createServer } from 'node:http';
const notes = [];
createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/notes') {
    res.setHeader('content-type', 'application/json');
    return res.end(JSON.stringify(notes));
  }
  res.statusCode = 404;
  res.end();
}).listen(3000);
EOF
git add -A; git commit -qm init

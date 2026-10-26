set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src
printf '{"name":"shop","type":"module","scripts":{"test":"node --test"}}\n' > package.json
cat > src/server.js <<'EOF'
import { createServer } from 'node:http';
const orders = [{ id: 1, item: 'pen', qty: 2 }, { id: 2, item: 'ink', qty: 1 }];
createServer((req, res) => {
  if (req.url === '/orders') {
    res.setHeader('content-type', 'application/json');
    res.end(JSON.stringify(orders));
    return;
  }
  res.statusCode = 404;
  res.end();
}).listen(3000);
EOF
git add -A; git commit -qm init

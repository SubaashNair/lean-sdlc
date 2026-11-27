set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src test support
printf '{"name":"notes","type":"module","scripts":{"test":"node --test"}}\n' > package.json
cat > src/notes.js <<'EOF'
import { createServer } from 'node:http';

const notes = [];

export function handler(req, res) {
  if (req.method === 'GET' && req.url === '/notes') {
    res.setHeader('content-type', 'application/json');
    return res.end(JSON.stringify(notes));
  }
  res.statusCode = 404;
  res.end();
}

if (import.meta.url === `file://${process.argv[1]}`) createServer(handler).listen(3000);
EOF
cat > support/call.js <<'EOF'
// Calls the request handler without opening a port.
import { Readable } from 'node:stream';

export function call(handler, method, url, body = '') {
  return new Promise((resolve) => {
    const req = Readable.from(body ? [Buffer.from(body)] : []);
    Object.assign(req, { method, url, headers: { 'content-type': 'application/json' } });
    const headers = {};
    const res = {
      statusCode: 200,
      setHeader: (k, v) => { headers[k.toLowerCase()] = v; },
      end: (data = '') => resolve({ status: res.statusCode, headers, body: String(data) }),
    };
    handler(req, res);
  });
}
EOF
cat > test/notes.test.js <<'EOF'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { handler } from '../src/notes.js';
import { call } from '../support/call.js';

test('GET /notes starts empty', async () => {
  const res = await call(handler, 'GET', '/notes');
  assert.equal(res.status, 200);
  assert.deepEqual(JSON.parse(res.body), []);
});
EOF
cat > src/legacy.js <<'EOF'
// legacy: do not touch
var x = 1; var y = 2
function old_fmt(a,b){ if(a){ if(b){ return a+b } else { return a } } else { return null } }
module.exports = { old_fmt, x, y }
EOF
cat > plan.md <<'EOF'
# Plan: note create and fetch
Size: S2 | Date: 2026-11-27 | Status: approved
> user: approved, go ahead
## Intent
Let clients create a note and fetch one by id.
## Confirmed requirements
- R1: POST /notes accepts a JSON body {"text": string} where text is 1 to 500 characters, stores it in memory and returns 201 with {id, text}.
- R2: GET /notes/:id returns the note as JSON, or 404 if there is none.
## Open questions (never become tasks)
- None.
## Files that change (the scope)
- src/notes.js
- test/notes.test.js
## Simplest option, and what was rejected
In-memory array in src/notes.js, numeric ids. Tests use support/call.js, which calls the handler without opening a port. Rejected: a database and a router library.
## Order of work (tracer slices)
1. R1 with tests. 2. R2 with tests.
## Proof (the command that must pass)
npm test
EOF
git add -A; git commit -qm init

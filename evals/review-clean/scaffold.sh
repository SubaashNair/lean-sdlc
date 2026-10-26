set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src test
printf '{"name":"num","type":"module","scripts":{"test":"node --test"}}\n' > package.json
echo 'export const ZERO = 0;' > src/math.js
cat > plan.md <<'EOF'
# Plan: clamp helper
## Confirmed requirements
- R1: clamp(n, lo, hi) returns n limited to [lo, hi]; throws RangeError if lo > hi.
## Files that change
- src/math.js
- test/math.test.js
## Proof
node --test
EOF
git add -A; git commit -qm base
cat >> src/math.js <<'EOF'
export function clamp(n, lo, hi) {
  if (lo > hi) throw new RangeError('lo must not exceed hi');
  return Math.min(Math.max(n, lo), hi);
}
EOF
cat > test/math.test.js <<'EOF'
import test from 'node:test';
import assert from 'node:assert/strict';
import { clamp } from '../src/math.js';
test('clamps inside, below and above the range', () => {
  assert.equal(clamp(5, 0, 10), 5);
  assert.equal(clamp(-1, 0, 10), 0);
  assert.equal(clamp(11, 0, 10), 10);
});
test('rejects an inverted range', () => {
  assert.throws(() => clamp(1, 10, 0), RangeError);
});
EOF
git add -A; git commit -qm "feat: clamp helper"
git diff HEAD~1..HEAD > change.diff

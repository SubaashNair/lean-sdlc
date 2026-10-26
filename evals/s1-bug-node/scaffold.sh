set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src test
printf '{"name":"shop","type":"module","scripts":{"test":"node --test"}}\n' > package.json
cat > src/price.js <<'EOF'
export function applyDiscount(price, percent) {
  return price - percent;
}
EOF
cat > test/price.test.js <<'EOF'
import test from 'node:test';
import assert from 'node:assert/strict';
import { applyDiscount } from '../src/price.js';
test('no discount keeps the price', () => {
  assert.equal(applyDiscount(100, 0), 100);
});
EOF
git add -A; git commit -qm init

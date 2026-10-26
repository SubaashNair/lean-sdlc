set -e
git init -q; git config user.name t; git config user.email t@t
mkdir -p src test
printf '{"name":"shop","type":"module","scripts":{"test":"node --test"}}\n' > package.json
cat > src/price.js <<'EOF'
export function applyDiscount(price, percent) {
  return price * (1 - percent / 100);
}
EOF
cat > src/cart.js <<'EOF'
import { applyDiscount } from './price.js';
export const total = (items) => items.reduce((s, i) => s + applyDiscount(i.price, i.off), 0);
EOF
cat > test/price.test.js <<'EOF'
import test from 'node:test';
import assert from 'node:assert/strict';
import { applyDiscount } from '../src/price.js';
test('25 percent off 200 is 150', () => assert.equal(applyDiscount(200, 25), 150));
EOF
git add -A; git commit -qm init

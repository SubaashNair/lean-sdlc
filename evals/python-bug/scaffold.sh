set -e
git init -q; git config user.name t; git config user.email t@t
cat > paginate.py <<'EOF'
def paginate(items, page, size):
    """Return one page of items. Pages start at 1."""
    start = page * size
    return items[start:start + size]
EOF
cat > test_paginate.py <<'EOF'
import unittest
from paginate import paginate


class PaginateTest(unittest.TestCase):
    def test_empty_list(self):
        self.assertEqual(paginate([], 1, 3), [])


if __name__ == "__main__":
    unittest.main()
EOF
git add -A; git commit -qm init

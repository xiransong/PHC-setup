#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Step 3 — Install PHC (Perpetual Humanoid Control)
#
# Target layout:
#   ~/scratch/PHC/PHC   ← PHC git repository
#
# What this script does:
#   1) Create PHC project directory
#   2) Clone PHC repo (or update if already present)
#   3) Install Python dependencies into active env
###############################################################################

PHC_ROOT="${HOME}/scratch/PHC"
PHC_REPO_DIR="${PHC_ROOT}/PHC"
PHC_REPO_URL="https://github.com/ZhengyiLuo/PHC.git"

echo "============================================================"
echo "[Step 3] Installing PHC"
echo "============================================================"

# ---------------------------------------------------------------------------
echo "[1/3] Sanity checks"

if ! python - << 'EOF'
import isaacgym
from isaacgym import gymapi
print("Isaac Gym OK")
EOF
then
  echo "[Error] Isaac Gym is not importable. Run Step 2 first."
  exit 1
fi

# ---------------------------------------------------------------------------
echo "[2/3] Cloning PHC repository"

mkdir -p "${PHC_ROOT}"

if [[ -d "${PHC_REPO_DIR}/.git" ]]; then
  echo "[OK] PHC repo already exists. Fetching updates."
  cd "${PHC_REPO_DIR}"
  git fetch --all
else
  git clone "${PHC_REPO_URL}" "${PHC_REPO_DIR}"
  cd "${PHC_REPO_DIR}"
fi

# Optional: pin to a known commit later (recommended for reproducibility)
# git checkout <commit-hash>

# ---------------------------------------------------------------------------
echo "[3/3] Installing PHC Python dependencies"

pip install --upgrade pip
pip install -r requirement.txt

echo "============================================================"
echo "[Done] PHC installed successfully"
echo
echo "Next:"
echo "  cd ~/scratch/PHC/PHC"
echo "  (Proceed to Step 4: SMPL assets)"
echo "============================================================"

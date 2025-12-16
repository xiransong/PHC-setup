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

echo "[PHC] Enforcing compatible PyTorch + NumPy versions"

pip uninstall -y torch torchvision torchaudio numpy pytorch-lightning || true

pip install \
  torch==1.13.1+cu117 \
  torchvision==0.14.1+cu117 \
  torchaudio==0.13.1+cu117 \
  --extra-index-url https://download.pytorch.org/whl/cu117

pip install numpy==1.23.5
pip install pytorch-lightning==1.9.5

# IMPORTANT:
# We use --no-deps to prevent pip from auto-upgrading critical packages
# (especially torch and numpy). PHC / Isaac Gym require:
#   - torch==1.13.1 (PyTorch 2.x breaks gymtorch)
#   - numpy==1.23.5 (numpy>=1.24 removes np.float)
# Letting pip resolve dependencies freely WILL break Isaac Gym.
pip install -r requirements.txt --no-deps

# Explicit runtime deps missing from requirements.txt
pip install \
  beautifulsoup4 \
  glfw \
  absl-py \
  python-utils \
  gymnasium==0.29.1 \
  lazy-loader \
  matplotlib \
  hydra-core==1.3.2 \
  pandas \
  threadpoolctl \
  addict \
  plotly \
  dash \
  ray==2.6.3 \
  tensorboardX \
  tensorboard \
  wandb \
  pydantic==1.10.13

echo "============================================================"
echo "[Done] PHC installed successfully"
echo
echo "Next:"
echo "  cd ~/scratch/PHC/PHC"
echo "  (Proceed to Step 4: SMPL assets)"
echo "============================================================"

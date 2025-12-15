#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Step 2 — Install Isaac Gym Preview 4 (headless)
#
# Target:
#   - Ubuntu 22.04
#   - micromamba env: isaac
#   - NVIDIA GPU (A10)
#
# What this script does:
#   1) Download Isaac Gym Preview 4
#   2) Extract to ~/isaacgym
#   3) Install Python bindings into active env
#   4) Run a minimal import test
###############################################################################

mkdir -p "${HOME}/scratch"

ISAAC_GYM_URL="https://developer.nvidia.com/isaac-gym-preview-4"
ISAAC_GYM_DIR="${HOME}/scratch/isaacgym"
ISAAC_GYM_TARBALL="${HOME}/scratch/isaac-gym-preview-4.tar.gz"

echo "============================================================"
echo "[Step 2] Installing Isaac Gym Preview 4"
echo "============================================================"

# ---------------------------------------------------------------------------
echo "[1/5] Sanity checks"

if ! command -v nvidia-smi >/dev/null; then
  echo "[Error] nvidia-smi not found. Run Step 1 first."
  exit 1
fi

if ! python -c "import torch; assert torch.cuda.is_available()"; then
  echo "[Error] torch.cuda.is_available() is False."
  echo "        Activate your env and verify Step 1."
  exit 1
fi

# ---------------------------------------------------------------------------
echo "[2/5] Downloading Isaac Gym Preview 4"

if [[ -d "${ISAAC_GYM_DIR}" ]]; then
  echo "[OK] Isaac Gym directory already exists: ${ISAAC_GYM_DIR}"
else
  if [[ ! -f "${ISAAC_GYM_TARBALL}" ]]; then
    echo "[Info] Downloading Isaac Gym tarball"
    wget -O "${ISAAC_GYM_TARBALL}" "${ISAAC_GYM_URL}"
  fi

  echo "[Info] Extracting Isaac Gym"
  tar -xvf "${ISAAC_GYM_TARBALL}"
  mv isaacgym "${ISAAC_GYM_DIR}"
fi

# ---------------------------------------------------------------------------
echo "[3/5] Installing Isaac Gym Python bindings (editable)"

cd "${ISAAC_GYM_DIR}/python"

# Editable install so PHC / IsaacGymEnvs can import gymapi
pip install -e .

# ---------------------------------------------------------------------------
echo "[4/5] Ensuring system libpython3.8 is available (Isaac Gym requirement)"

if ! ldconfig -p | grep -q libpython3.8.so; then
  sudo -E add-apt-repository -y ppa:deadsnakes/ppa
  sudo -E apt-get update
  sudo -E apt-get install -y python3.8 python3.8-dev
fi

# ---------------------------------------------------------------------------
echo "[5/5] Sanity check: import isaacgym"

python - << 'EOF'
import isaacgym
from isaacgym import gymapi
print("Isaac Gym import OK")
print("Gym API version:", gymapi.__file__)
EOF

echo "============================================================"
echo "[Done] Isaac Gym installed successfully"
echo
echo "Next:"
echo "  - Proceed to Step 3: Install PHC + IsaacGymEnvs"
echo "============================================================"

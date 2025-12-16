#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Step 1 — NVIDIA driver (if needed) + micromamba + PyTorch environment
#
# Target: Ubuntu 22.04 GPU VM (Lambda Cloud, NVIDIA A10)
#
# What this script does:
#   1) Install base OS packages (non-interactive)
#   2) Install NVIDIA driver if nvidia-smi is missing (then exit for reboot)
#   3) Install micromamba locally
#   4) Create conda env "isaac" with Python 3.8 + PyTorch + CUDA runtime
#
# Re-run safe. Non-interactive.
###############################################################################

# ---------------------------------------------------------------------------
# Non-interactive apt (avoid needrestart / whiptail)
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# ---------------------------------------------------------------------------
# Config
ENV_NAME="${ENV_NAME:-isaac}"
PYTHON_VERSION="3.8"
CUDA_RUNTIME_VERSION="11.6"

MAMBA_ROOT="${HOME}/scratch/micromamba"
MAMBA_BIN="${MAMBA_ROOT}/bin/micromamba"

# ---------------------------------------------------------------------------
echo "============================================================"
echo "[Step 1] Base system + NVIDIA driver + micromamba + env"
echo "============================================================"

# ---------------------------------------------------------------------------
echo "[1/4] Installing base OS packages"
sudo -E apt-get update -y
sudo -E apt-get install -y --no-install-recommends \
  ca-certificates curl wget git unzip bzip2 \
  build-essential pkg-config \
  tmux htop \
  python3-dev \
  libgl1-mesa-glx libegl1 libxext6 libxrender1 libsm6 \
  alsa-utils \
  ubuntu-drivers-common
sudo rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
echo "[2/4] Checking NVIDIA driver (nvidia-smi)"

if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "[Info] nvidia-smi not found — installing NVIDIA driver"

  if ! lspci | grep -qi nvidia; then
    echo "[Error] No NVIDIA GPU detected. Are you on a GPU VM?"
    exit 1
  fi

  DRIVER="$(ubuntu-drivers devices | awk '/recommended/ {print $3; exit}')"
  if [[ -z "${DRIVER}" ]]; then
    DRIVER="nvidia-driver-535"
    echo "[Warn] Could not detect recommended driver, using fallback: ${DRIVER}"
  else
    echo "[Info] Recommended driver: ${DRIVER}"
  fi

  sudo -E apt-get update -y
  sudo -E apt-get install -y "${DRIVER}"

  echo
  echo "============================================================"
  echo "[Driver installed] Reboot required"
  echo
  echo "Run:"
  echo "  sudo reboot"
  echo
  echo "After reboot, re-run:"
  echo "  bash step1_base.sh"
  echo "============================================================"
  exit 0
fi

echo "[OK] NVIDIA driver detected"
nvidia-smi || true

# ---------------------------------------------------------------------------
echo "[3/4] Installing micromamba (local)"

mkdir -p "${MAMBA_ROOT}/bin"
if [[ ! -x "${MAMBA_BIN}" ]]; then
  TMP_DIR="$(mktemp -d)"
  curl -L https://micro.mamba.pm/api/micromamba/linux-64/latest \
    | tar -xvj -C "${TMP_DIR}" --strip-components=1 bin/micromamba
  mv "${TMP_DIR}/micromamba" "${MAMBA_BIN}"
  chmod +x "${MAMBA_BIN}"
  rm -rf "${TMP_DIR}"
fi

# Ensure micromamba is available in future shells
if ! grep -q "micromamba setup" "${HOME}/.bashrc"; then
  cat >> "${HOME}/.bashrc" << EOF

# >>> micromamba setup >>>
export MAMBA_ROOT_PREFIX="${MAMBA_ROOT}"
export PATH="${MAMBA_ROOT}/bin:\$PATH"
eval "\$(${MAMBA_BIN} shell hook -s bash)"
# <<< micromamba setup <<<
EOF
fi

# Activate micromamba in this shell
export MAMBA_ROOT_PREFIX="${MAMBA_ROOT}"
export PATH="${MAMBA_ROOT}/bin:${PATH}"
eval "$(${MAMBA_BIN} shell hook -s bash)"

# ---------------------------------------------------------------------------
echo "[4/4] Creating conda env '${ENV_NAME}' (PyTorch + CUDA runtime)"

if micromamba env list | awk '{print $1}' | grep -qx "${ENV_NAME}"; then
  echo "[OK] Env already exists: ${ENV_NAME}"
else
  micromamba create -y -n "${ENV_NAME}" \
    python="${PYTHON_VERSION}" \
    pytorch torchvision torchaudio \
    "pytorch-cuda=${CUDA_RUNTIME_VERSION}" \
    -c conda-forge -c pytorch -c nvidia
fi

# ---------------------------------------------------------------------------
echo "============================================================"
echo "[Done] Step 1 complete"
echo
echo "Next:"
echo "  source ~/.bashrc"
echo "  micromamba activate ${ENV_NAME}"
echo "  nvidia-smi"
echo "  python -c \"import torch; print(torch.__version__); print(torch.cuda.is_available())\""
echo "============================================================"

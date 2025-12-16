#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Step 4 — Setup SMPL / SMPL-X assets for PHC
#
# Assumes:
#   - SMPL_python_v.1.1.0.zip uploaded to ~/scratch/smpl_upload
#   - models_smplx_v1_1.zip uploaded to ~/scratch/smpl_upload
###############################################################################

UPLOAD_DIR="${HOME}/scratch/smpl_upload"
PHC_REPO="${HOME}/scratch/PHC/PHC"
SMPL_DIR="${PHC_REPO}/data/smpl"

echo "============================================================"
echo "[Step 4] Setting up SMPL / SMPL-X assets"
echo "============================================================"

# ---------------------------------------------------------------------------
echo "[1/4] Creating target directory"
mkdir -p "${SMPL_DIR}"

# ---------------------------------------------------------------------------
echo "[2/4] Extracting SMPL v1.1.0"

cd "${UPLOAD_DIR}"
unzip -q -o SMPL_python_v.1.1.0.zip

# SMPL files live under SMPL_python_v.1.1.0/smpl/models/
SMPL_SRC="SMPL_python_v.1.1.0/smpl/models"

cp "${SMPL_SRC}/basicmodel_neutral_lbs_10_207_0_v1.1.0.pkl" "${SMPL_DIR}/SMPL_NEUTRAL.pkl"
cp "${SMPL_SRC}/basicmodel_m_lbs_10_207_0_v1.1.0.pkl"       "${SMPL_DIR}/SMPL_MALE.pkl"
cp "${SMPL_SRC}/basicmodel_f_lbs_10_207_0_v1.1.0.pkl"       "${SMPL_DIR}/SMPL_FEMALE.pkl"

# ---------------------------------------------------------------------------
echo "[3/4] Extracting SMPL-X v1.1"

unzip -q -o models_smplx_v1_1.zip

# SMPL-X files live under models/
SMPLX_SRC="models"

cp "${SMPLX_SRC}/smplx/SMPLX_NEUTRAL.pkl" "${SMPL_DIR}/SMPLX_NEUTRAL.pkl"
cp "${SMPLX_SRC}/smplx/SMPLX_MALE.pkl"    "${SMPL_DIR}/SMPLX_MALE.pkl"
cp "${SMPLX_SRC}/smplx/SMPLX_FEMALE.pkl"  "${SMPL_DIR}/SMPLX_FEMALE.pkl"

# ---------------------------------------------------------------------------
echo "[4/4] Verifying files"

ls -lh "${SMPL_DIR}"

echo "============================================================"
echo "[Done] SMPL assets installed"
echo
echo "Next:"
echo "  cd ~/scratch/PHC/PHC"
echo "  bash download_data.sh"
echo "============================================================"

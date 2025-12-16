#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Step 4b — Setup SMPL / SMPL-X assets for PHC
#
# This script:
#   - Extracts SMPL / SMPL-X zip files uploaded in Step 4a
#   - Renames model files to PHC-expected names
#   - Installs them into PHC/data/smpl
#
# Assumes:
#   ~/scratch/PHC/assets/smpl_raw/
#     - SMPL_python_v.1.1.0.zip
#     - models_smplx_v1_1.zip
###############################################################################

RAW_DIR="${HOME}/scratch/PHC/assets/smpl_raw"
PHC_REPO="${HOME}/scratch/PHC/PHC"
SMPL_DIR="${PHC_REPO}/data/smpl"

echo "============================================================"
echo "[Step 4b] Setting up SMPL / SMPL-X assets for PHC"
echo "============================================================"

# ---------------------------------------------------------------------------
echo "[1/4] Sanity checks"

for f in SMPL_python_v.1.1.0.zip models_smplx_v1_1.zip; do
  if [[ ! -f "${RAW_DIR}/${f}" ]]; then
    echo "[Error] Missing file: ${RAW_DIR}/${f}"
    echo "Please run step4a_upload_smpl.sh first."
    exit 1
  fi
done

# ---------------------------------------------------------------------------
echo "[2/4] Preparing target directory"
mkdir -p "${SMPL_DIR}"

# Use a temp workspace to avoid polluting raw directory
WORK_DIR="$(mktemp -d)"
echo "[Info] Using temp directory: ${WORK_DIR}"

# ---------------------------------------------------------------------------
echo "[3/4] Extracting and installing SMPL v1.1.0"

unzip -q "${RAW_DIR}/SMPL_python_v.1.1.0.zip" -d "${WORK_DIR}"

SMPL_SRC="${WORK_DIR}/SMPL_python_v.1.1.0/smpl/models"

cp "${SMPL_SRC}/basicmodel_neutral_lbs_10_207_0_v1.1.0.pkl" "${SMPL_DIR}/SMPL_NEUTRAL.pkl"
cp "${SMPL_SRC}/basicmodel_m_lbs_10_207_0_v1.1.0.pkl"       "${SMPL_DIR}/SMPL_MALE.pkl"
cp "${SMPL_SRC}/basicmodel_f_lbs_10_207_0_v1.1.0.pkl"       "${SMPL_DIR}/SMPL_FEMALE.pkl"

# ---------------------------------------------------------------------------
echo "[4/4] Extracting and installing SMPL-X v1.1"

unzip -q "${RAW_DIR}/models_smplx_v1_1.zip" -d "${WORK_DIR}"

SMPLX_SRC="${WORK_DIR}/models/smplx"

cp "${SMPLX_SRC}/SMPLX_NEUTRAL.pkl" "${SMPL_DIR}/SMPLX_NEUTRAL.pkl"
cp "${SMPLX_SRC}/SMPLX_MALE.pkl"    "${SMPL_DIR}/SMPLX_MALE.pkl"
cp "${SMPLX_SRC}/SMPLX_FEMALE.pkl"  "${SMPL_DIR}/SMPLX_FEMALE.pkl"

# ---------------------------------------------------------------------------
echo "[Verify] Installed files:"
ls -lh "${SMPL_DIR}"

# Cleanup
rm -rf "${WORK_DIR}"

echo "============================================================"
echo "[Done] SMPL / SMPL-X assets installed successfully."
echo
echo "Next:"
echo "  cd ~/scratch/PHC/PHC"
echo "  bash download_data.sh"
echo "============================================================"

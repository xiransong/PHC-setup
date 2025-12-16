#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Step 4a — Upload SMPL / SMPL-X zip files to remote VM
#
# This script uploads the official SMPL and SMPL-X zip files from your local
# machine to the VM. Unzipping and renaming will be done on the VM in Step 4b.
#
# Usage:
#   bash scripts/step4a_upload_smpl.sh ubuntu@<VM_IP>
#
# Expects the following files in the repo root:
#   - SMPL_python_v.1.1.0.zip
#   - models_smplx_v1_1.zip
###############################################################################

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 user@host"
  exit 1
fi

REMOTE="$1"

# Where raw zip files live on the VM (before extraction)
REMOTE_DIR="~/scratch/PHC/assets/smpl_raw"

FILES=(
  "SMPL_python_v.1.1.0.zip"
  "models_smplx_v1_1.zip"
)

echo "============================================================"
echo "[Step 4a] Uploading SMPL assets to ${REMOTE}:${REMOTE_DIR}"
echo "============================================================"

# --- Sanity check local files
for f in "${FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "[Error] Missing file: $f"
    echo "Please download it from the official SMPL / SMPL-X website first."
    exit 1
  fi
done

# --- Create remote directory
ssh "${REMOTE}" "mkdir -p ${REMOTE_DIR}"

# --- Upload
scp "${FILES[@]}" "${REMOTE}:${REMOTE_DIR}/"

echo "============================================================"
echo "[Done] Upload complete."
echo
echo "Next (on the VM):"
echo "  bash scripts/step4b_setup_smpl.sh"
echo
echo "Note:"
echo "  - This script ONLY uploads the zip files."
echo "  - Extraction and renaming happen in Step 4b."
echo "============================================================"

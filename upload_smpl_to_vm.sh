#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Upload SMPL / SMPL-X zip files to a remote VM scratch directory
#
# Usage:
#   bash upload_smpl_to_vm.sh ubuntu@<VM_IP>
#
# Expects files in current directory:
#   - SMPL_python_v.1.1.0.zip
#   - models_smplx_v1_1.zip
###############################################################################

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 user@host"
  exit 1
fi

REMOTE="$1"
REMOTE_DIR="~/scratch/smpl_upload"

FILES=(
  "SMPL_python_v.1.1.0.zip"
  "models_smplx_v1_1.zip"
)

echo "============================================================"
echo "Uploading SMPL files to ${REMOTE}:${REMOTE_DIR}"
echo "============================================================"

for f in "${FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "[Error] File not found: $f"
    exit 1
  fi
done

ssh "${REMOTE}" "mkdir -p ${REMOTE_DIR}"

scp "${FILES[@]}" "${REMOTE}:${REMOTE_DIR}/"

echo "============================================================"
echo "Upload complete"
echo "Next (on VM):"
echo "  bash step4_setup_smpl.sh"
echo "============================================================"

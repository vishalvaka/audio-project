https://os.unil.cloud.switch.ch/fma/fma_small.zip
https://os.unil.cloud.switch.ch/fma/fma_metadata.zip
``` :contentReference[oaicite:0]{index=0}  

Because our first script looked for `fma_small.tar.xz`, the server quite correctly replied *404 Not Found*.  
Below is a corrected `scripts/download_fma.sh` that grabs the **`.zip`** archives, resumes partial downloads, and unpacks them.

---

```bash
#!/usr/bin/env bash
# --------------------------------------------
# Download the Free Music Archive (FMA) dataset
# Usage examples
#   ./scripts/download_fma.sh                 # → data/raw/fma_small ...
#   ./scripts/download_fma.sh data/raw medium # medium subset
# --------------------------------------------
set -euo pipefail

TARGET_DIR=${1:-"data/raw"}
SUBSET=${2:-"small"}          # small | medium | large | full

BASE_URL="https://os.unil.cloud.switch.ch/fma"

case "$SUBSET" in
  small)  FILE="fma_small.zip"  ;;
  medium) FILE="fma_medium.zip" ;;
  large)  FILE="fma_large.zip"  ;;
  full)   FILE="fma_full.zip"   ;;
  *) echo "❌ Unknown subset '${SUBSET}'"; exit 1 ;;
esac

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# 1 ▸ Audio subset ------------------------------------------
if [[ -f "$FILE" ]]; then
  echo "✔️  $FILE already exists — skipping download."
else
  echo "⬇️  Downloading $FILE …"
  wget -c "$BASE_URL/$FILE"
fi

# 2 ▸ Metadata ----------------------------------------------
if [[ -f "fma_metadata.zip" ]]; then
  echo "✔️  fma_metadata.zip already exists — skipping download."
else
  echo "⬇️  Downloading metadata …"
  wget -c "$BASE_URL/fma_metadata.zip"
fi

# 3 ▸ Extract archives --------------------------------------
if [[ -d "${FILE%.zip}" ]]; then
  echo "✔️  ${FILE%.zip}/ already extracted."
else
  echo "📦  Extracting $FILE …"
  unzip -q "$FILE"
fi

if [[ -d "fma_metadata" ]]; then
  echo "✔️  Metadata already extracted."
else
  echo "📦  Extracting metadata …"
  unzip -q fma_metadata.zip
fi

echo -e "\n🎉  FMA subset '$SUBSET' ready in $TARGET_DIR/"

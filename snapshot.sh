#!/usr/bin/env bash
# snapshot.sh — archive the current CV state for a specific application
#
# Usage:
#   ./snapshot.sh <date> <org_slug> <role_slug> [--from <archive_name>]
#
# Examples:
#   ./snapshot.sh 2026-05-01 ExampleAnalytics data-analyst
#   ./snapshot.sh 2026-06-15 OtherCorp junior-analyst --from 2026-05-01_ExampleAnalytics_data-analyst
#
# --from: bootstraps the working content/ files from a past archive before snapshotting.
#         Useful for starting a new application from the closest matching past version.

set -e

if [ "$#" -lt 3 ]; then
  echo "Usage: ./snapshot.sh <date> <org_slug> <role_slug> [--from <archive_name>]"
  echo "Example: ./snapshot.sh 2026-06-15 OtherCorp junior-analyst --from 2026-05-01_ExampleAnalytics_data-analyst"
  exit 1
fi

DATE="$1"
ORG="$2"
ROLE="$3"
FROM=""

# Parse optional --from flag
if [ "$4" = "--from" ] && [ -n "$5" ]; then
  FROM="$5"
fi

DEST="archive/${DATE}_${ORG}_${ROLE}"
MAIN="main.tex"

if [ -d "$DEST" ]; then
  echo "Archive already exists at $DEST — aborting to avoid overwrite."
  exit 1
fi

# --- Bootstrap content from a past archive if --from is specified ---
if [ -n "$FROM" ]; then
  SOURCE="archive/${FROM}"
  if [ ! -d "$SOURCE" ]; then
    echo "Source archive not found: $SOURCE"
    exit 1
  fi
  echo "Bootstrapping content/ from $SOURCE ..."
  cp "$SOURCE"/*.tex . 2>/dev/null || true
  # Re-move content files into content/ (archive stores them flat)
  for f in header summary skills education experience projects publications engagements; do
    [ -f "${f}.tex" ] && mv "${f}.tex" "content/${f}.tex"
  done
  echo "Done. Edit content/ files for the new application, then re-run without --from to snapshot."
  exit 0
fi

mkdir -p "$DEST"

# Copy entry points and content files
cp *.tex "$DEST/" 2>/dev/null || true
cp content/*.tex "$DEST/" 2>/dev/null || true
cp *.pdf "$DEST/" 2>/dev/null || true

echo "Copied files to $DEST/"

# --- Extract design settings from main.tex ---
FONT_PKG=$(grep -oP '(?<=\]\{)[^\}]+(?=\})' "$MAIN" | grep -v 'utf8\|T1\|none\|hyperref\|enumitem\|titlesec\|tabularx\|parskip\|hyphenat\|fontawesome\|geometry\|fontspec' | head -1 || echo "inter")
FONT_SIZE=$(grep -oP '(?<=\\documentclass\[)\d+pt' "$MAIN" | head -1 || echo "unknown")
PAPER=$(grep -oP '(?<=\\documentclass\[)[^\]]+' "$MAIN" | grep -oP '[a-z0-9]+paper' | head -1 || echo "unknown")
TOP=$(grep -oP '(?<=top=)[^,\]]+' "$MAIN" | head -1 || echo "unknown")
BOTTOM=$(grep -oP '(?<=bottom=)[^,\]]+' "$MAIN" | head -1 || echo "unknown")
LEFT=$(grep -oP '(?<=left=)[^,\]]+' "$MAIN" | head -1 || echo "unknown")
RIGHT=$(grep -oP '(?<=right=)[^,\]]+' "$MAIN" | head -1 || echo "unknown")
LINESPREAD=$(grep -oP '(?<=\\linespread\{)[^\}]+' "$MAIN" | head -1 || echo "unknown")
SEC_BEFORE=$(grep -oP '(?<=\\titlespacing\*\{\\section\}\{0pt\}\{)[^\}]+' "$MAIN" | head -1 || echo "unknown")
SEC_AFTER=$(grep -oP '(?<=\\titlespacing\*\{\\section\}\{0pt\}\{[^\}]+\}\{)[^\}]+' "$MAIN" | head -1 || echo "unknown")
ACTIVE_FLAG=$(grep -oP '\\summary[A-Z]true' "$MAIN" | head -1 | sed 's/\\//;s/true//' || echo "none")

# --- Write meta.yaml ---
cat > "$DEST/meta.yaml" <<EOF
application:
  date: ${DATE}
  organisation: ${ORG}
  role: ${ROLE}
  type: ""              # public-service | research | industry | nfp
  req_id: ""
  contact: ""
  outcome: applied      # update: interview / offer / rejected / withdrawn
  notes: >
    Add notes here about the framing strategy for this application —
    what you emphasised, what you downplayed, and why.

design:
  cv:
    font_display: CalSans-SemiBold
    font_body: inter
    font_size: ${FONT_SIZE}
    paper: ${PAPER}
    margins:
      top: ${TOP}
      bottom: ${BOTTOM}
      left: ${LEFT}
      right: ${RIGHT}
    line_spread: ${LINESPREAD}
    section_spacing:
      before: ${SEC_BEFORE}
      after: ${SEC_AFTER}
    active_summary_flag: ${ACTIVE_FLAG}

  cover_letter:
    font_display: CalSans-SemiBold
    font_body: inter
    font_size: ""
    paper: ""
    margins:
      top: ""
      bottom: ""
      left: ""
      right: ""
    line_spread: ""
    par_skip: ""
EOF

echo "Created $DEST/meta.yaml"
echo ""
echo "Done. Open $DEST/meta.yaml and fill in the application details and notes."

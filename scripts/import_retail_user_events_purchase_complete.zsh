#!/usr/bin/env zsh

################################################################################
# Environment Variables - Retail API Project
################################################################################

local RETAIL_PROJECT_ID="winter-dataform"
local RETAIL_PROJECT_NUMBER="374294533986"
local RETAIL_LOCATION="global"
local RETAIL_CATALOG="default_catalog"
local RETAIL_IMPORT_GCS_BUCKET="gs://winter-retail/user_events"
local RETAIL_BQ_DATASET="fashion"

local RETAIL_TMP_DIR="${0:A:h}/../tmp"
RETAIL_TMP_DIR="${RETAIL_TMP_DIR:A}"


################################################################################
# Import Retail User Events - Purchase Complete - From BigQuery
################################################################################

# Delete Any Files Previously Staged Purchase Complete Events
gsutil -q -m rm -rf "${RETAIL_IMPORT_GCS_BUCKET}/purchase_complete/staging"

# Output the Import User Events - Purchase Complete - JSON Request Object
cat <<EOF > "$RETAIL_TMP_DIR/import_user_events_purchase_complete_request.json"
{
  "inputConfig": {
    "bigQuerySource": {
      "projectId": "${RETAIL_PROJECT_ID}",
      "datasetId": "${RETAIL_BQ_DATASET}",
      "tableId": "retail_user_events_purchase_complete",
      "gcsStagingDir": "${RETAIL_IMPORT_GCS_BUCKET}/purchase_complete/staging",
      "dataSchema": "user_event"
    }
  },
  "errorsConfig": {
    "gcsPrefix": "${RETAIL_IMPORT_GCS_BUCKET}/purchase_complete/errors"
  }
}
EOF

curl -X POST \
-H "Authorization: Bearer $(gcloud auth application-default print-access-token --project=${RETAIL_PROJECT_ID})" \
-H "x-goog-user-project: ${RETAIL_PROJECT_ID}" \
-H "Content-Type: application/json; charset=utf-8" -d @"$RETAIL_TMP_DIR/import_user_events_purchase_complete_request.json" \
"https://retail.googleapis.com/v2/projects/${RETAIL_PROJECT_NUMBER}/locations/${RETAIL_LOCATION}/catalogs/${RETAIL_CATALOG}/userEvents:import"

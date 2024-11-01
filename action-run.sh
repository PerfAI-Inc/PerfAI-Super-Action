#!/bin/bash

# Default values
WAIT_FOR_COMPLETION=true
FAIL_ON_NEW_LEAKS=false

# Parse the input arguments
TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:,catalog-id:,label:,openapi_url:,base_path:,wait-for-completion:,fail-on-new-leaks:" -- -- "$@")

[ $? -eq 0 ] || exit

eval set -- "$TEMP"

while [ $# -gt 0 ]
do
    case "$1" in
        --hostname) PERFAI_HOSTNAME="$2"; shift;;
        --username) PERFAI_USERNAME="$2"; shift;;
        --password) PERFAI_PASSWORD="$2"; shift;;
        --catalog-id) CATALOG_ID="$2"; shift;;
        --label) LABEL="$2"; shift;;
        --openapi_url) OPENAPI_URL="$2"; shift;;
        --base_path) BASE_PATH="$2"; shift;;
        --wait-for-completion) WAIT_FOR_COMPLETION="$2"; shift;;
        --fail-on-new-leaks) FAIL_ON_NEW_LEAKS="$2"; shift;;
        --) shift ;;
    esac
    shift;
done

echo " "

if [ "$PERFAI_HOSTNAME" = "" ];
then
PERFAI_HOSTNAME="https://app.apiprivacy.com"
fi

### Step 1: Print Access Token ###
TOKEN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/auth/token" \
--header "Content-Type: application/json" \
--data-raw "{
    \"username\": \"${PERFAI_USERNAME}\",
    \"password\": \"${PERFAI_PASSWORD}\"
}")

ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.id_token')

if [ -z "$ACCESS_TOKEN" ]; then
    echo "Error: Could not retrieve access token"
    exit 1
fi

echo "Access Token is: $ACCESS_TOKEN"
echo " "

# Get commit information
COMMIT_ID=${GITHUB_SHA}
COMMIT_DATE=$(date "+%F")
COMMIT_URL="https://github.com/${GITHUB_REPOSITORY}/commit/${COMMIT_ID}"

### Step 2: Schedule API Privacy Tests ###
RUN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/api-catalog/apps/schedule-run-multiple" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "{
    \"catalog_id\": \"${CATALOG_ID}\",
    \"services\": [\"sensitive\",\"governance\",\"vms\"],
    \"label\": \"${LABEL}\",
    \"openapi_url\": \"${OPENAPI_URL}\",
    \"base_path\": \"${BASE_PATH}\",
    \"test_account_1\": {
        \"authentication_url\": \"${AUTH_URL_1}\",
        \"authentication_body\": \"${AUTH_BODY_1}\",
        \"authorization_headers\": \"${AUTH_HEADERS}\"
    },
    \"test_account_2\": {
        \"authentication_url\": \"${AUTH_URL_2}\",
        \"authentication_body\": \"${AUTH_BODY_2}\",
        \"authorization_headers\": \"${AUTH_HEADERS}\"
    },
    \"build_details\": {
        \"commit_id\": \"${COMMIT_ID}\",
        \"commit_url\": \"${COMMIT_URL}\",
        \"commit_user_name\": \"${GITHUB_ACTOR}\",
        \"commit_date\": \"${COMMIT_DATE}\",
        \"repo_name\": \"${GITHUB_REPOSITORY}\",
        \"comment\": \"${COMMENT}\"
    }
  }"
)

#echo "Run Response: $RUN_RESPONSE"

### RUN_ID Prints ###
RUN_ID=$(echo "$RUN_RESPONSE" | jq -r '.run_ids.sensitive')


# Output Run Response ###
echo " "
echo "Run Response: $RUN_RESPONSE"
echo " "
echo "Run ID is: $RUN_ID"

if [ "$ACCESS_TOKEN" == "null" ]; then
    echo "Error: Could not retrieve access token"
    exit 1
fi

### Step 3: Check the wait-for-completion flag ###
if [ "$WAIT_FOR_COMPLETION" == "true" ]; then
    echo "Waiting for API Privacy Tests to complete..."

    STATUS="PROCESSING"

    ### Step 4: Poll the status of the AI run until completion ###
    while [[ "$STATUS" == "PROCESSING" ]]; do
        
        # Check the status of the API Privacy Tests
    STATUS_RESPONSE=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/sensitive-data-service/apps/get-run-status?run_id=$RUN_ID" \
      --header "Authorization: Bearer $ACCESS_TOKEN")    

    #echo $STATUS_RESPONSE
   
    STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status')

    if  [ "$STATUS" == "COMPLETED"  ]; then

    NEW_ISSUES=$(echo "$STATUS_RESPONSE" | jq -r '.newIssues[]')
    NEW_ISSUES_DETECTED=$(echo "$STATUS_RESPONSE" | jq -r '.newIssuesDetected')

    echo " "
    echo "AI Running Status: $(echo "$STATUS_RESPONSE" | jq)"

        if [ "$NEW_ISSUES" == "" ] ||  [ "$NEW_ISSUES" == null ]; then
          echo "No new issues detected. Build passed."
          else
            echo "Build failed with new issues. New issue: $NEW_ISSUES"
            exit 1
        fi
    fi 

   # echo "AI Running Status: $STATUS"

    # If the AI run fails, exit with an error
    if [[ "$STATUS" == "FAILED" ]]; then
      echo "Error: API Privacy Tests failed for Run ID $RUN_ID"
      exit 1
    fi
  done
    
    # Once the status is no longer "in_progress", assume it completed
   echo "API Privacy Tests for API ID $CATALOG_ID has completed successfully!"
 else
   echo "API Privacy Tests triggered. Run ID: $RUN_ID. Exiting without waiting for completion."
   exit 1  
 fi

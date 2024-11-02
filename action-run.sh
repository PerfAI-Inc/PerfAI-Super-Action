#!/bin/bash

# Default values
WAIT_FOR_COMPLETION=true
FAIL_ON_NEW_LEAKS=false

# Parse the input arguments
TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:,openapi_url:,base_path:,api_id:,label:,wait-for-completion:,fail-on-new-leaks:,auth_url_1:,auth_body_1:,auth_headers:,auth_url_2:,auth_body_2:,auth_headhers:" -- -- "$@")

[ $? -eq 0 ] || exit

eval set -- "$TEMP"

while [ $# -gt 0 ]
do
    case "$1" in
        --hostname) PERFAI_HOSTNAME="$2"; shift;;
        --username) PERFAI_USERNAME="$2"; shift;;
        --password) PERFAI_PASSWORD="$2"; shift;;
        --openapi_url) OPENAPI_URL="$2"; shift;;
        --base_path) BASE_PATH="$2"; shift;;        
        --api_id) CATALOG_ID="$2"; shift;;
        --label) LABEL="$2"; shift;;
        --wait-for-completion) WAIT_FOR_COMPLETION="$2"; shift;;
        --fail-on-new-leaks) FAIL_ON_NEW_LEAKS="$2"; shift;;
        --auth_url_1) AUTH_URL_1="$2"; shift;;
        --auth_body_1) AUTH_BODY_1="$2"; shift;;
        --auth_headers) AUTH_HEADERS="$2"; shift;;
        --auth_url_2) AUTH_URL_2="$2"; shift;;
        --auth_body_2) AUTH_BODY_2="$2"; shift;;
        --auth_headhers) AUTH_HEADERS="$2"; shift;;
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
#COMMENT="${{ github.event.head_commit.message }}"  # Fetch commit message

# Print commit information to confirm
# echo "Commit ID: $COMMIT_ID"
# echo "Commit Date: $COMMIT_DATE"
# echo "Commit URL: $COMMIT_URL"
#echo "Commit Message: $COMMENT"

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
RUN_ID=$(echo "$RUN_RESPONSE" | jq -r '.run_id')


# Output Run Response ###
echo " "
echo "Run Response: $RUN_RESPONSE"
echo " "
echo "Run ID is: $RUN_ID"

# Check if RUN_ID is null or empty
if [ -z "$RUN_ID" ] || [ "$RUN_ID" == "null" ]; then
    echo "API Privacy Tests triggered. Run ID: $RUN_ID. Exiting without waiting for completion."
    exit 1
fi

# Check if ACCESS_TOKEN is null or emtpy
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
        STATUS_RESPONSE=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/api-catalog/apps/all_service_run_status?run_id=$RUN_ID" \
          --header "Authorization: Bearer $ACCESS_TOKEN")    

      # Handle empty or null STATUS_RESPONSE
        if [ -z "$STATUS_RESPONSE" ] || [ "$STATUS_RESPONSE" == "null" ]; then
            echo "Error: Received empty response from the API."
            exit 1
        fi
    #echo $STATUS_RESPONSE
    
        # Extract fields with default values to handle null cas
        PRIVACY=$(echo "$STATUS_RESPONSE" | jq -r '.PRIVACY')

        # Set STATUS to "PROCESSING" if PRIVACY status is null or empty
        STATUS=$(echo "$PRIVACY" | jq -r '.status')

        # Check if STATUS is completed and handle issues
        if  [ "$STATUS" == "COMPLETED"  ]; then

            NEW_ISSUES=$(echo "$STATUS_RESPONSE" | jq -r '.PRIVACY.newIssues[]')
            NEW_ISSUES_DETECTED=$(echo "$STATUS_RESPONSE" | jq -r '.PRIVACY.newIssuesDetected')

            echo " "
            echo "AI Running Status: $STATUS"

            if [ -z "$NEW_ISSUES" ] ||  [ "$NEW_ISSUES" == null ]; then
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

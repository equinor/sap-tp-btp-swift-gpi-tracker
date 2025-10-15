#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ -z "$ENV" ]; then
    echo "The ENV environment variable needs to be set, and match a file in the /config folder, e.g. 'dev' or 'test'"
    exit 1
fi

# shellcheck disable=SC1090
source "$SCRIPTDIR/../config/$ENV.cfg"

if [ "$(az ad sp list --spn "$CFG_SERVICE_PRINCIPAL_NAME" --query "length([])")" -eq 0 ]; then
  echo "Creating $CFG_SERVICE_PRINCIPAL_NAME"
  az ad sp create-for-rbac --name "$CFG_SERVICE_PRINCIPAL_NAME" --role "Omnia Contributor" --scopes "/subscriptions/$CFG_SUBSCRIPTION_ID/resourceGroups/$CFG_APP_RESOURCE_GROUP_NAME" --sdk-auth
else
  echo "Service principal: $CFG_SERVICE_PRINCIPAL_NAME already exists, doing nothing"
fi

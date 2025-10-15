#!/bin/bash -e

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TEMPLATEDIR=$SCRIPTDIR/../templates

if [ -z "$ENV" ]; then
    echo "The ENV environment variable needs to be set, and match a file in the /config folder, e.g. 'dev' or 'test'"
    exit 1
fi

# shellcheck disable=SC1090
source "$SCRIPTDIR/../config/$ENV.cfg"

#
# Everything below is application specific, and should be modified to specific needs
#

ACTIVEUSER=$(az account show --query user.name)
echo "Active user / service principal: $ACTIVEUSER"
echo "Deploying $ENV baseline (Key Vault, etc) into $CFG_BASELINE_RESOURCE_GROUP_NAME"

az deployment group create --resource-group "$CFG_BASELINE_RESOURCE_GROUP_NAME" --name "$CFG_BASELINE_DEPLOYMENT_NAME" \
    --subscription "$CFG_SUBSCRIPTION_NAME" --template-file "$TEMPLATEDIR"/baseline/$ENV/azuredeploy.json \
    --parameters @"$TEMPLATEDIR"/baseline/$ENV/"$CFG_ARM_DEPLOYMENT_PARAMETERS_FILE" 

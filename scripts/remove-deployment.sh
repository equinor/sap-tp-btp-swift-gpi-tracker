#!/bin/bash -e

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ -z "$ENV" ]; then
    echo "The ENV environment variable needs to be set, and match a file in the /config folder, e.g. 'dev' or 'test'"
    exit 1
fi

# shellcheck disable=SC1090
source $SCRIPTDIR/../config/$ENV.cfg

echo "Removing all resources from $CFG_APP_RESOURCE_GROUP_NAME ($ENV)"

#
# Everything below this point is application specific and should most likely be modified
#

RECORDNAME=$(az deployment group show --name $CFG_CENTOS_DEPLOYMENT_NAME --resource-group $CFG_DNS_RESOURCE_GROUP_NAME \
    --query "properties.parameters.recordName.value" -o tsv)
az deployment group create --mode Complete --resource-group $CFG_APP_RESOURCE_GROUP_NAME --subscription $CFG_SUBSCRIPTION_NAME \
    --template-file $SCRIPTDIR/../cleanup/azuredeploy.json

echo "Removing $RECORDNAME from $CFG_DNS_ZONE_NAME"
az network private-dns record-set a delete --resource-group $CFG_DNS_RESOURCE_GROUP_NAME --zone-name $CFG_DNS_ZONE_NAME --name $RECORDNAME --yes

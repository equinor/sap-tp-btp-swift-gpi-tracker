#!/bin/bash

KEYNAME=$1
VAULTNAME=$2

# If an existing password is not found, then attempt to create and insert a new one

az keyvault secret show --vault-name $VAULTNAME --name $KEYNAME --query value > /dev/null 2>&1

if [ $? == 3 ]; then
    #if the return code is 3 (SecretNotFound), then attempt to create and insert a new password
    echo -n "Creating and inserting new key windows password... "
    az keyvault secret set --name $KEYNAME --vault-name $VAULTNAME --value `openssl rand -base64 32` > /dev/null
    echo "Done"
else
    echo "An existing password was found in $VAULTNAME, doing nothing"
fi

#!/bin/bash

KEYNAME=$1
VAULTNAME=$2

# If an existing key pair is not found, then attempt to create and insert a new one

az keyvault secret show --vault-name "$VAULTNAME" --name "$KEYNAME"-pub --query value > /dev/null 2>&1

if [ $? == 3 ]; then
    #if the return code is 3 (SecretNotFound), then attempt to create and insert a new pair
    echo -n "Creating and inserting new key pair... "
    ssh-keygen -f "$KEYNAME" -P "" > /dev/null
    az keyvault secret set --name "$KEYNAME" --vault-name "$VAULTNAME" --encoding ascii --file "$KEYNAME" > /dev/null
    az keyvault secret set --name "$KEYNAME"-pub --vault-name "$VAULTNAME" --encoding ascii --file "$KEYNAME".pub > /dev/null   
    rm "$KEYNAME" "$KEYNAME".pub
    echo "Done"
else
    echo "An existing key was found in $VAULTNAME"
fi

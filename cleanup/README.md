# Danger zone

Running this wipes the contents of the resource group
This can be used to clear the resource group at regular intervals (e.g. every evening)

This command is executed by the [cleanup](https://github.com/equinor/mss-infra-reference-classic/blob/master/.github/workflows/cleanup.yml) pipeline.


```az deployment group create --mode Complete --resource-group S013-mss-infra-reference --subscription S013-MSS-Classic1 --template-file azuredeploy.json```

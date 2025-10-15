This template sets up an internal load balancer with two VMs behind it that has a local administrator. 
The template assumes that a KeyVault with the ssh login key already exists. 

This template (and KeyVault) would typically be loaded by the ```scripts/deploy.sh``` script.

## Precondition

> The steps in the [reference project](https://github.com/equinor/application-template-classic/blob/master/README.md) (or equivalent) has been followed, so that a KeyVault is available with the ssh login key. Optionally the ```scripts/deploy.sh``` is used which handles everything. 

The az cli is logged in as a service principal with the required access rights to do the deployments. A typical gotcha is that the service principal is missing ```Virtual Machine Contributor``` on the vnets. 

Example of how to log in with the service principal:

```az login --service-principal -p $PASSWORD -u $SP_NAME --tenant 3aa4a235-b6e2-48d5-9195-7fcf05b459b0```

Refer to the ```scripts/deploy.sh``` for more details on how to load the individual parts of the sample application.
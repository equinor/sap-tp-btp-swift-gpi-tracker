#!/bin/bash -e

# Deployment steps are defined from this point
# By default they are executed sequentially, but can also be executed individually with the -s <n> parameter 

if [ ! "$MODE" == "what-if" ]; then
    MODE=create
fi

s1_retrieve_vault_name() {
    echo -n "Retrieving the key vault name from the $CFG_BASELINE_DEPLOYMENT_NAME deployment... "
    VAULT_NAME=$(az deployment group show --name "$CFG_BASELINE_DEPLOYMENT_NAME" --resource-group "$CFG_BASELINE_RESOURCE_GROUP_NAME" \
        --query "properties.parameters.keyVaultName.value" -o tsv)
    echo "$VAULT_NAME"
}

s2_deploy_centos_vms() {
    echo Deploying CentOS VMs and load balancer
    "$SCRIPTDIR"/create-keypair.sh "$CFG_SSH_KEY_NAME" "$VAULT_NAME"
    ADMINPUBKEY=$(az keyvault secret show --name "$CFG_SSH_KEY_NAME"-pub --vault-name "$VAULT_NAME" --output tsv --query value)

    az deployment group $MODE --resource-group "$CFG_APP_RESOURCE_GROUP_NAME" --name "$CFG_CENTOS_DEPLOYMENT_NAME" \
        --subscription "$CFG_SUBSCRIPTION_NAME" --template-file "$TEMPLATEDIR"/centos/azuredeploy.json \
        --parameters @"$TEMPLATEDIR"/centos/"$CFG_ARM_DEPLOYMENT_PARAMETERS_FILE" --parameters adminPubKey="$ADMINPUBKEY" 
}

s3_deploy_centos_dns() {
    ILB_IP=$(az deployment group show --name "$CFG_CENTOS_DEPLOYMENT_NAME" --resource-group "$CFG_APP_RESOURCE_GROUP_NAME" \
         --query "properties.outputs.ilbIP.value" -o tsv)

    echo "Deploying DNS record for the CentOS load balancer with IP $ILB_IP"

    # The DNS record is deployed to another resource group, so it cannot be part of the deployment above
    az deployment group $MODE --resource-group "$CFG_DNS_RESOURCE_GROUP_NAME" --name "$CFG_CENTOS_DEPLOYMENT_NAME" \
        --subscription "$CFG_SUBSCRIPTION_NAME" --template-file "$TEMPLATEDIR"/centos/dns/azuredeploy.json \
        --parameters @"$TEMPLATEDIR"/centos/dns/"$CFG_ARM_DEPLOYMENT_PARAMETERS_FILE" \
        --parameters privateDnsZoneName="$CFG_DNS_ZONE_NAME" \
        --parameters ipv4="$ILB_IP"
}

s4_deploy_windows_vms() {
    echo Deploying Windows VMs
    "$SCRIPTDIR"/create-windows-pwd.sh "$CFG_WINDOWS_PWD_SECRET_NAME" "$VAULT_NAME"
    ADMINPWD=$(az keyvault secret show --name "$CFG_WINDOWS_PWD_SECRET_NAME" --vault-name "$VAULT_NAME" --output tsv --query value)

    resolve_ad_join_password

    # As an alternative to creating multiple VMs in one template, iterate over the parameter files
    # and load each of them individually. This is a suitable approach when several of the parameters are varying 
    # while the underlying template is the same.
    vms=($(ls $TEMPLATEDIR/windows/$ENV/vm*parameters.json | sort))
    i=1
    for vm in "${vms[@]}"
    do
        echo "Deploying VM $i/${#vms[@]}" 
        ((i=i+1))
	    az deployment group $MODE --resource-group "$CFG_APP_RESOURCE_GROUP_NAME" --name "$CFG_WINDOWS_DEPLOYMENT_NAME" \
            --subscription "$CFG_SUBSCRIPTION_NAME" --template-file "$TEMPLATEDIR"/windows/azuredeploy.json \
            --parameters @$vm --parameters adminPassword="$ADMINPWD" \
            --parameters domainJoinUserName="$CFG_AD_JOIN_USERNAME" --parameters domainJoinUserPassword="$ADJOINPWD" \
            --parameters ouPath="$CFG_AD_JOIN_OU_PATH" 
    done
}

# Helper function to resolve the domain join password, needs to be adjusted unless the target subscription is S013
resolve_ad_join_password() {
   ADJOINPWD=$(az keyvault secret show --name adjoinpwd --vault-name s013-ad --output tsv --query value) 
}

# End of step definitions. Mostly generic functionality below

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TEMPLATEDIR=$SCRIPTDIR/../templates

if [ -z "$ENV" ]; then
    echo "The ENV environment variable needs to be set, and match a file in the /config folder, e.g. 'dev' or 'test'"
    exit 1
fi

usage() {
    echo "Usage: "
    echo   " -s        List defined steps within the script"
    echo   " -s <num>  Execute specific step(s), e.g. -s 1 or -s 1,2 (no spaces between numbers)"
    exit 0
}

while [ "$1" != "" ]; do
    case $1 in
        -s | --step) shift
            use_steps=1 
            if [ "$1" != "" ]; then
                # Read the potentially comma separated steps into the step_nums array
                IFS=', ' read -r -a step_nums <<< "$1"
                shift
            fi 
            continue
            ;;
        -h | --help) usage
    esac
    shift
done

# shellcheck disable=SC1090
source "$SCRIPTDIR/../config/$ENV.cfg"

print_startup_summary() {
    ACTIVEUSER=$(az account show --query user.name -o tsv)
    echo ""
    echo "Environment:           $ENV" 
    echo "Running deployment as: $ACTIVEUSER"
    echo "Target resource group: $CFG_APP_RESOURCE_GROUP_NAME"
    echo "Mode:                  $MODE"
    echo ""
}

# Fetch all the declared steps within this script into a sorted array called steps
# Only function names starting with s<num>_ are considered steps, e.g. s45_some_operation
steps=($(declare -F | awk '{print $NF}' | sort | egrep -o "^[sS][0-9]+_.*$") )

if [ ! -z $use_steps ] && [ -z $step_nums ]; then
    # -s used as an argument, but no step number => print all the steps and exit
    echo "Steps in the script that can be executed individually:"
    i=1
    for step in "${steps[@]}"
    do
        echo "  $i: $step"
        ((i=i+1))
    done
    exit 0
fi

print_startup_summary
if [ ! -z $use_steps ] && [ ! -z $step_nums ]; then
    # -s used as an argument, and a step number(s) is/are defined => run the specific steps
    for i in "${step_nums[@]}"
    do
        echo ""
        echo "******************************************************"
        echo "* Step $i/${#steps[@]}: ${steps[$i-1]}" 
        echo "******************************************************"
        echo ""
	    ${steps[$i-1]}
    done
else
    # default - run all the steps
    i=1
    for step in "${steps[@]}"
    do
        echo ""
        echo "******************************************************"
        echo "* Step $i/${#steps[@]}: $step" 
        echo "******************************************************"
        echo ""
        ((i=i+1))
	    $step
    done
fi
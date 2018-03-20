# these demos use the Azure CLI
# install following instructions from here:
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
# then login:
# az login
# see which subscription is selected
# az account show --query name -o tsv
# select the subscription you want to use
# az account set -s "MySub"

# create a resource group
$resourceGroup = "AciElasticSearchDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

# create an elasticsearch container with 4GB RAM and 2 CPUs
$containerGroupName = "es-demo"
az container create --image elasticsearch:latest --name $containerGroupName -g $resourceGroup `
        --ip-address public --dns-name-label es-aci --memory 4 --cpu 2 --ports 9200

# see whether it's finished provisioning yet
az container show -g $resourceGroup -n $containerGroupName --query provisioningState -o tsv

# get the domain name
$fqdn = az container show -g $resourceGroup -n $containerGroupName --query ipAddress.fqdn -o tsv

# make a request to elasticsearch to check it's working
(Invoke-WebRequest -Uri "http://$($fqdn):9200/?pretty").content

# when we're done delete this resource group and the container within it
az group delete -n $resourceGroup -y


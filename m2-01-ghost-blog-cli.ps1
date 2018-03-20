# create a resource group
$resourceGroup = "AciGhostDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

# create a new container group using the ghost blog image
$containerGroupName = "ghost-blog1"
az container create -g $resourceGroup -n $containerGroupName --image ghost `
          –ports 2368 –ip-address public –dns-name-label ghostaci 

# find out the domain name
$fqdn = az container show -g $resourceGroup -n $containerGroupName --query ipAddress.fqdn -o tsv

# visit the blog home page
$site = "http://$($fqdn):2368"

Start-Process $site

# visit the blog admin page
Start-Process "$site/ghost"

# check the logs for this container group
az container logs -n $containerGroupName -g $resourceGroup 

# delete the resource group including the container group
az group delete -n $resourceGroup -y
$resourceGroup = "AciGhostDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

$containerGroupName = "ghost-blog1"
az container create -g $resourceGroup -n $containerGroupName --image ghost `
          –ports 2368 –ip-address public –dns-name-label ghostaci 

$fqdn = az container show -g $resourceGroup -n $containerGroupName --query ipAddress.fqdn -o tsv

$site = "http://$($fqdn):2368"

Start-Process $site

Start-Process "$site/ghost"

az container logs -n $containerGroupName -g $resourceGroup 

az group delete -n $resourceGroup -y
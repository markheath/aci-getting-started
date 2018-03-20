$resourceGroup = "AciWindowsDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

$containerGroupName = "miniblog-win"
az container create -g $resourceGroup -n $containerGroupName --image markheath/miniblogcore:v1 `
    --ip-address public --dns-name-label miniblog-win --os-type windows --memory 2 --cpu 2 --restart-policy OnFailure

$fqdn = az container show -g $resourceGroup -n $containerGroupName --query ipAddress.fqdn -o tsv

$site = "http://$($fqdn)"

Start-Process $site

az container logs -n $containerGroupName -g $resourceGroup 

az group delete -n $resourceGroup -y
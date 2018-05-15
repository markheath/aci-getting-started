# create a resource group
$resourceGroup = "AciWindowsDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

# create our container running a Windows ASP.NET Core application
$containerGroupName = "miniblog-win"
az container create -g $resourceGroup -n $containerGroupName `
    --image markheath/miniblogcore:v1 `
    --ip-address public `
    --dns-name-label miniblog-win `
    --os-type windows `
    --memory 2 --cpu 2 `
    --restart-policy OnFailure

# get its domain name:
$fqdn = az container show -g $resourceGroup -n $containerGroupName --query ipAddress.fqdn -o tsv

# visit the site in a browser
$site = "http://$($fqdn)"

Start-Process $site

# inspect the logs
az container logs -n $containerGroupName -g $resourceGroup 

# when we're done, clean up by deleting the resource group
az group delete -n $resourceGroup -y
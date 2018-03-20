$resourceGroup = "AciElasticSearchDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

$containerGroupName = "es-demo"
az container create --image elasticsearch:latest --name $containerGroupName -g $resourceGroup `
        --ip-address public --dns-name-label es-aci --memory 4 --cpu 2 --ports 9200

$fqdn = az container show -g $resourceGroup -n $containerGroupName --query ipAddress.fqdn -o tsv

(Invoke-WebRequest -Uri "http://$($fqdn):9200/?pretty").content

az group delete -n $resourceGroup -y


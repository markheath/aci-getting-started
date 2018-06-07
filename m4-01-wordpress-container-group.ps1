# using a single ACI container group to run wordpress and mysql
# https://docs.microsoft.com/en-gb/azure/templates/microsoft.containerinstance/containergroups
$resourceGroup = "AciGroupDemo"
$location="westeurope"
az group create -n $resourceGroup -l $location

$containerGroupName = "myWordpress"
$dnsNameLabel = "wordpressaci"
$mySqlPassword = "My5q1P@s5w0rd!"

az group deployment create `
    -n "WordPressDeployment" -g $resourceGroup `
    --template-file "aci-wordpress.json" `
    --parameters "mysqlPassword=$mySqlPassword" `
    --parameters "containerGroupName=$containerGroupName" `
    --parameters "dnsNameLabel=$dnsNameLabel"

az container list -g $resourceGroup -o table

az container show -g $resourceGroup -n $containerGroupName `
        --query ipAddress.fqdn -o tsv

# view the logs for the back end container
az container logs -g $resourceGroup -n $containerGroupName --container-name "back-end"

# run a bash session on the front end container
az container exec -g $resourceGroup -n $containerGroupName --container-name "front-end" `
    --exec-command "/bin/bash"

# export details of this container group to a yaml file
az container export -g $resourceGroup -n $containerGroupName -f "aci-wordpress.yaml"

az container delete -g $resourceGroup -n $containerGroupName --yes

az group delete --name $resourceGroup --yes --no-wait
$resourceGroup = "AciSecretsDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

$containerGroupName = "secretdemo"
az container create -n $containerGroupName -g $resourceGroup `
    --image alpine --restart-policy never `
    --secrets "PASSWORD=VerySecret!" `
    --secrets-mount-path "/mnt/secrets" `
    --command-line "/bin/sh -c 'cat /mnt/secrets/PASSWORD'"

az container show -n $containerGroupName -g $resourceGroup 

az container logs -n $containerGroupName -g $resourceGroup 

az container delete -n $containerGroupName -g $resourceGroup

az group delete -n $resourceGroup -y
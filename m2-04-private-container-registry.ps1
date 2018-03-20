# create a resource group to use
$resourceGroup = "AciPrivateRegistryDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

# create an Azure Container Registry
$acrName = "mheathacr"
az acr create -g $resourceGroup -n $acrName --sku Basic --admin-enabled true

# docker login to ACR (assumes we have docker installed) - decided against this as it gave scary warning about disabling wincred
# az acr login --name $

# az acr update -n $acrName --admin-enabled true

$acrUser = (az acr show --name $acrName --query loginServer -o tsv)
$acrPassword = (az acr credential show --name $acrName --query "passwords[0].value" -o tsv)
$loginServer = az acr show --name $acrName --query loginServer --output tsv
docker login -u $acrName -p $acrPassword $loginServer 

$imageName = "mystaticsite"
$imageTag = "$loginServer/$($imageName):v1"
docker tag "$($imageName):v1" $imageTag
docker push $imageTag
az acr repository list --name $acrName --output table


$containerGroupName = "aci-acr"
az container create --resource-group $resourceGroup --name $containerGroupName --image $imageTag `
    --cpu 1 --memory 1 --registry-username $acrUser --registry-password $acrPassword `
    --dns-name-label "aciacr" --ports 80


$fqdn = az container show -g $resourceGroup -n $containerGroupName --query ipAddress.fqdn -o tsv

$site = "http://$($fqdn)"

Start-Process $site

az container logs -n $containerGroupName -g $resourceGroup

az group delete -n $resourceGroup -y
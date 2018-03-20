$resourceGroup = "AciPrivateRegistryDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

$acrName = "my-acr"
az acr create -g $resourceGroup -n $acrName --sku Basic
az acr login --name $acrName
$loginServer = az acr show --name $acrName --query loginServer --output tsv

$imageName = "my-image"
$imageTag = "$loginServer/$($imageName):v1"
docker tag $imageName $imageTag
docker push $imageTag
az acr repository list --name $acrName --output table

$acrUser = (az acr show --name $acrName --query loginServer -o tsv)
$acrPassword = (az acr credential show --name $acrName --query "passwords[0].value" -o tsv)

$containerGroupName = "aci-acr"
az container create --resource-group $resourceGroup --name $containerGroupName --image $imageTag `
    --cpu 1 --memory 1 --registry-username $acrUser --registry-password $acrPassword `
    --dns-name-label aci-acr --ports 80


$fqdn = az container show -g $resourceGroup -n $containerGroupName --query ipAddress.fqdn -o tsv

$site = "http://$($fqdn)"

Start-Process $site

az container logs -n $containerGroupName -g $resourceGroup 

az group delete -n $resourceGroup -y
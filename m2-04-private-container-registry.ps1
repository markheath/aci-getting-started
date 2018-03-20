# create a resource group to use
$resourceGroup = "AciPrivateRegistryDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

# create an Azure Container Registry
$acrName = "mheathacr"
az acr create -g $resourceGroup -n $acrName --sku Basic --admin-enabled true

# login to the registry with docker
$acrPassword = az acr credential show --name $acrName --query "passwords[0].value" -o tsv
$loginServer = az acr show --name $acrName --query loginServer --output tsv
docker login -u $acrName -p $acrPassword $loginServer

# tag the image we want to use in our registry
$imageName = "mystaticsite"
$imageTag = "$loginServer/$($imageName):v1"
docker tag "$($imageName):v1" $imageTag

# push the image to our registry
docker push $imageTag

# see what images are in our registry
az acr repository list --name $acrName --output table

# create a new container group using the image from the private registry
$containerGroupName = "aci-acr"
az container create -g $resourceGroup -n $containerGroupName --image $imageTag `
    --cpu 1 --memory 1 --registry-username $loginServer --registry-password $acrPassword `
    --dns-name-label "aciacr" --ports 80

# get the site address and launch in a browser
$fqdn = az container show -g $resourceGroup -n $containerGroupName --query ipAddress.fqdn -o tsv
Start-Process "http://$($fqdn)"

# view the logs for our container
az container logs -n $containerGroupName -g $resourceGroup

# delete the resource group (ACR and container group)
az group delete -n $resourceGroup -y
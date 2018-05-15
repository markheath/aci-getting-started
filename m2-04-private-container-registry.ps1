# create a resource group to use
$resourceGroup = "AciPrivateRegistryDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

# create an Azure Container Registry
$acrName = "mheathacr"
az acr create -g $resourceGroup -n $acrName `
    --sku Basic --admin-enabled true

# login to the registry with docker
$acrPassword = az acr credential show -n $acrName `
    --query "passwords[0].value" -o tsv
$loginServer = az acr show -n $acrName `
    --query loginServer --output tsv
docker login -u $acrName -p $acrPassword $loginServer

# tag the image we want to use in our registry
$image = "mystaticsite:v1"
$imageTag = "$loginServer/$image"
docker tag $image $imageTag

# push the image to our registry
docker push $imageTag

# see what images are in our registry
az acr repository list -n $acrName --output table

# create a new container group using the image from the private registry
$containerGroupName = "aci-acr"
az container create -g $resourceGroup `
    -n $containerGroupName `
    --image $imageTag --cpu 1 --memory 1 `
    --registry-username $loginServer `
    --registry-password $acrPassword `
    --dns-name-label "aciacr" --ports 80

# get the site address and launch in a browser
$fqdn = az container show -g $resourceGroup -n $containerGroupName `
    --query ipAddress.fqdn -o tsv
Start-Process "http://$($fqdn)"

# view the logs for our container
az container logs -n $containerGroupName -g $resourceGroup

# delete the resource group (ACR and container group)
az group delete -n $resourceGroup -y
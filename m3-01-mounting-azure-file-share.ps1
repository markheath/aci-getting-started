# good tutorial available at https://docs.microsoft.com/en-us/azure/container-instances/container-instances-volume-azure-files
$resourceGroup = "AciVolumeDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

$storageAccountName = "acishare$(Get-Random -Minimum 1000 -Maximum 10000)"

# create a storage account
az storage account create -g $resourceGroup -n $storageAccountName `
    --sku Standard_LRS

# get the connection string for our storage account
$storageConnectionString = az storage account show-connection-string -n $storageAccountName -g $resourceGroup --query connectionString -o tsv
# export it as an environment variable
$env:AZURE_STORAGE_CONNECTION_STRING = $storageConnectionString

# Create the file share
$shareName="acishare"
az storage share create -n $shareName

# upload 
$filename = "intro.mp4"
$localFile = "C:\Users\markh\Pictures\Camera Roll\$filename"
az storage file upload -s $shareName --source "$localFile"

# get the key for this storage account
$storageKey=$(az storage account keys list -g $resourceGroup --account-name $storageAccountName --query "[0].value" --output tsv)

$containerGroupName = "transcode"
az container create `
    -g $resourceGroup `
    -n $containerGroupName `
    --image jrottenberg/ffmpeg `
    --restart-policy never `
    --azure-file-volume-account-name $storageAccountName `
    --azure-file-volume-account-key $storageKey `
    --azure-file-volume-share-name $shareName `
    --azure-file-volume-mount-path "/mnt/azfile" `
    --command-line "ffmpeg -i /mnt/azfile/$filename -vf  ""thumbnail,scale=640:360"" -frames:v 1 /mnt/azfile/thumb.png"

az container logs -g $resourceGroup -n $containerGroupName 

az container show -g $resourceGroup -n $containerGroupName --query provisioningState

az storage file list -s $shareName -o table

$downloadThumbnailPath = "C:\Users\markh\Downloads\thumb.png"
az storage file download -s $shareName -p "thumb.png" --dest $downloadThumbnailPath
Start-Process $downloadThumbnailPath

#az container delete -g $resourceGroup -n $containerGroupName

# delete the resource group (file share and container group)
az group delete -n $resourceGroup -y

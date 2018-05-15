
# create a resource group
$resourceGroup = "AciGitDemo"
$location = "westeurope" #"westcentralus"
az group create -n $resourceGroup -l $location

# we want our ACI container to deploy to a web app, so let's create an app service plan...
$planName = "AciDemo"
az appservice plan create -n $planName -g $resourceGroup `
    -l $location --sku B1

# ... and a web app
$appName = "acicake"
az webapp create -n $appName -g $resourceGroup --plan $planName

# get the deployment credentials
$user = az webapp deployment list-publishing-profiles `
    -n $appName -g $resourceGroup `
    --query "[?publishMethod=='MSDeploy'].userName" -o tsv

$pass = az webapp deployment list-publishing-profiles `
    -n $appName -g $resourceGroup `
    --query "[?publishMethod=='MSDeploy'].userPWD" -o tsv

function CreateContainerCli  {
    # currently the az container create command doesn't support mounting git repos
    # this is with some made up command line arguments of --gitrepo-repository and 
    # --gitrepo-mount-path to show mounting a github repository
    # we are also setting environment variables
$containerGroupName = "cakebuilder"
#$commandLine = "/bin/bash -c ""chmod 755 ./build.sh && ./build.sh -Target=Default --settings_skipverification=true"""
az container create `
    -g $resourceGroup `
    -n $containerGroupName `
    --image "markheath/cakebuilder:0.1" `
    --gitrepo-url https://github.com/markheath/aspnet-core-cake `
    --gitrepo-mount-path "/src" `
    --restart-policy never `
    -e KUDU_CLIENT_BASEURI=https://$appName.scm.azurewebsites.net `
       KUDU_CLIENT_USERNAME=$user KUDU_CLIENT_PASSWORD=$pass `
    --command-line "/bin/bash -c 'chmod 755 ./build.sh && ./build.sh -Target=Default --settings_skipverification=true'"
}

function ArmDeploy {
    # instead we'll deploy using an ARM template
$containerGroupName = "cakebuilder"
az group deployment create `
    -n TestDeployment -g $resourceGroup `
    --template-file "cake-builder.json" `
    --parameters "KUDU_CLIENT_BASEURI=https://$appName.scm.azurewebsites.net" `
    --parameters "KUDU_CLIENT_USERNAME=$user" `
    --parameters "KUDU_CLIENT_PASSWORD=$pass" `
    --parameters "containerGroupName=$containerGroupName"
#    --parameters commandLine='./build.sh -Target=Default --settings_skipverification=true'
}

function LocalDockerTest {
    # trying it out locally with docker and the source code in a temp folder
    docker run -v c:/users/markh/code/azure/temp1:/src `
        -e KUDU_CLIENT_BASEURI=https://$appName.scm.azurewebsites.net `
        -e KUDU_CLIENT_USERNAME=$user `
        -e KUDU_CLIENT_PASSWORD=$pass `
        markheath/cakebuilder:0.1
}




# enable run from zip deployment technique (currently more reliable if we set it after our first upload to sitepackages)
az webapp config appsettings set -n $appName -g $resourceGroup `
    --settings WEBSITE_RUN_FROM_ZIP=1

# see what's in Kudu
Start-Process https://$appName.scm.azurewebsites.net

# see if the deploy worked
Start-Process https://$appName.azurewebsites.net


# check the logs for this container group
az container logs -n $containerGroupName -g $resourceGroup 

az container show -n $containerGroupName -g $resourceGroup 

# delete just the container
az container delete -n $containerGroupName -g $resourceGroup -y

# delete the resource group including the container group
az group delete -n $resourceGroup -y
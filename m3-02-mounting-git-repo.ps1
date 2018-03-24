
# create a resource group
$resourceGroup = "AciGitDemo"
$location = "westeurope"
az group create -n $resourceGroup -l $location

# we want our ACI container to deploy to a web app, so let's create an app service plan...
$planName = "AciDemo"
az appservice plan create -n $planName -g $resourceGroup -l $location --sku B1

# ... and a web app
$appName = "acicake"
az webapp create -n $appName -g $resourceGroup --plan $planName

# get the deployment credentials
$user = az webapp deployment list-publishing-profiles -n $appName -g $resourceGroup `
    --query "[?publishMethod=='MSDeploy'].userName" -o tsv

$pass = az webapp deployment list-publishing-profiles -n $appName -g $resourceGroup `
    --query "[?publishMethod=='MSDeploy'].userPWD" -o tsv

# enable run from zip deployment technique
az webapp config appsettings set -n $appName -g $resourceGroup --settings WEBSITE_USE_ZIP=1

function CreateContainerCli  {
    # currently the az container create command doesn't support mounting git repos
    # this is with some made up command line arguments of --gitrepo-repository and 
    # --gitrepo-mount-path to show mounting a github repository
    # we are also setting environment variables
    $containerGroupName = "transcode"
    az container create `
        -g $resourceGroup `
        -n $containerGroupName `
        -e KUDU_CLIENT_BASEURI=https://$appName.scm.azurewebsites.net KUDU_CLIENT_USERNAME=$user KUDU_CLIENT_PASSWORD=$pass `
        --gitrepo-repository https://github.com/markheath/aspnet-core-cake `
        --gitrepo-mount-path "/src" `
        --image markheath/cakebuilder `
        --restart-policy never `
        --command-line "./build.sh -Target=Default --settings_skipverification=true"
}

function LocalDockerTest {
    # trying it out locally with docker and the source code in a temp folder
    docker run -v c:/users/markh/code/azure/temp1:/src `
        -e KUDU_CLIENT_BASEURI=https://$appName.scm.azurewebsites.net `
        -e KUDU_CLIENT_USERNAME=$user `
        -e KUDU_CLIENT_PASSWORD=$pass `
        markheath/cakebuilder:0.1
}

Start-Process https://$appName.azurewebsites.net

# instead we'll deploy using an ARM template
az group deployment create `
    -n TestDeployment -g $resourceGroup `
    --template-file "cake-builder.json" `
    --parameters "KUDU_CLIENT_BASEURI=https://$appName.scm.azurewebsites.net" `
    --parameters "KUDU_CLIENT_USERNAME=$user" `
    --parameters "KUDU_CLIENT_PASSWORD=$pass" `
    --parameters "containerGroupName=$containerGroupName" `
    --parameters commandLine='./build.sh -Target=Default --settings_skipverification=true' `

# check the logs for this container group
az container logs -n $containerGroupName -g $resourceGroup 

# delete the resource group including the container group
az group delete -n $resourceGroup -y
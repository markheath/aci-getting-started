# This demo does the same as the previous, but using Azure powershell
# installation instructions available here:
# https://github.com/Azure/azure-powershell
# To get started:
# Import-Module -Name AzureRM
# Login-AzureRmAccount
# Get-AzureRmSubscription to list all, Get-AzureRmContext to see currently selected subscription
# Set-AzureRmContext -SubscriptionName

# create a resource group
$resourceGroup = "AciGhostDemo2"
$location = "westeurope"
New-AzureRmResourceGroup -Name $resourceGroup -Location $location

# create the container
$containerGroupName = "ghost-blog2"
New-AzureRmContainerGroup -ResourceGroupName $resourceGroup -Name $containerGroupName -Image ghost `
     -Port 2368 -IpAddressType Public -DnsNameLabel ghostaci2

# check up on its provisioning state
(Get-AzureRmContainerGroup -ResourceGroupName $resourceGroup -Name $containerGroupName).ProvisioningState

# get its domain name:
$fqdn = (Get-AzureRmContainerGroup -ResourceGroupName $resourceGroup -Name $containerGroupName).Fqdn


$site = "http://$($fqdn):2368"

# visit the website
Start-Process $site

# visit the admin page
Start-Process "$site/ghost"

# view the logs
Get-AzureRmContainerInstanceLog -ResourceGroupName $resourceGroup -ContainerGroupName $containerGroupName

# when we're done, delete the resource group, including the container
Remove-AzureRmResourceGroup -Name $resourceGroup -Force



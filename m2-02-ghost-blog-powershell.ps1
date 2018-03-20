# https://github.com/Azure/azure-powershell
# Import-Module -Name AzureRM
# Login-AzureRmAccount
# Get-AzureRmSubscription
# Set-AzureRmContext -SubscriptionName

$resourceGroup = "AciGhostDemo2"
$location = "westeurope"
New-AzureRmResourceGroup -Name $resourceGroup -Location $location

$containerGroupName = "ghost-blog2"
New-AzureRmContainerGroup -ResourceGroupName $resourceGroup -Name $containerGroupName -Image ghost `
     -Port 2368 -IpAddressType Public -DnsNameLabel ghostaci2


$fqdn = (Get-AzureRmContainerGroup -ResourceGroupName $resourceGroup -Name $containerGroupName).Fqdn

$site = "http://$($fqdn):2368"

Start-Process $site

Start-Process "$site/ghost"

Get-AzureRmContainerInstanceLog -ResourceGroupName $resourceGroup -ContainerGroupName $containerGroupName

Remove-AzureRmResourceGroup -Name $resourceGroup -Force



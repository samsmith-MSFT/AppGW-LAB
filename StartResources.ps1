# Start AppGW
$AppGw = Get-AzApplicationGateway -Name "my-app-gateway" -ResourceGroupName $answers.resourceGroupName
Start-AzApplicationGateway -ApplicationGateway $AppGw

# Check AppGW status
do {
    $AppGwStatus = (Get-AzApplicationGateway -Name "my-app-gateway" -ResourceGroupName $answers.resourceGroupName).OperationalState
    Write-Host "Waiting for Application Gateway to start. Current status: $AppGwStatus"
    Start-Sleep -Seconds 10
} while ($AppGwStatus -ne "Running")

# Start Azure Firewall
$azfw = Get-AzFirewall -Name "azfw-hub" -ResourceGroupName $answers.resourceGroupName
$azfw.Allocate()
Set-AzFirewall -AzureFirewall $azfw

# Check Azure Firewall status
do {
    $azfwStatus = (Get-AzFirewall -Name "azfw-hub" -ResourceGroupName $answers.resourceGroupName).ProvisioningState
    Write-Host "Waiting for Azure Firewall to start. Current status: $azfwStatus"
    Start-Sleep -Seconds 10
} while ($azfwStatus -ne "Succeeded")

# Start AppService
$AppService = Get-AzWebApp -Name $answers.appServiceName -ResourceGroupName $answers.resourceGroupName
Start-AzWebApp -WebApp $AppService

# Check AppService status
do {
    $AppServiceStatus = (Get-AzWebApp -Name $answers.appServiceName -ResourceGroupName $answers.resourceGroupName).State
    Write-Host "Waiting for App Service to start. Current status: $AppServiceStatus"
    Start-Sleep -Seconds 10
} while ($AppServiceStatus -ne "Running")
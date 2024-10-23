$answers = Get-Content -Raw -Path "answers.json" | ConvertFrom-Json

# Stop AppGW
$AppGw = Get-AzApplicationGateway -Name "my-app-gateway" -ResourceGroupName $answers.resourceGroupName
Stop-AzApplicationGateway -ApplicationGateway $AppGw

# Check AppGW status
do {
    $AppGwStatus = (Get-AzApplicationGateway -Name "my-app-gateway" -ResourceGroupName $answers.resourceGroupName).OperationalState
    Write-Host "Waiting for Application Gateway to stop. Current status: $AppGwStatus"
    Start-Sleep -Seconds 10
} while ($AppGwStatus -ne "Stopped")

# Stop Azure Firewall
$azfw = Get-AzFirewall -Name "azfw-hub" -ResourceGroupName $answers.resourceGroupName
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw

# Check Azure Firewall status
do {
    $azfwStatus = (Get-AzFirewall -Name "azfw-hub" -ResourceGroupName $answers.resourceGroupName).ProvisioningState
    Write-Host "Waiting for Azure Firewall to stop. Current status: $azfwStatus"
    Start-Sleep -Seconds 10
} while ($azfwStatus -ne "Succeeded")

# Stop AppService
$AppService = Get-AzWebApp -Name $answers.appServiceName -ResourceGroupName $answers.resourceGroupName
Stop-AzWebApp -WebApp $AppService

# Check AppService status
do {
    $AppServiceStatus = (Get-AzWebApp -Name $answers.appServiceName -ResourceGroupName $answers.resourceGroupName).State
    Write-Host "Waiting for App Service to stop. Current status: $AppServiceStatus"
    Start-Sleep -Seconds 10
} while ($AppServiceStatus -ne "Stopped")
$answers = Get-Content -Raw -Path "answers.json" | ConvertFrom-Json

# Stop AppGW
$AppGw = Get-AzApplicationGateway -Name "my-app-gateway" -ResourceGroupName $answers.resourceGroupName
Stop-AzApplicationGateway -ApplicationGateway $AppGw

# Stop Azure Firewall
$azfw = Get-AzFirewall -Name "azfw-hub" -ResourceGroupName $answers.resourceGroupName
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw

# Stop AppService
$AppService = Get-AzWebApp -Name $answers.appServiceName -ResourceGroupName $answers.resourceGroupName
Stop-AzWebApp -WebApp $AppService
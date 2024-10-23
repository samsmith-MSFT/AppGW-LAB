$answers = Get-Content -Raw -Path "answers.json" | ConvertFrom-Json

# Start AppGW
$AppGw = Get-AzApplicationGateway -Name "my-app-gateway" -ResourceGroupName $answers.resourceGroupName
Start-AzApplicationGateway -ApplicationGateway $AppGw

# Start Azure Firewall
$azfw = Get-AzFirewall -Name "azfw-hub" -ResourceGroupName $answers.resourceGroupName
$azfw.Allocate()
Set-AzFirewall -AzureFirewall $azfw

# Start AppService
$AppService = Get-AzWebApp -Name $answers.appServiceName -ResourceGroupName $answers.resourceGroupName
Start-AzWebApp -Name $answers.appServiceName -ResourceGroupName $answers.resourceGroupName
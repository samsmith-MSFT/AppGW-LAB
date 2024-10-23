$answers = Get-Content -Raw -Path "answers.json" | ConvertFrom-Json

# Stop AppGW
$AppGw = Get-AzApplicationGateway -Name "my-app-gateway" -ResourceGroupName $answers.resourceGroupName
Start-AzApplicationGateway -ApplicationGateway $AppGw

# Stop Azure Firewall
$azfw = Get-AzFirewall -Name "azfw-hub" -ResourceGroupName $answers.resourceGroupName
$azfw.Allocate()
Set-AzFirewall -AzureFirewall $azfw
# Change to the modules directory
Set-Location \ | Set-Location -Path "/workspaces/AppGW-LAB/Modules"

$order = @("3-AppGW", "2-AppService", "1-Hub-Spoke")

# Get the root directory
$rootDir = Get-Location

foreach ($dir in $order) {
    # Construct the full path to the directory
    $fullPath = Join-Path -Path $rootDir -ChildPath $dir
    
    if (Test-Path -Path $fullPath) {
        # Navigate to the directory
        Set-Location -Path $fullPath
        
        Write-Host "Running terraform destroy in $fullPath"
        
        # Run terraform destroy with auto-approve
        terraform destroy -auto-approve
        
        # Navigate back to the root directory
        Set-Location -Path $rootDir
    } else {
        Write-Host "Directory $fullPath not found"
    }
}

# Change to the modules directory
Set-Location -Path "Modules"

$order = @("3-AppGW", "2-AppService", "1-Hub-Spoke")

# Get the root directory
$rootDir = Get-Location

foreach ($dir in $order) {
    # Construct the full path to the directory
    $fullPath = Join-Path -Path $rootDir -ChildPath $dir
    
    if (Test-Path -Path $fullPath) {
        # Navigate to the directory
        Set-Location -Path $fullPath
        
        Write-Host "Running terraform destroy in $fullPath"
        
        # Run terraform destroy with auto-approve
        terraform destroy -auto-approve
        
        # Navigate back to the root directory
        Set-Location -Path $rootDir
    } else {
        Write-Host "Directory $fullPath not found"
    }
}

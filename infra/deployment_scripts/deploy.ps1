param(
    [string]$ResourceGroupName = "yt-trending-rg",
    [string]$Location = "eastus",
    [string]$ProjectName = "yttrending"
)

Write-Host "🚀 Starting YouTube Trending Project Deployment..." -ForegroundColor Green

# Check if Azure CLI is installed and logged in
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "✅ Azure CLI found: $($azVersion.'azure-cli')" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI not found. Please install Azure CLI first." -ForegroundColor Red
    exit 1
}

# Check if logged in to Azure
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Host "✅ Logged in as: $($account.user.name)" -ForegroundColor Green
} catch {
    Write-Host "❌ Not logged in to Azure. Please run 'az login' first." -ForegroundColor Red
    exit 1
}

# Create Resource Group
Write-Host "📦 Creating Resource Group: $ResourceGroupName" -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

# Deploy ARM Template
Write-Host "🔧 Deploying Azure Resources..." -ForegroundColor Yellow
$deploymentName = "yt-trending-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file "infra/arm_templates/main.json" `
    --parameters projectName=$ProjectName location=$Location `
    --name $deploymentName

# Get deployment outputs
$outputs = az deployment group show `
    --resource-group $ResourceGroupName `
    --name $deploymentName `
    --query properties.outputs `
    --output json | ConvertFrom-Json

Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resource Details:" -ForegroundColor Cyan
Write-Host "   Storage Account: $($outputs.storageAccountName.value)" -ForegroundColor White
Write-Host "   Data Factory: $($outputs.dataFactoryName.value)" -ForegroundColor White
Write-Host "   Databricks: $($outputs.databricksName.value)" -ForegroundColor White
Write-Host "   Synapse: $($outputs.synapseName.value)" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Upload your data to Azure Storage" -ForegroundColor White
Write-Host "   2. Configure Data Factory pipelines" -ForegroundColor White
Write-Host "   3. Set up Databricks notebooks" -ForegroundColor White
Write-Host "   4. Create Synapse tables" -ForegroundColor White
Write-Host ""
Write-Host "💡 Run 'az group show --name $ResourceGroupName' to view all resources" -ForegroundColor Yellow 
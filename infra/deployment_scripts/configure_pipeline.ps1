# YouTube Trending Project - Pipeline Configuration Script
# Run this after deploying Azure resources

param(
    [string]$ResourceGroupName = "yt-trending-rg",
    [string]$StorageAccountName = "yttrendingstorage",
    [string]$DataFactoryName = "yttrendingadf",
    [string]$DatabricksName = "yttrendingdb"
)

Write-Host "🔧 Configuring YouTube Trending Pipeline..." -ForegroundColor Green

# Get storage account key
Write-Host "📦 Getting Storage Account Key..." -ForegroundColor Yellow
$storageKey = az storage account keys list --resource-group $ResourceGroupName --account-name $StorageAccountName --query "[0].value" --output tsv

# Upload sample data to storage
Write-Host "📤 Uploading sample data to Azure Storage..." -ForegroundColor Yellow
if (Test-Path "ingestion/trending_items.json") {
    az storage blob upload `
        --account-name $StorageAccountName `
        --container-name "raw-data" `
        --name "trending_items.json" `
        --file "ingestion/trending_items.json" `
        --account-key $storageKey
    Write-Host "✅ Uploaded trending_items.json to raw-data container" -ForegroundColor Green
} else {
    Write-Host "⚠️  trending_items.json not found. Please run ingestion scripts first." -ForegroundColor Yellow
}

# Create ADF Linked Service for Storage
Write-Host "🔗 Creating ADF Linked Service..." -ForegroundColor Yellow
$linkedServiceJson = @"
{
    "name": "AzureStorageLinkedService",
    "properties": {
        "type": "AzureBlobStorage",
        "typeProperties": {
            "connectionString": {
                "type": "SecureString",
                "value": "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$storageKey;EndpointSuffix=core.windows.net"
            }
        }
    }
}
"@

$linkedServiceJson | Out-File -FilePath "orchestration/adf/linked_service_configured.json" -Encoding UTF8
Write-Host "✅ Created ADF Linked Service configuration" -ForegroundColor Green

# Get Databricks workspace URL
Write-Host "🔗 Getting Databricks Workspace URL..." -ForegroundColor Yellow
$databricksUrl = az databricks workspace show --resource-group $ResourceGroupName --name $DatabricksName --query "workspaceUrl" --output tsv

Write-Host "✅ Configuration completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Configuration Details:" -ForegroundColor Cyan
Write-Host "   Storage Account: $StorageAccountName" -ForegroundColor White
Write-Host "   Data Factory: $DataFactoryName" -ForegroundColor White
Write-Host "   Databricks URL: https://$databricksUrl" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Open Azure Data Factory Studio" -ForegroundColor White
Write-Host "   2. Import linked service from orchestration/adf/linked_service_configured.json" -ForegroundColor White
Write-Host "   3. Create datasets and pipelines" -ForegroundColor White
Write-Host "   4. Open Databricks workspace and upload notebooks" -ForegroundColor White
Write-Host ""
Write-Host "💡 ADF Studio: https://adf.azure.com" -ForegroundColor Yellow
Write-Host "💡 Databricks: https://$databricksUrl" -ForegroundColor Yellow 
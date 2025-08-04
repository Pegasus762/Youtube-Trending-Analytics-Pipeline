# 🚀 YouTube Trending Project - Azure Deployment Guide

This guide will help you deploy your YouTube trending data pipeline to Azure.

## 📋 Prerequisites

### Required Tools
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (latest version)
- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) (Windows) or Bash (Linux/Mac)
- [Python 3.8+](https://www.python.org/downloads/) with pip

### Azure Requirements
- Active Azure subscription with billing enabled
- Owner or Contributor permissions on the subscription
- Available quota for the following services:
  - Azure Storage Account
  - Azure Data Factory
  - Azure Databricks
  - Azure Synapse Analytics

## 🎯 Quick Start (Automated Deployment)

### Step 1: Login to Azure
```bash
az login
```

### Step 2: Run Deployment Script
```powershell
# Windows PowerShell
.\infra\deployment_scripts\deploy.ps1

# Or with custom parameters
.\infra\deployment_scripts\deploy.ps1 -ResourceGroupName "my-yt-project" -Location "westus2"
```

### Step 3: Configure Pipeline
```powershell
.\infra\deployment_scripts\configure_pipeline.ps1
```

## 🔧 Manual Deployment (Step-by-Step)

### Step 1: Create Resource Group
```bash
az group create --name yt-trending-rg --location eastus
```

### Step 2: Deploy Infrastructure
```bash
az deployment group create \
  --resource-group yt-trending-rg \
  --template-file infra/arm_templates/main.json \
  --parameters projectName=yttrending location=eastus
```

### Step 3: Get Resource Names
```bash
az deployment group show \
  --resource-group yt-trending-rg \
  --name yt-trending-deployment-YYYYMMDD-HHMMSS \
  --query properties.outputs
```

## 📊 Resource Details

After deployment, you'll have:

| Service | Purpose | Resource Name |
|---------|---------|---------------|
| **Storage Account** | Data Lake for raw and processed data | `yttrendingstorage` |
| **Data Factory** | Orchestration and data movement | `yttrendingadf` |
| **Databricks** | ETL processing and analytics | `yttrendingdb` |
| **Synapse Analytics** | Data warehouse and SQL processing | `yttrendingsynapse` |

## 🔗 Post-Deployment Configuration

### 1. Upload Data to Storage
```bash
# Get storage account key
STORAGE_KEY=$(az storage account keys list \
  --resource-group yt-trending-rg \
  --account-name yttrendingstorage \
  --query "[0].value" --output tsv)

# Upload trending data
az storage blob upload \
  --account-name yttrendingstorage \
  --container-name raw-data \
  --name trending_items.json \
  --file ingestion/trending_items.json \
  --account-key $STORAGE_KEY
```

### 2. Configure Azure Data Factory

1. **Open ADF Studio**: https://adf.azure.com
2. **Select your factory**: `yttrendingadf`
3. **Create Linked Service**:
   - Go to Manage → Linked Services → New
   - Choose "Azure Blob Storage"
   - Use connection string from `orchestration/adf/linked_service_configured.json`

4. **Create Datasets**:
   - Import `orchestration/adf/input_dataset.json`
   - Import `orchestration/adf/output_dataset.json`

5. **Create Pipeline**:
   - Import `orchestration/adf/sample_pipeline.json`

### 3. Configure Databricks

1. **Open Databricks**: https://your-workspace-url.azuredatabricks.net
2. **Upload Notebooks**:
   - Upload `transform/databricks_notebooks/sample_etl.py`
   - Create cluster with appropriate Spark version

3. **Configure Storage Access**:
   ```python
   spark.conf.set(
     "fs.azure.account.key.yttrendingstorage.blob.core.windows.net",
     "YOUR_STORAGE_KEY"
   )
   ```

### 4. Configure Synapse Analytics

1. **Open Synapse Studio**: https://web.azuresynapse.net
2. **Create Database**:
   ```sql
   CREATE DATABASE yt_trending_db;
   ```

3. **Create Tables**:
   - Run `warehouse/synapse_sql/create_trending_table.sql`

## 🔄 Data Pipeline Flow

```
YouTube API → Azure Storage → Databricks → Synapse → BI Tools
     ↓              ↓              ↓           ↓         ↓
  fetch_yt.py   raw-data    ETL Notebook   Tables   Dashboard
```

## 💰 Cost Optimization

### Development Environment
- **Storage**: Standard_LRS (cheapest)
- **Databricks**: Auto-termination enabled
- **Synapse**: Pause when not in use
- **Data Factory**: Pay-per-use

### Production Environment
- **Storage**: Standard_GRS (redundancy)
- **Databricks**: Reserved instances
- **Synapse**: Dedicated SQL pool
- **Monitoring**: Azure Monitor enabled

## 🛠️ Troubleshooting

### Common Issues

1. **"Resource not found"**
   - Check resource group exists
   - Verify resource names match

2. **"Permission denied"**
   - Ensure you have Owner/Contributor role
   - Check subscription is active

3. **"Quota exceeded"**
   - Request quota increase
   - Use different region

4. **"Storage connection failed"**
   - Verify storage account key
   - Check container names

### Debug Commands

```bash
# Check resource group
az group show --name yt-trending-rg

# List all resources
az resource list --resource-group yt-trending-rg

# Check deployment status
az deployment group list --resource-group yt-trending-rg

# Get storage account keys
az storage account keys list --resource-group yt-trending-rg --account-name yttrendingstorage
```

## 🔐 Security Best Practices

1. **Use Managed Identity** where possible
2. **Store secrets** in Azure Key Vault
3. **Enable encryption** at rest and in transit
4. **Set up RBAC** with least privilege
5. **Monitor access** with Azure Monitor

## 📈 Monitoring and Alerting

### Set up Alerts
1. **Data Factory**: Pipeline failures
2. **Databricks**: Job failures
3. **Storage**: High usage
4. **Synapse**: Query performance

### Log Analytics
- Enable diagnostic settings
- Set up log retention
- Create custom dashboards

## 🚀 Next Steps

1. **Test the pipeline** end-to-end
2. **Set up scheduling** for data ingestion
3. **Create dashboards** in Power BI/Tableau
4. **Implement monitoring** and alerting
5. **Optimize performance** based on usage

## 📞 Support

- **Azure Documentation**: https://docs.microsoft.com/azure/
- **Data Factory**: https://docs.microsoft.com/azure/data-factory/
- **Databricks**: https://docs.microsoft.com/azure/databricks/
- **Synapse**: https://docs.microsoft.com/azure/synapse-analytics/

---

**Happy Deploying! 🎉** 
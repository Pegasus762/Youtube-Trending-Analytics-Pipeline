Create Azure Data Factory

az datafactory create `
  --resource-group yt-trending `
  --factory-name yttrendingadf `
  --location "Southeast Asia"

Create Azure Databricks Workspace

  az databricks workspace create `
  --resource-group yt-trending `
  --name yttrendingdb `
  --location southeastasia `
  --sku standard


az storage blob upload \
  --account-name yttrendingdata \
  --container-name raw \
  --name trending.json \
  --file trending.json \
  --auth-mode login




✅ Summary of Outputs
Step	                Output
Ingestion	            trending.json in raw
ADF Copy	            processed_trending.json in curated
Databricks Transform	Shown in notebook + optionally written to curated/final_output/



{
  "name": "YouTubeTrendingPipeline",
  "properties": {
    "activities": [
      {
        "name": "ValidateInputData",
        "type": "Validation",
        "inputs": [
          { "referenceName": "InputDataset", "type": "DatasetReference" }
        ],
        "typeProperties": {
          "timeout": "00:05:00",
          "sleep": 10,
          "minimumSize": 1
        }
      },
      {
        "name": "TransformTrendingData",
        "type": "Copy",
        "inputs": [
          { "referenceName": "InputDataset", "type": "DatasetReference" }
        ],
        "outputs": [
          { "referenceName": "TransformedDataset", "type": "DatasetReference" }
        ],
        "typeProperties": {
          "source": { "type": "JsonSource" },
          "sink": { "type": "JsonSink" },
          "enableStaging": false
        }
      },
      {
        "name": "ProcessWithDatabricks",
        "type": "DatabricksNotebook",
        "inputs": [
          { "referenceName": "TransformedDataset", "type": "DatasetReference" }
        ],
        "outputs": [
          { "referenceName": "ProcessedDataset", "type": "DatasetReference" }
        ],
        "typeProperties": {
          "notebookPath": "/Shared/TrendingETL",
          "baseParameters": {
            "input_path": "@pipeline().parameters.input_path",
            "output_path": "@pipeline().parameters.output_path"
          }
        }
      },
      {
        "name": "LoadToSynapse",
        "type": "Copy",
        "inputs": [
          { "referenceName": "ProcessedDataset", "type": "DatasetReference" }
        ],
        "outputs": [
          { "referenceName": "SynapseDataset", "type": "DatasetReference" }
        ],
        "typeProperties": {
          "source": { "type": "JsonSource" },
          "sink": { 
            "type": "SqlSink",
            "writeBehavior": "insert"
          }
        }
      },
      {
        "name": "SendNotification",
        "type": "WebActivity",
        "dependsOn": [
          { "activity": "LoadToSynapse", "dependencyConditions": ["Succeeded"] }
        ],
        "typeProperties": {
          "url": "https://your-webhook-url.com/notify",
          "method": "POST",
          "body": {
            "message": "YouTube trending data processed successfully",
            "timestamp": "@utcnow()"
          }
        }
      }
    ],
    "parameters": {
      "input_path": {
        "type": "string",
        "defaultValue": "raw-data/trending.json"
      },
      "output_path": {
        "type": "string", 
        "defaultValue": "curated-data/processed_trending.json"
      }
    },
    "variables": {
      "processing_date": {
        "type": "String"
      }
    },
    "description": "Complete YouTube trending data pipeline: Validate → Transform → Process → Load → Notify"
  }
}




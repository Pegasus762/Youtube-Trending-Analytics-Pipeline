from pyspark.sql import SparkSession
from pyspark.sql.functions import col, explode

spark = SparkSession.builder.appName('TrendingETL').getOrCreate()

spark.conf.set(
  "fs.azure.account.key.yttrendingdata.blob.core.windows.net",
  "BdnuWz/PmaknAhOjrpPgAdEuJE8HzTJczY370JyRhIZo/CRV2Zgst79fwWr1aPwSdFRYNTs/Vvo4+AStOCDqcQ=="
)

# Read the JSON data
df = spark.read.json("wasbs://curated@yttrendingdata.blob.core.windows.net/processed_trending.json")

# First, let's see the schema to understand the structure
print("=== Original Schema ===")
df.printSchema()

# Extract the items array and explode it
df_items = df.select(explode("items").alias("item"))

# Now extract the nested fields
df_processed = df_items.select(
    col("item.id").alias("video_id"),
    col("item.snippet.title").alias("title"),
    col("item.snippet.channelTitle").alias("channelTitle"),
    col("item.snippet.publishedAt").alias("publishedAt"),
    col("item.statistics.viewCount").alias("viewCount"),
    col("item.statistics.likeCount").alias("likeCount"),
    col("item.statistics.commentCount").alias("commentCount")
)

# Show the processed data
print("=== Processed Data ===")
df_processed.show(truncate=False)

# Show the schema of processed data
print("=== Processed Schema ===")
df_processed.printSchema()

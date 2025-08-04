from pyspark.sql import SparkSession
from pyspark.sql.functions import col

spark = SparkSession.builder.appName('TrendingETL').getOrCreate()

# Use the correct DBFS path (without double /dbfs/)
df = spark.read.json("/FileStore/tables/trending_items.json")

# Show schema
print("=== Schema ===")
df.printSchema()

# Select and show relevant fields
df_processed = df.select(
    col("id").alias("video_id"),
    col("snippet.title").alias("title"),
    col("snippet.channelTitle").alias("channelTitle"),
    col("snippet.publishedAt").alias("publishedAt"),
    col("statistics.viewCount").alias("viewCount"),
    col("statistics.likeCount").alias("likeCount"),
    col("statistics.commentCount").alias("commentCount")
)

print("=== Processed Data ===")
df_processed.show(truncate=False)
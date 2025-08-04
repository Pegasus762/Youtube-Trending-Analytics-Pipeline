import json
import glob
import os
import re

# Find the latest trending_*.json file in ingestion/
files = glob.glob("ingestion/trending_*.json")
if not files:
    print("Error: No trending_*.json file found in ingestion/")
    exit(1)

# Pick the most recently modified file
latest_file = max(files, key=os.path.getmtime)

# Extract region code from filename
match = re.search(r'trending_(\w+)\.json$', latest_file)
if not match:
    print(f"Error: Could not extract region code from filename {latest_file}")
    exit(1)
region_code = match.group(1)

input_path = latest_file
output_path = f"ingestion/trending_items_{region_code}.json"

# Read the original YouTube trending data
with open(input_path, "r", encoding="utf-8") as f:
    data = json.load(f)

# Extract the items array
items = data.get("items", [])

# Write each item as a separate line (JSONL format)
with open(output_path, "w", encoding="utf-8") as f:
    for item in items:
        f.write(json.dumps(item) + "\n")

print(f"Extracted {len(items)} items to {output_path}")
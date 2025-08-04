import requests
import json
import os

API_KEY = os.getenv('YOUTUBE_API_KEY')
TRENDING_URL = 'https://www.googleapis.com/youtube/v3/videos'

params = {
    'part': 'snippet,statistics',
    'chart': 'mostPopular',
    'regionCode': 'MY',
    'maxResults': 10,
    'key': API_KEY
}

def fetch_trending():
    response = requests.get(TRENDING_URL, params=params)
    if response.status_code == 200:
        data = response.json()
        output_path = os.path.join('ingestion', f'trending_{params["regionCode"]}.json')
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print('Trending data saved to trending.json')
    else:
        print('Failed to fetch trending data:', response.text)

if __name__ == "__main__":
    fetch_trending() 
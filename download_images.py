# this script downloads the images from assets/periodic_table.json

# This requires aiohttp-3.7.4.post0 requests==2.25.1

import aiohttp
import asyncio
import json
import time
from bs4 import BeautifulSoup

JSON_PATH = "assets/periodic_table.json"
OUTPUT_PATH = "assets/atomic_images"

def get_json_data(path: str):
    with open(JSON_PATH) as file:
        data = json.load(file)

    return data

async def get_image(session, url: str):
    assert(url != None)

    async with session.get(url) as resp:
        html = BeautifulSoup(await resp.read())
        _url = html.find('div', {"id": "file"}).children[0].href

        print(_url)

async def main():
    spectral_image_urls = list(map(lambda x: x.get("spectral_img"), get_json_data(JSON_PATH)))

    async with aiohttp.ClientSession() as session:
        tasks = []

        for url in spectral_image_urls:
            if url:
                tasks.append(asyncio.ensure_future(get_image(session, url)))
    
        images = await asyncio.gather(*tasks)
                


if __name__ == "__main__":
    start_time = time.time()

    asyncio.run(main())

    print("--- %s seconds ---" % (time.time() - start_time))
# this script downloads the images from assets/periodic_table.json

# This requires aiohttp-3.7.4.post0 requests==2.25.1

import aiohttp
import asyncio
import aiofiles
import json
import time
import os
from bs4 import BeautifulSoup

JSON_PATH = "../assets/periodic_table.json"
OUTPUT_PATH = "../assets/atomic_images"

def get_json_data(path: str):
    with open(JSON_PATH) as file:
        data = json.load(file)

    return data

async def get_image(session, url: str, name: str):
    assert(url != None)

    direct_image_url: str

    async with session.get(url) as resp:
        html = BeautifulSoup(await resp.read())
        # print(list(html.find('div', {"id": "file"}).children)[0])
        _url = list(html.find('div', {"id": "file"}).children)[0].get("href")

        direct_image_url = "https:" + _url
    
    async with session.get(direct_image_url) as resp:
        if resp.status == 200:
            f = await aiofiles.open(OUTPUT_PATH + '/{}.jpg'.format(name), mode='wb')
            await f.write(await resp.read())
            await f.close()

async def main():
    os.makedirs(OUTPUT_PATH, exist_ok=True)

    data = get_json_data(JSON_PATH)
    spectral_image_urls = list(map(lambda x: x.get("spectral_img"), get_json_data(JSON_PATH)))

    async with aiohttp.ClientSession() as session:
        tasks = []

        for i, url in enumerate(spectral_image_urls):
            if url:
                tasks.append(asyncio.ensure_future(get_image(session, url, data[i]["name"])))
    
        images = await asyncio.gather(*tasks)
                


if __name__ == "__main__":
    start_time = time.time()

    asyncio.run(main())

    print("--- %s seconds ---" % (time.time() - start_time))
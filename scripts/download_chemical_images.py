# this script downloads the images from assets/periodic_table.json

# This requires aiohttp-3.7.4.post0 requests==2.25.1

import aiohttp
import asyncio
import aiofiles
import re
import time
import os
from pprint import pprint
from bs4 import BeautifulSoup

OUTPUT_PATH = "../assets/atomic_images"

async def extract_url_from_html(session, url: str):
    async with session.get(url) as resp:
        html = BeautifulSoup(await resp.read())
        # print(list(html.find('div', {"id": "file"}).children)[0])
        # id="mntl-sc-block-image_2-0-184"
        # urls = list(html.find_all('img', id=re.compile('.+block-image.+')).children)[0].get("href")
        urls = list(map(lambda x: x.get('data-srcset'), html.find_all('img', id=re.compile('.+block-image.+'))))

    return urls

async def get_image(session, url: str, name: str):
    assert(url != None)

    direct_image_url: str = url

    print(url)
    
    async with session.get(direct_image_url) as resp:
        print(resp)
        if resp.status == 200:
            f = await aiofiles.open(OUTPUT_PATH + '/{}.jpg'.format(name), mode='wb')
            await f.write(await resp.read())
            await f.close()

def extract_title_from_url(url: str):
    matches = re.findall(r'.+(strip_icc\(\))\/(\D+)', url)
    return matches

async def main():
    os.makedirs(OUTPUT_PATH, exist_ok=True)


    # spectral_image_urls = list(map(lambda x: x.get("spectral_img"), get_json_data(JSON_PATH)))

    async with aiohttp.ClientSession() as session:
        urls = await extract_url_from_html(session, "https://www.thoughtco.com/chemical-element-pictures-photo-gallery-4052466")
        # pprint(urls)
        tasks = []

        for i, url in enumerate(urls):
            if url: 
                matches = extract_title_from_url(url)
                title = matches[0][1] if len(matches) > 0 else "unknown" + str(i)
                print(title[:-1])
                tasks.append(asyncio.ensure_future(get_image(session, url[:-5], title[:-1])))
    
        images = await asyncio.gather(*tasks)
                


if __name__ == "__main__":
    start_time = time.time()

    asyncio.run(main())

    print("--- %s seconds ---" % (time.time() - start_time))
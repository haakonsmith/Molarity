# Pubchem has a fabulously complicated API, it breaks my brain, and it seems to be quite inflexible.
# Hence the need for this, this serves the purpose of scraping information from a JS based pubchem site 
# (thus the need for a web driver), and retriving specific information about it. E.g. Taste.

import asyncio
import sys

from arsenic import get_session, keys, browsers, services



async def hello_world():
    service = services.Chromedriver()
    browser = browsers.Chrome(chromeOptions={
        'args': ['--headless', '--disable-gpu']
    })

    async with get_session(service, browser) as session:
        await session.get('https://images.google.com/')
        search_box = await session.wait_for_element(5, 'input[name=q]')
        await search_box.send_keys('Cats')
        await search_box.send_keys(keys.ENTER)



def main():
    loop = asyncio.get_event_loop()
    loop.run_until_complete(hello_world())


if __name__ == '__main__':
    main()
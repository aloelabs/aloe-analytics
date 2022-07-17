#!/usr/bin/env python3

import requests
import time
from tqdm import tqdm

"""
What do I know so far?
- 
"""

# base_url = "http://34.94.17.85"
base_url = "http://localhost:8000"

r = requests.get(base_url + "/deployed_pools/1")

pools = r.json()

print([pools])

for pool in tqdm(pools[3:]):
    url = f'{base_url}/pool_returns/{pool["pool_address"]}/{pool["chain_id"]}/1w/{round(time.time())}'
    print(url)
    r = requests.get(url)
    print(r.json())

print("Done!")

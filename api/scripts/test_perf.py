import requests
import time
from tqdm import tqdm

base_url = "http://34.94.17.85"

r = requests.get(base_url + "/deployed_pools/1")

pools = r.json()

for pool in tqdm(pools):
    url = f'{base_url}/pool_returns/{pool["pool_address"]}/{pool["chain_id"]}/1w/{round(time.time())}'
    print(url)
    r = requests.get(url)
    print(r.json())

print("Done!")

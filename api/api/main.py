from collections import defaultdict
import logging
from typing import Any, Dict, List
from fastapi import FastAPI
import pendulum
import databases
from fastapi.encoders import jsonable_encoder
from pydantic import BaseSettings
from pendulum import duration
from fastapi_cache import FastAPICache
from fastapi_cache.backends.inmemory import InMemoryBackend
from fastapi_cache.decorator import cache
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
    allow_credentials=False,
)


class Settings(BaseSettings):
    database_url: str

    class Config:
        env_file = ".env"


settings = Settings()

db = databases.Database(settings.database_url)

logging.basicConfig()
logging.getLogger("databases").setLevel(logging.DEBUG)


@app.on_event("startup")
async def startup():
    FastAPICache.init(InMemoryBackend(), prefix="fastapi-cache", expire=60)
    await db.connect()


@app.on_event("shutdown")
async def shutdown():
    await db.disconnect()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/deployed_pools/{chain_id}")
@cache()
async def get_deployed_pools(chain_id: int):
    query = "SELECT * FROM dbt.deployed_pools WHERE chain_id = :chain_id"
    values = {"chain_id": chain_id}
    return await db.fetch_all(query=query, values=values)


@app.get("/pool_stats/{pool_address}/{chain_id}")
@cache()
async def get_pool_stats(pool_address: str, chain_id: int):
    query = "SELECT * FROM dbt.pool_stats WHERE pool_address = :pool_address AND chain_id = :chain_id"
    values = {"pool_address": pool_address.lower(), "chain_id": chain_id}
    return await db.fetch_all(query=query, values=values)


@app.get("/global_stats")
@cache()
async def get_global_stats():
    return await db.fetch_all(f"SELECT * FROM dbt.global_stats")


ranges = {
    "1d": (duration(days=1), duration(minutes=5)),
    "1w": (duration(weeks=1), duration(hours=1)),
    "1m": (duration(months=1), duration(hours=12)),
    "3m": (duration(months=3), duration(days=1)),
    "1y": (duration(years=1), duration(days=3)),
    "all": (duration(years=3), duration(days=3)),
}


def _generate_series(range: str, end_time: str) -> List[str]:
    series = []
    offset, interval = ranges[range]
    end_dt = pendulum.from_timestamp(int(end_time))
    current_dt = end_dt - offset
    while current_dt <= end_dt:
        series.append(current_dt.int_timestamp)
        current_dt += interval
    return series


def _generate_subquery_for_range(range: str, end_time: str) -> str:
    timestamps = _generate_series(range, end_time)
    values_list = list(map(lambda t: f"({t} :: int8)", timestamps))
    subquery = (
        f'SELECT * FROM (VALUES {",".join(values_list) }) AS timestamps ("timestamp")'
    )
    return subquery


@app.get("/pool_returns/{pool_address}/{chain_id}/{range}/{end_time}")
@cache()
async def get_pool_returns(pool_address: str, chain_id: int, range: str, end_time: str):
    # subquery = _generate_subquery_for_range(range, end_time)
    offset, interval = ranges[range]
    end_dt = pendulum.from_timestamp(int(end_time))
    start_dt = end_dt - offset
    start_time = start_dt.int_timestamp
    query = (
        "SELECT block_number, inventory0, inventory1, total_supply "
        "FROM dbt.pool_returns "
        f'WHERE pool_address = :pool_address AND chain_id = :chain_id AND "interval" <@ tsrange(to_timestamp({start_time}) :: TIMESTAMP, to_timestamp({end_time}) :: TIMESTAMP)'
        "ORDER BY block_number ASC"
    )
    values = {"pool_address": pool_address.lower(), "chain_id": chain_id}
    return await db.fetch_all(query=query, values=values)


@app.get("/token_returns/{token_address}/{chain_id}/{range}/{end_time}")
@cache()
async def get_token_returns(
    token_address: str, chain_id: int, range: str, end_time: str
):
    subquery = _generate_subquery_for_range(range, end_time)
    query = (
        "SELECT timestamps.timestamp, price FROM "
        "dbt.prices "
        f"JOIN ({subquery}) AS timestamps ON prices.interval @> to_timestamp(timestamps.timestamp) :: TIMESTAMP "
        "WHERE token_address = :token_address AND chain_id = :chain_id "
        "ORDER BY timestamps.timestamp ASC"
    )
    values = {"token_address": token_address.lower(), "chain_id": chain_id}
    return await db.fetch_all(query=query, values=values)


def _partition_by_key(list_of_dicts: List[Dict], key: str) -> Dict[Any, List[Dict]]:
    result = defaultdict(list)
    for dict_ in list_of_dicts:
        k = dict_[key]
        del dict_[key]
        result[k].append(dict_)
    return result


@app.get("/share_balances/{user_address}/{chain_id}/{range}/{end_time}")
@cache()
async def get_share_balances(
    user_address: str, chain_id: int, range: str, end_time: str
):
    subquery = _generate_subquery_for_range(range, end_time)
    query = (
        "SELECT timestamps.timestamp, pool_address, balance FROM "
        "dbt.historical_balances "
        f"JOIN ({subquery}) AS timestamps ON historical_balances.interval @> to_timestamp(timestamps.timestamp) :: TIMESTAMP "
        "WHERE user_address = :user_address "
        "ORDER BY timestamps.timestamp ASC"
    )
    values = {"user_address": user_address.lower()}
    rows = jsonable_encoder(await db.fetch_all(query=query, values=values))
    return _partition_by_key(rows, "pool_address")


@app.get("/net_deposits/{user_address}/{chain_id}/{range}/{end_time}")
@cache()
async def get_net_deposits(user_address: str, chain_id: int, range: str, end_time: str):
    subquery = _generate_subquery_for_range(range, end_time)
    query = (
        "SELECT timestamps.timestamp, pool_address, net_deposit FROM "
        "dbt.net_deposits "
        f"JOIN ({subquery}) AS timestamps ON net_deposits.interval @> to_timestamp(timestamps.timestamp) :: TIMESTAMP "
        "WHERE user_address = :user_address "
        "ORDER BY timestamps.timestamp ASC"
    )
    values = {"user_address": user_address.lower()}
    rows = jsonable_encoder(await db.fetch_all(query=query, values=values))
    return _partition_by_key(rows, "pool_address")

from functools import cache
from itertools import chain, starmap
import json
from typing import List
from venv import create
from fastapi import FastAPI
from fastapi.responses import RedirectResponse, StreamingResponse
import pendulum
import databases
from pendulum import duration, time
from sqlalchemy import create_engine
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

from fastapi_cache import FastAPICache
from fastapi_cache.backends.inmemory import InMemoryBackend
from fastapi_cache.decorator import cache

app = FastAPI()

# https://github.com/tiangolo/fastapi/issues/1788

db = databases.Database(
    "postgresql://mattevenson:password@localhost:5432/aloe_analytics"
)


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


@cache()
@app.get("/deployed_pools/{chain_id}")
async def get_deployed_pools(chain_id: int):
    query = "SELECT * FROM dbt_api.deployed_pools WHERE chain_id = :chain_id"
    values = {"chain_id": chain_id}
    return await db.fetch_all(query=query, values=values)


@cache()
@app.get("/pool_stats/{pool_address}/{chain_id}")
async def get_pool_stats(pool_address: str, chain_id: int):
    query = "SELECT * FROM dbt_api.pool_stats WHERE pool_address = :pool_address AND chain_id = :chain_id"
    values = {"pool_address": pool_address, "chain_id": chain_id}
    return await db.fetch_all(query=query, values=values)


@cache()
@app.get("/global_stats")
async def get_global_stats():
    return await db.fetch_all(f"SELECT * FROM dbt_api.global_stats")


ranges = {
    "1d": (duration(days=1), duration(minutes=5)),
    "1w": (duration(weeks=1), duration(hours=1)),
    "1m": (duration(months=1), duration(hours=12)),
    "3m": (duration(months=3), duration(days=1)),
    "1y": (duration(years=1), duration(days=3)),
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


@cache()
@app.get("/pool_returns/{pool_address}/{chain_id}/{range}/{end_time}")
async def get_pool_returns(pool_address: str, chain_id: int, range: str, end_time: str):
    timestamps = _generate_series(range, end_time)
    subquery = f'SELECT * FROM (VALUES {",".join(list(map(lambda t: f"({t} :: int8)", timestamps))) }) AS timestamps ("timestamp")'

    query = f"SELECT timestamps.timestamp, block_number, block_timestamp, pool_address, chain_id, inventory0, inventory1, total_supply FROM dbt_api.pool_returns JOIN ({ subquery }) AS timestamps ON block_interval @> timestamps.timestamp :: int8 WHERE pool_address = :pool_address AND chain_id = :chain_id  ORDER BY block_number ASC"

    values = {"pool_address": pool_address, "chain_id": chain_id}
    return await db.fetch_all(query=query, values=values)


# @app.get("/token_returns/{token_address}/{chain_id}/{range}/{end_time}")
# async def get_token_returns(
#     token_address: str, chain_id: int, range: str, end_time: str
# ):
#     timestamps = _generate_series(range, end_time)
#     subquery = " OR ".join(
#         [f"interval @> {timestamp} :: int8" for timestamp in timestamps]
#     )
#     records = await db.fetch_all(
#         f"SELECT timestamp, token_address, chain_id, inventory0, inventory1, total_supply FROM dbt_api.pool_returns WHERE pool_address = '{token_address}' AND chain_id = {chain_id} AND ({subquery}) ORDER BY block_number ASC"
#     )

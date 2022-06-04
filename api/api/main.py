import json
from typing import List
from venv import create
from fastapi import FastAPI
from fastapi.responses import RedirectResponse, StreamingResponse
import pendulum
import databases
from pendulum import duration
from sqlalchemy import create_engine
from sqlalchemy.ext.asyncio import create_async_engine

app = FastAPI()

# https://github.com/tiangolo/fastapi/issues/1788

db = databases.Database(
    "postgresql://mattevenson:password@localhost:5432/aloe_analytics"
)


@app.on_event("startup")
async def startup():
    await db.connect()


@app.on_event("shutdown")
async def shutdown():
    await db.disconnect()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/deployed_pools/{chain_id}")
async def get_deployed_pools_by_chain(chain_id: str):
    return await db.fetch_all(
        f"SELECT * FROM dbt_api.deployed_pools WHERE chain_id = {chain_id}"
    )


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


@app.get("/pool_returns/{pool_address}/{chain_id}/{range}/{end_time}")
async def get_pool_returns(pool_address: str, chain_id: str, range: str, end_time: str):
    timestamps = _generate_series(range, end_time)
    subquery = " OR ".join(
        [f"interval @> {timestamp} :: int8" for timestamp in timestamps]
    )
    return await db.fetch_all(
        f"SELECT block_number, timestamp, pool_address, chain_id, inventory0, inventory1, total_supply FROM dbt_api.pool_returns WHERE pool_address = '{pool_address}' AND chain_id = {chain_id} AND ({subquery}) ORDER BY block_number ASC"
    )

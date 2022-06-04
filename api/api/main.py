from fastapi import FastAPI
from fastapi.responses import RedirectResponse, StreamingResponse
import pendulum

app = FastAPI()

# https://github.com/tiangolo/fastapi/issues/1788


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/deployed_pools/{chain_id}")
async def get_deployed_pools_by_chain(chain_id: str):
    return RedirectResponse(
        f"http://localhost:3000/deployed_pools?chain_id=eq.{chain_id}"
    )


@app.get("/pool_returns/{pool_address}/{chain_id}/{range}/{end_time}")
async def get_pool_returns(pool_address: str, chain_id: str, range: str, end_time: str):
    if range == "1d":
        end_time = pendulum.from_timestamp(end_time)
        start_time = end_time

    return RedirectResponse(
        f"http://localhost:3000/pool_returns?pool_address=eq.{pool_address}&chain_id=eq.{chain_id}&limit=100"
    )

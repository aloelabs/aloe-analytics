select
    to_timestamp(cast(mainnet_block.timestamp as bigint)) as timestamp,
    cast(mainnet_block.id as bigint) as block_number
from
    tap_thegraph.mainnet_block
WITH 

aztec_v2_contract_labels as (
        SELECT
            c.*, 
            c.address as contract_address, -- added this so i don't have to update v1 code which uses contract_address in the case when logic 
            c.category as contract_type
        FROM 
        {{ref('labels_aztec_v2_contracts_ethereum')}} c
 ), 
 
 erc_tfers_filtered as (
        SELECT 
            DISTINCT t.*
        FROM 
        {{ source('erc20_ethereum', 'evt_transfer') }} t 
        INNER JOIN 
        aztec_v2_contract_labels at 
            ON t.`from` = at.address
            OR t.`to` = at.address 
        WHERE t.evt_block_time >= '2022-06-06' -- first erc20 tx date 
 ), 
 
 eth_traces_filtered as (
        SELECT 
            DISTINCT t.*
        FROM 
        ethereum.traces t 
        INNER JOIN 
        aztec_v2_contract_labels at 
            ON t.`from` = at.address
            OR t.`to` = at.address 
        WHERE t.block_time >= '2022-06-06' -- first eth tx date
 ), 
 
 tfers_raw as (
    SELECT 
    `from` as tx_from, 
    `to` as tx_to,
    value, 
    contract_address, 
    evt_tx_hash,
    evt_index,
    evt_block_time,
    evt_block_number
    FROM erc_tfers_filtered 
    UNION all 
  -- Track the ETH that's transferred
    SELECT 
      `from` as tx_from
      , `to` as tx_to 
      , value
      , '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' as contract_address
      , tx_hash as evt_tx_hash
      , null::bigint as evt_index
      , block_time as evt_block_time
      , block_number as evt_block_number
  FROM eth_traces_filtered
  WHERE true
  AND value <> 0
  AND (LOWER(call_type) NOT IN ('delegatecall', 'callcode', 'staticcall') or call_type is null)
    AND CASE WHEN block_number < 4370000  THEN True
            WHEN block_number >= 4370000 THEN tx_success
            END 
    AND success = true
),

tfers_categorized as (
  select t.*
    , tk.symbol
    , tk.decimals
    , t.value / POW(10, coalesce(tk.decimals,18)) as value_norm
    , case when to_contract.contract_type is not null and from_contract.contract_type is not null then 'Internal'
      else 'External'        
        end as broad_txn_type
    , case 
        when from_contract.contract_type is null and to_contract.contract_type = 'Rollup' then 'User Deposit'
        when to_contract.contract_type is null and from_contract.contract_type = 'Rollup' then 'User Withdrawal'
        when from_contract.contract_type = 'Rollup' and to_contract.contract_type = 'Bridge' then 'RP to Bridge'
        when to_contract.contract_type = 'Rollup' and from_contract.contract_type = 'Bridge' then 'Bridge to RP'
        when from_contract.contract_type = 'Bridge' and to_contract.contract_type is null then 'Bridge to Protocol'
        when to_contract.contract_type = 'Bridge' and from_contract.contract_type is null then 'Protocol to Bridge'
        end as spec_txn_type
    , to_contract.protocol as to_protocol
    , to_contract.contract_type as to_type
    , from_contract.protocol as from_protocol
    , from_contract.contract_type as from_type
    , case when to_contract.contract_type = 'Bridge' then to_contract.contract_address
      when from_contract.contract_type = 'Bridge' then from_contract.contract_address
      else null end
      as bridge_address
    , case when to_contract.contract_type = 'Bridge' then to_contract.protocol
      when from_contract.contract_type = 'Bridge' then from_contract.protocol
      else null end
      as bridge_protocol
    , case when to_contract.contract_type = 'Bridge' then to_contract.version
      when from_contract.contract_type = 'Bridge' then from_contract.version
      else null end
      as bridge_version
  from tfers_raw t
  LEFT JOIN {{ref('tokens_ethereum_erc20')}} tk on t.contract_address = tk.contract_address
  LEFT JOIN aztec_v2_contract_labels to_contract on t.tx_to = to_contract.contract_address
  LEFT JOIN aztec_v2_contract_labels from_contract on t.tx_from = from_contract.contract_address
)

SELECT * FROM tfers_raw

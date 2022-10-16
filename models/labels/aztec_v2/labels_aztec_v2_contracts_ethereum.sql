{{config(alias='aztec_v2_contracts_ethereum',
        post_hook='{{ expose_spells(\'["ethereum"]\',
                                    "project",
                                    "labels",
                                    \'["henrystats, jackiep00"]\') }}')}}


with
  contract_labels as (
    SELECT
      array('ethereum') as blockchain,
      contract_address as address,
      description as name,
      contract_type as category,
      'jackiep00' as contributor,
      'wizard' as source,
      date('2022-09-19') as created_at,
      now() as updated_at,
      version,
      protocol,
      contract_creator 
    from
      (
        SELECT
          protocol,
          contract_type,
          version,
          description,
          lower(contract_address) as contract_address, 
          lower(contract_creator) as contract_creator
        FROM
          (
            VALUES
              (
                'Aztec RollupProcessor',
                'Rollup',
                '1.0',
                'Prod Aztec Rollup',
                '0xFF1F2B4ADb9dF6FC8eAFecDcbF96A2B351680455',
                '0x61acf20ae64bdd2c54bcd622ed3dfbae8a82517f'
              ),
              (
                'Element',
                'Bridge',
                '1.0',
                'Prod Element Bridge',
                '0xaeD181779A8AAbD8Ce996949853FEA442C2CDB47',
                '0xa173bddf4953c1e8be2ca0695cfc07502ff3b1e7'
              ),
              (
                'Lido',
                'Bridge',
                '1.0',
                'Prod Lido Bridge',
                '0x381abF150B53cc699f0dBBBEF3C5c0D1fA4B3Efd',
                '0xa173bddf4953c1e8be2ca0695cfc07502ff3b1e7'
              ),
              (
                'AceOfZK',
                'Bridge',
                '1.0',
                'Ace Of ZK NFT - nonfunctional',
                '0x0eb7f9464060289fe4fddfde2258f518c6347a70',
                '0xa173bddf4953c1e8be2ca0695cfc07502ff3b1e7'
              ),
              (
                'Curve',
                'Bridge',
                '1.0',
                'CurveStEth Bridge',
                '0x0031130c56162e00a7e9c01ee4147b11cbac8776',
                '0xa173bddf4953c1e8be2ca0695cfc07502ff3b1e7'
              ),
              (
                'Aztec',
                'Bridge',
                '1.0',
                'Subsidy Manager',
                '0xABc30E831B5Cc173A9Ed5941714A7845c909e7fA',
                '0x36bb84d28bb2d9772158cc9a09feaa5472ebfd32'
              ),
              (
                'Yearn',
                'Bridge',
                '1.0',
                'Yearn Deposits',
                '0xE71A50a78CcCff7e20D8349EED295F12f0C8C9eF',
                '0x36bb84d28bb2d9772158cc9a09feaa5472ebfd32'
              ),
              (
                'Aztec',
                'Bridge',
                '1.0',
                'ERC4626 Tokenized Vault',
                '0x3578D6D5e1B4F07A48bb1c958CBfEc135bef7d98',
                '0x36bb84d28bb2d9772158cc9a09feaa5472ebfd32'
              ),
              (
                'Curve',
                'Bridge',
                '1.0',
                'CurveStEth Bridge V2',
                '0xe09801dA4C74e62fB42DFC8303a1C1BD68073D1a',
                '0xe96600ccb1a0f0c37a85ec0e8451c259a80cfbb6'
              ),
              (
                'Uniswap',
                'Bridge',
                '1.0',
                'UniswapDCABridge',
                '0x94679A39679ffE53B53b6a1187aa1c649A101321',
                '0x36bb84d28bb2d9772158cc9a09feaa5472ebfd32'
              )
          ) AS x (
            protocol,
            contract_type,
            version,
            description,
            contract_address,
            contract_creator
          )
      )
  )
select
  c.*
from
  contract_labels c
;
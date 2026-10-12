open! Core
open Bybit_protocol

let%expect_test "position list" =
  Helpers.round_trip_envelope
    (module Position.Response)
    {|{
  "retCode": 0,
  "retMsg": "OK",
  "result": {
    "list": [
      {
        "positionIdx": 0,
        "riskId": 1,
        "riskLimitValue": "150",
        "symbol": "BTCUSD",
        "side": "Sell",
        "size": "300",
        "avgPrice": "27464.50441675",
        "positionValue": "0.01092319",
        "tradeMode": 0,
        "positionStatus": "Normal",
        "leverage": "10",
        "markPrice": "28224.50",
        "liqPrice": "",
        "positionIM": "0.00010923",
        "positionMM": "0.0000015",
        "unrealisedPnl": "-0.00029413",
        "curRealisedPnl": "0.00013123",
        "cumRealisedPnl": "-0.00096902",
        "createdTime": "1676538056258",
        "updatedTime": "1697673600012"
      }
    ],
    "nextPageCursor": "",
    "category": "inverse"
  },
  "retExtInfo": {},
  "time": 1697684980172
}|};
  [%expect
    {|
    ((ret_code 0) (ret_msg OK)
     (result
      ((category Inverse)
       (list
        (((position_idx One_way) (symbol BTCUSD) (side (Sell)) (size 300)
          (avg_price 27464.50441675) (position_value (0.01092319))
          (unrealised_pnl -0.00029413) (cum_realised_pnl -0.00096902)
          (cur_realised_pnl (0.00013123)) (leverage (10)) (liq_price ())
          (mark_price 28224.5) (position_status (Normal))
          (created_time 1676538056258) (updated_time 1697673600012) (category ())
          (seq ()))))
       (next_page_cursor (""))))
     (ret_ext_info {}) (time 1697684980172))
    {"retCode":0,"retMsg":"OK","result":{"category":"inverse","list":[{"positionIdx":0,"symbol":"BTCUSD","side":"Sell","size":"300","avgPrice":"27464.50441675","positionValue":"0.01092319","unrealisedPnl":"-0.00029413","cumRealisedPnl":"-0.00096902","curRealisedPnl":"0.00013123","leverage":"10","liqPrice":"","markPrice":"28224.5","positionStatus":"Normal","createdTime":"1676538056258","updatedTime":"1697673600012"}],"nextPageCursor":""},"retExtInfo":{},"time":1697684980172}
    |}]
;;

let%expect_test "wallet balance" =
  Helpers.round_trip_envelope
    (module Wallet_balance)
    {|{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "list": [
            {
                "totalEquity": "3.31216591",
                "accountIMRate": "0",
                "accountIMRateByMp": "0",
                "totalMarginBalance": "3.00326056",
                "totalInitialMargin": "0",
                "totalInitialMarginByMp": "0",
                "accountType": "UNIFIED",
                "totalAvailableBalance": "3.00326056",
                "accountMMRate": "0",
                "accountMMRateByMp": "0",
                "totalPerpUPL": "0",
                "totalWalletBalance": "3.00326056",
                "accountLTV": "0",
                "totalMaintenanceMargin": "0",
                "totalMaintenanceMarginByMp": "0",
                "coin": [
                    {
                        "availableToBorrow": "3",
                        "bonus": "0",
                        "accruedInterest": "0",
                        "availableToWithdraw": "0",
                        "totalOrderIM": "0",
                        "equity": "0",
                        "totalPositionMM": "0",
                        "usdValue": "0",
                        "spotHedgingQty": "0.01592413",
                        "unrealisedPnl": "0",
                        "collateralSwitch": true,
                        "borrowAmount": "0.0",
                        "totalPositionIM": "0",
                        "walletBalance": "0",
                        "cumRealisedPnl": "0",
                        "locked": "0",
                        "marginCollateral": true,
                        "coin": "BTC",
                        "spotBorrow": "0"
                    }
                ]
            }
        ]
    },
    "retExtInfo": {},
    "time": 1690872862481
}|};
  [%expect
    {|
    ((ret_code 0) (ret_msg OK)
     (result
      ((list
        (((account_type UNIFIED) (total_equity 3.31216591)
          (total_wallet_balance 3.00326056) (total_margin_balance 3.00326056)
          (total_available_balance 3.00326056) (total_perp_upl (0))
          (total_initial_margin (0)) (total_maintenance_margin (0))
          (coin
           (((coin BTC) (wallet_balance 0) (equity 0) (unrealised_pnl (0))
             (cum_realised_pnl (0)) (usd_value (0)) (locked (0))))))))))
     (ret_ext_info {}) (time 1690872862481))
    {"retCode":0,"retMsg":"OK","result":{"list":[{"accountType":"UNIFIED","totalEquity":"3.31216591","totalWalletBalance":"3.00326056","totalMarginBalance":"3.00326056","totalAvailableBalance":"3.00326056","totalPerpUPL":"0","totalInitialMargin":"0","totalMaintenanceMargin":"0","coin":[{"coin":"BTC","walletBalance":"0","equity":"0","unrealisedPnl":"0","cumRealisedPnl":"0","usdValue":"0","locked":"0"}]}]},"retExtInfo":{},"time":1690872862481}
    |}]
;;

open! Core
open Bybit_protocol

let msg = Helpers.round_trip (module Ws_message)

let%expect_test "requests" =
  let req = Helpers.round_trip (module Ws_request) in
  req
    {|{ "req_id": "test", "op": "subscribe", "args": ["orderbook.1.BTCUSDT", "publicTrade.BTCUSDT", "orderbook.1.ETHUSDT"] }|};
  req {|{"op":"subscribe","args":["tickers.BTCUSDT"]}|};
  req {|{"op":"subscribe","args":["order"]}|};
  req {|{ "req_id": "100001", "op": "ping" }|};
  req
    {|{
    "req_id": "10001",
    "op": "auth",
    "args": [
        "api_key",
        1662350400000,
        "signature"
    ]
}|};
  [%expect
    {|
    (Subscribe (req_id (test))
     (args
      ((Orderbook (depth 1) (symbol BTCUSDT)) (Public_trade BTCUSDT)
       (Orderbook (depth 1) (symbol ETHUSDT)))))
    {"req_id":"test","op":"subscribe","args":["orderbook.1.BTCUSDT","publicTrade.BTCUSDT","orderbook.1.ETHUSDT"]}
    (Subscribe (req_id ()) (args ((Tickers BTCUSDT))))
    {"op":"subscribe","args":["tickers.BTCUSDT"]}
    (Subscribe (req_id ()) (args ((Order ()))))
    {"op":"subscribe","args":["order"]}
    (Ping (req_id (100001)))
    {"req_id":"100001","op":"ping"}
    (Auth (req_id (10001)) (api_key api_key) (expires 1662350400000)
     (signature signature))
    {"req_id":"10001","op":"auth","args":["api_key",1662350400000,"signature"]}
    |}]
;;

let%expect_test "signed auth request" =
  Ws_request.auth ~api_key:"XXXXXXXXXX" ~secret:"test-secret" ~expires:1662350400000 ()
  |> Ws_request.yojson_of_t
  |> Yojson.Safe.to_string
  |> print_endline;
  [%expect
    {| {"op":"auth","args":["XXXXXXXXXX",1662350400000,"f072aab6fa18cd774da998325df6cfc87c3ccf10d5722e6b43b570c5feaf6172"]} |}]
;;

let%expect_test "acks and pongs" =
  msg
    {|{"success": true, "ret_msg": "", "op": "subscribe", "conn_id": "cejreassvfrsfvb9v1a0-2m"}|};
  msg
    {|{"success": true, "ret_msg": "subscribe", "conn_id": "2324d924-aa4d-45b0-a858-7b8be29ab52b", "req_id": "10001", "op": "subscribe"}|};
  msg
    {|{"success": true, "ret_msg": "pong", "conn_id": "465772b1-7630-4fdc-a492-e003e6f0f260", "req_id": "", "op": "ping"}|};
  msg
    {|{"req_id": "test", "op": "pong", "args": ["1675418560633"], "conn_id": "cfcb4ocsvfriu23r3er0-1b"}|};
  msg
    {|{"success": true, "ret_msg": "pong", "conn_id": "0970e817-426e-429a-a679-ff7f55e0b16a", "op": "ping"}|};
  (* UNVERIFIED: auth ack and failure shapes. *)
  msg
    {|{"success": true, "ret_msg": "", "op": "auth", "conn_id": "cejreassvfrsfvb9v1a0-2m"}|};
  msg
    {|{"success": false, "ret_msg": "Invalid topic", "op": "subscribe", "conn_id": "x"}|};
  [%expect
    {|
    (Subscribe_ack
     ((success (true)) (ret_msg ("")) (conn_id (cejreassvfrsfvb9v1a0-2m))
      (req_id ()) (op subscribe) (args ())))
    {"success":true,"ret_msg":"","conn_id":"cejreassvfrsfvb9v1a0-2m","op":"subscribe"}
    (Subscribe_ack
     ((success (true)) (ret_msg (subscribe))
      (conn_id (2324d924-aa4d-45b0-a858-7b8be29ab52b)) (req_id (10001))
      (op subscribe) (args ())))
    {"success":true,"ret_msg":"subscribe","conn_id":"2324d924-aa4d-45b0-a858-7b8be29ab52b","req_id":"10001","op":"subscribe"}
    (Pong
     ((success (true)) (ret_msg (pong))
      (conn_id (465772b1-7630-4fdc-a492-e003e6f0f260)) (req_id ("")) (op ping)
      (args ())))
    {"success":true,"ret_msg":"pong","conn_id":"465772b1-7630-4fdc-a492-e003e6f0f260","req_id":"","op":"ping"}
    (Pong
     ((success ()) (ret_msg ()) (conn_id (cfcb4ocsvfriu23r3er0-1b))
      (req_id (test)) (op pong) (args ((1675418560633)))))
    {"conn_id":"cfcb4ocsvfriu23r3er0-1b","req_id":"test","op":"pong","args":["1675418560633"]}
    (Pong
     ((success (true)) (ret_msg (pong))
      (conn_id (0970e817-426e-429a-a679-ff7f55e0b16a)) (req_id ()) (op ping)
      (args ())))
    {"success":true,"ret_msg":"pong","conn_id":"0970e817-426e-429a-a679-ff7f55e0b16a","op":"ping"}
    (Auth_ack
     ((success (true)) (ret_msg ("")) (conn_id (cejreassvfrsfvb9v1a0-2m))
      (req_id ()) (op auth) (args ())))
    {"success":true,"ret_msg":"","conn_id":"cejreassvfrsfvb9v1a0-2m","op":"auth"}
    (Subscribe_ack
     ((success (false)) (ret_msg ("Invalid topic")) (conn_id (x)) (req_id ())
      (op subscribe) (args ())))
    {"success":false,"ret_msg":"Invalid topic","conn_id":"x","op":"subscribe"}
    |}]
;;

let%expect_test "orderbook snapshot and delta" =
  msg
    {|{
  "topic": "orderbook.50.BTCUSDT",
  "type": "snapshot",
  "ts": 1672304484978,
  "data": {
    "s": "BTCUSDT",
    "b": [ ["16493.50", "0.006"], ["16493.00", "0.100"] ],
    "a": [ ["16611.00", "0.029"], ["16612.00", "0.213"] ],
    "u": 18521288,
    "seq": 7961638724
  },
  "cts": 1672304484976
}|};
  msg
    {|{
  "topic": "orderbook.50.BTCUSDT",
  "type": "delta",
  "ts": 1687940967466,
  "data": {
    "s": "BTCUSDT",
    "b": [
      ["30247.20", "30.028"],
      ["30245.40", "0.224"],
      ["30242.10", "1.593"],
      ["30240.30", "1.305"],
      ["30240.00", "0"]
    ],
    "a": [
      ["30248.70", "0"],
      ["30249.30", "0.892"],
      ["30249.50", "1.778"],
      ["30249.60", "0"],
      ["30251.90", "2.947"],
      ["30252.20", "0.659"],
      ["30252.50", "4.591"]
    ],
    "u": 177400507,
    "seq": 66544703342
  },
  "cts": 1687940967464
}|};
  [%expect
    {|
    (Orderbook
     ((topic (Orderbook (depth 50) (symbol BTCUSDT))) (type_ Snapshot)
      (ts 1672304484978)
      (data
       ((s BTCUSDT)
        (b (((price 16493.5) (size 0.006)) ((price 16493) (size 0.1))))
        (a (((price 16611) (size 0.029)) ((price 16612) (size 0.213))))
        (u 18521288) (seq 7961638724)))
      (cts (1672304484976))))
    {"topic":"orderbook.50.BTCUSDT","type":"snapshot","ts":1672304484978,"data":{"s":"BTCUSDT","b":[["16493.5","0.006"],["16493","0.1"]],"a":[["16611","0.029"],["16612","0.213"]],"u":18521288,"seq":7961638724},"cts":1672304484976}
    (Orderbook
     ((topic (Orderbook (depth 50) (symbol BTCUSDT))) (type_ Delta)
      (ts 1687940967466)
      (data
       ((s BTCUSDT)
        (b
         (((price 30247.2) (size 30.028)) ((price 30245.4) (size 0.224))
          ((price 30242.1) (size 1.593)) ((price 30240.3) (size 1.305))
          ((price 30240) (size 0))))
        (a
         (((price 30248.7) (size 0)) ((price 30249.3) (size 0.892))
          ((price 30249.5) (size 1.778)) ((price 30249.6) (size 0))
          ((price 30251.9) (size 2.947)) ((price 30252.2) (size 0.659))
          ((price 30252.5) (size 4.591))))
        (u 177400507) (seq 66544703342)))
      (cts (1687940967464))))
    {"topic":"orderbook.50.BTCUSDT","type":"delta","ts":1687940967466,"data":{"s":"BTCUSDT","b":[["30247.2","30.028"],["30245.4","0.224"],["30242.1","1.593"],["30240.3","1.305"],["30240","0"]],"a":[["30248.7","0"],["30249.3","0.892"],["30249.5","1.778"],["30249.6","0"],["30251.9","2.947"],["30252.2","0.659"],["30252.5","4.591"]],"u":177400507,"seq":66544703342},"cts":1687940967464}
    |}]
;;

let%expect_test "public trade" =
  msg
    {|{
    "topic": "publicTrade.BTCUSDT",
    "type": "snapshot",
    "ts": 1672304486868,
    "data": [
        {
            "T": 1672304486865,
            "s": "BTCUSDT",
            "S": "Buy",
            "v": "0.001",
            "p": "16578.50",
            "L": "PlusTick",
            "i": "20f43950-d8dd-5b31-9112-a178eb6023af",
            "BT": false,
            "seq": 1783284617
        }
    ]
}|};
  [%expect
    {|
    (Public_trade
     ((topic (Public_trade BTCUSDT)) (type_ Snapshot) (ts 1672304486868)
      (data
       (((time 1672304486865) (symbol BTCUSDT) (side Buy) (size 0.001)
         (price 16578.5) (tick_direction (PlusTick))
         (trade_id 20f43950-d8dd-5b31-9112-a178eb6023af) (block_trade false)
         (rpi ()) (seq (1783284617)))))))
    {"topic":"publicTrade.BTCUSDT","type":"snapshot","ts":1672304486868,"data":[{"T":1672304486865,"s":"BTCUSDT","S":"Buy","v":"0.001","p":"16578.5","L":"PlusTick","i":"20f43950-d8dd-5b31-9112-a178eb6023af","BT":false,"seq":1783284617}]}
    |}]
;;

let ticker_snapshot =
  {|{
  "topic": "tickers.BTCUSDT",
  "type": "snapshot",
  "data": {
    "symbol": "BTCUSDT",
    "tickDirection": "MinusTick",
    "price24hPcnt": "-0.158315",
    "lastPrice": "66666.60",
    "prevPrice24h": "79206.20",
    "highPrice24h": "79266.30",
    "lowPrice24h": "65076.90",
    "prevPrice1h": "66666.60",
    "markPrice": "66666.60",
    "indexPrice": "115418.19",
    "openInterest": "492373.72",
    "openInterestValue": "32824881841.75",
    "turnover24h": "4936790807.6521",
    "volume24h": "73191.3870",
    "fundingIntervalHour": "8",
    "fundingCap": "0.005",
    "nextFundingTime": "1760342400000",
    "fundingRate": "-0.005",
    "bid1Price": "66666.60",
    "bid1Size": "23789.165",
    "ask1Price": "66666.70",
    "ask1Size": "23775.469",
    "preOpenPrice": "",
    "preQty": "",
    "curPreListingPhase": ""
  },
  "cs": 9532239429,
  "ts": 1760325052630
}|}
;;

(* UNVERIFIED: no delta example in the docs; this one is made up from the merge rule. *)
let ticker_delta =
  {|{"topic": "tickers.BTCUSDT", "type": "delta",
     "data": {"symbol": "BTCUSDT", "bid1Price": "66666.50", "bid1Size": "1.5"},
     "cs": 9532239430, "ts": 1760325052730}|}
;;

let%expect_test "tickers snapshot, delta and merge" =
  msg ticker_snapshot;
  msg ticker_delta;
  let data s = (Ws_ticker.t_of_yojson (Yojson.Safe.from_string s)).data in
  print_s
    [%sexp
      (Ws_ticker.Data.apply (data ticker_snapshot) ~delta:(data ticker_delta)
       : Ws_ticker.Data.t)];
  [%expect
    {|
    (Ticker
     ((topic (Tickers BTCUSDT)) (type_ Snapshot)
      (data
       ((symbol BTCUSDT) (last_price (66666.6)) (mark_price (66666.6))
        (index_price (115418.19)) (bid1_price (66666.6)) (bid1_size (23789.165))
        (ask1_price (66666.7)) (ask1_size (23775.469)) (funding_rate (-0.005))
        (next_funding_time (1760342400000)) (open_interest (492373.72))
        (volume24h (73191.387)) (turnover24h (4936790807.6521))
        (price24h_pcnt (-0.158315))))
      (cs (9532239429)) (ts 1760325052630)))
    {"topic":"tickers.BTCUSDT","type":"snapshot","data":{"symbol":"BTCUSDT","lastPrice":"66666.6","markPrice":"66666.6","indexPrice":"115418.19","bid1Price":"66666.6","bid1Size":"23789.165","ask1Price":"66666.7","ask1Size":"23775.469","fundingRate":"-0.005","nextFundingTime":"1760342400000","openInterest":"492373.72","volume24h":"73191.387","turnover24h":"4936790807.6521","price24hPcnt":"-0.158315"},"cs":9532239429,"ts":1760325052630}
    (Ticker
     ((topic (Tickers BTCUSDT)) (type_ Delta)
      (data
       ((symbol BTCUSDT) (last_price ()) (mark_price ()) (index_price ())
        (bid1_price (66666.5)) (bid1_size (1.5)) (ask1_price ()) (ask1_size ())
        (funding_rate ()) (next_funding_time ()) (open_interest ())
        (volume24h ()) (turnover24h ()) (price24h_pcnt ())))
      (cs (9532239430)) (ts 1760325052730)))
    {"topic":"tickers.BTCUSDT","type":"delta","data":{"symbol":"BTCUSDT","bid1Price":"66666.5","bid1Size":"1.5"},"cs":9532239430,"ts":1760325052730}
    ((symbol BTCUSDT) (last_price (66666.6)) (mark_price (66666.6))
     (index_price (115418.19)) (bid1_price (66666.5)) (bid1_size (1.5))
     (ask1_price (66666.7)) (ask1_size (23775.469)) (funding_rate (-0.005))
     (next_funding_time (1760342400000)) (open_interest (492373.72))
     (volume24h (73191.387)) (turnover24h (4936790807.6521))
     (price24h_pcnt (-0.158315)))
    |}]
;;

let%expect_test "private order" =
  msg
    {|{
    "id": "5923240c6880ab-c59f-420b-9adb-3639adc9dd90",
    "topic": "order",
    "creationTime": 1672364262474,
    "data": [
        {
            "symbol": "ETH-30DEC22-1400-C",
            "orderId": "5cf98598-39a7-459e-97bf-76ca765ee020",
            "side": "Sell",
            "orderType": "Market",
            "cancelType": "UNKNOWN",
            "price": "72.5",
            "qty": "1",
            "orderIv": "",
            "timeInForce": "IOC",
            "orderStatus": "Filled",
            "orderLinkId": "",
            "lastPriceOnCreated": "",
            "reduceOnly": false,
            "leavesQty": "",
            "leavesValue": "",
            "cumExecQty": "1",
            "cumExecValue": "75",
            "avgPrice": "75",
            "blockTradeId": "",
            "positionIdx": 0,
            "cumExecFee": "0.358635",
            "closedPnl": "0",
            "createdTime": "1672364262444",
            "updatedTime": "1672364262457",
            "rejectReason": "EC_NoError",
            "stopOrderType": "",
            "tpslMode": "",
            "triggerPrice": "",
            "takeProfit": "",
            "stopLoss": "",
            "tpTriggerBy": "",
            "slTriggerBy": "",
            "tpLimitPrice": "",
            "slLimitPrice": "",
            "triggerDirection": 0,
            "triggerBy": "",
            "closeOnTrigger": false,
            "category": "option",
            "placeType": "price",
            "smpType": "None",
            "smpGroup": "0",
            "smpOrderId": "",
            "feeCurrency": "",
            "cumFeeDetail": { "MNT": "0.00242968" },
            "rpiTakerAccess": false,
            "rpiMatchedQty": "0"
        }
    ]
}|};
  [%expect
    {|
    (Order
     ((id 5923240c6880ab-c59f-420b-9adb-3639adc9dd90) (topic (Order ()))
      (creation_time 1672364262474)
      (data
       (((order_id 5cf98598-39a7-459e-97bf-76ca765ee020) (order_link_id ())
         (symbol ETH-30DEC22-1400-C) (side Sell) (order_type Market) (price 72.5)
         (qty 1) (time_in_force Ioc) (order_status Filled) (cum_exec_qty 1)
         (cum_exec_value 75) (avg_price (75)) (leaves_qty ()) (reduce_only false)
         (reject_reason No_error) (position_idx One_way)
         (created_time 1672364262444) (updated_time 1672364262457)
         (category (Option)) (closed_pnl (0)))))))
    {"id":"5923240c6880ab-c59f-420b-9adb-3639adc9dd90","topic":"order","creationTime":1672364262474,"data":[{"orderId":"5cf98598-39a7-459e-97bf-76ca765ee020","orderLinkId":"","symbol":"ETH-30DEC22-1400-C","side":"Sell","orderType":"Market","price":"72.5","qty":"1","timeInForce":"IOC","orderStatus":"Filled","cumExecQty":"1","cumExecValue":"75","avgPrice":"75","leavesQty":"","reduceOnly":false,"rejectReason":"EC_NoError","positionIdx":0,"createdTime":"1672364262444","updatedTime":"1672364262457","category":"option","closedPnl":"0"}]}
    |}]
;;

let%expect_test "private execution" =
  msg
    {|{
    "topic": "execution",
    "id": "386825804_BTCUSDT_140612148849382",
    "creationTime": 1746270400355,
    "data": [
        {
            "category": "linear",
            "symbol": "BTCUSDT",
            "closedSize": "0.5",
            "execFee": "26.3725275",
            "execId": "0ab1bdf7-4219-438b-b30a-32ec863018f7",
            "execPrice": "95900.1",
            "execQty": "0.5",
            "execType": "Trade",
            "execValue": "47950.05",
            "feeRate": "0.00055",
            "tradeIv": "",
            "markIv": "",
            "blockTradeId": "",
            "markPrice": "95901.48",
            "indexPrice": "",
            "underlyingPrice": "",
            "leavesQty": "0",
            "orderId": "9aac161b-8ed6-450d-9cab-c5cc67c21784",
            "orderLinkId": "",
            "orderPrice": "94942.5",
            "orderQty": "0.5",
            "orderType": "Market",
            "stopOrderType": "UNKNOWN",
            "side": "Sell",
            "execTime": "1746270400353",
            "isLeverage": "0",
            "isMaker": false,
            "seq": 140612148849382,
            "marketUnit": "",
            "execPnl": "0.05",
            "createType": "CreateByUser",
            "extraFees": [ { "feeCoin": "USDT", "feeType": "GST", "subFeeType": "IND_GST", "feeRate": "0.0000675", "fee": "0.006403779" } ],
            "feeCurrency": "USDT"
        }
    ]
}|};
  [%expect
    {|
    (Execution
     ((id 386825804_BTCUSDT_140612148849382) (topic (Execution ()))
      (creation_time 1746270400355)
      (data
       (((exec_id 0ab1bdf7-4219-438b-b30a-32ec863018f7)
         (order_id 9aac161b-8ed6-450d-9cab-c5cc67c21784) (order_link_id ())
         (symbol BTCUSDT) (side Sell) (exec_price 95900.1) (exec_qty 0.5)
         (exec_value 47950.05) (exec_fee 26.3725275) (fee_rate (0.00055))
         (exec_type Trade) (is_maker false) (exec_time 1746270400353)
         (closed_size (0.5)) (seq (140612148849382)) (category (Linear)))))))
    {"id":"386825804_BTCUSDT_140612148849382","topic":"execution","creationTime":1746270400355,"data":[{"execId":"0ab1bdf7-4219-438b-b30a-32ec863018f7","orderId":"9aac161b-8ed6-450d-9cab-c5cc67c21784","orderLinkId":"","symbol":"BTCUSDT","side":"Sell","execPrice":"95900.1","execQty":"0.5","execValue":"47950.05","execFee":"26.3725275","feeRate":"0.00055","execType":"Trade","isMaker":false,"execTime":"1746270400353","closedSize":"0.5","seq":140612148849382,"category":"linear"}]}
    |}]
;;

let%expect_test "private position uses entryPrice" =
  msg
    {|{
    "id": "1003076014fb7eedb-c7e6-45d6-a8c1-270f0169171a",
    "topic": "position",
    "creationTime": 1697682317044,
    "data": [
        {
            "positionIdx": 2,
            "tradeMode": 0,
            "riskId": 1,
            "riskLimitValue": "2000000",
            "symbol": "BTCUSDT",
            "side": "",
            "size": "0",
            "entryPrice": "0",
            "leverage": "10",
            "breakEvenPrice": "93556.73034991",
            "positionValue": "0",
            "positionBalance": "0",
            "markPrice": "28184.5",
            "positionIM": "0",
            "positionIMByMp": "0",
            "positionMM": "0",
            "positionMMByMp": "0",
            "takeProfit": "0",
            "stopLoss": "0",
            "trailingStop": "0",
            "unrealisedPnl": "0",
            "curRealisedPnl": "1.26",
            "cumRealisedPnl": "-25.06579337",
            "sessionAvgPrice": "0",
            "createdTime": "1694402496913",
            "updatedTime": "1697682317038",
            "tpslMode": "Full",
            "liqPrice": "0",
            "bustPrice": "",
            "category": "linear",
            "positionStatus": "Normal",
            "adlRankIndicator": 0,
            "autoAddMargin": 0,
            "leverageSysUpdatedTime": "",
            "mmrSysUpdatedTime": "",
            "seq": 8327597863,
            "isReduceOnly": false
        }
    ]
}|};
  [%expect
    {|
    (Position
     ((id 1003076014fb7eedb-c7e6-45d6-a8c1-270f0169171a) (topic (Position ()))
      (creation_time 1697682317044)
      (data
       (((position_idx Hedge_sell) (symbol BTCUSDT) (side ()) (size 0)
         (avg_price 0) (position_value (0)) (unrealised_pnl 0)
         (cum_realised_pnl -25.06579337) (cur_realised_pnl (1.26))
         (leverage (10)) (liq_price (0)) (mark_price 28184.5)
         (position_status (Normal)) (created_time 1694402496913)
         (updated_time 1697682317038) (category (Linear)) (seq (8327597863)))))))
    {"id":"1003076014fb7eedb-c7e6-45d6-a8c1-270f0169171a","topic":"position","creationTime":1697682317044,"data":[{"positionIdx":2,"symbol":"BTCUSDT","side":"","size":"0","entryPrice":"0","positionValue":"0","unrealisedPnl":"0","cumRealisedPnl":"-25.06579337","curRealisedPnl":"1.26","leverage":"10","liqPrice":"0","markPrice":"28184.5","positionStatus":"Normal","createdTime":"1694402496913","updatedTime":"1697682317038","category":"linear","seq":8327597863}]}
    |}]
;;

let%expect_test "private wallet" =
  msg
    {|{
  "id": "592324d2bce751-ad38-48eb-8f42-4671d1fb4d4e",
  "topic": "wallet",
  "creationTime": 1700034722104,
  "data": [
    {
      "accountType": "UNIFIED",
      "totalEquity": "10262.91335023",
      "totalWalletBalance": "9684.46297164",
      "totalMarginBalance": "9684.46297164",
      "totalAvailableBalance": "9556.6056555",
      "coin": [
        {
          "coin": "BTC",
          "equity": "0.00102964",
          "walletBalance": "0.00102964",
          "locked": "0",
          "borrowAmount": "0",
          "spotBorrow": "0"
        }
      ]
    }
  ]
}|};
  [%expect
    {|
    (Wallet
     ((id 592324d2bce751-ad38-48eb-8f42-4671d1fb4d4e) (topic Wallet)
      (creation_time 1700034722104)
      (data
       (((account_type UNIFIED) (total_equity 10262.91335023)
         (total_wallet_balance 9684.46297164)
         (total_margin_balance 9684.46297164)
         (total_available_balance 9556.6056555) (total_perp_upl ())
         (total_initial_margin ()) (total_maintenance_margin ())
         (coin
          (((coin BTC) (wallet_balance 0.00102964) (equity 0.00102964)
            (unrealised_pnl ()) (cum_realised_pnl ()) (usd_value ())
            (locked (0))))))))))
    {"id":"592324d2bce751-ad38-48eb-8f42-4671d1fb4d4e","topic":"wallet","creationTime":1700034722104,"data":[{"accountType":"UNIFIED","totalEquity":"10262.91335023","totalWalletBalance":"9684.46297164","totalMarginBalance":"9684.46297164","totalAvailableBalance":"9556.6056555","coin":[{"coin":"BTC","walletBalance":"0.00102964","equity":"0.00102964","locked":"0"}]}]}
    |}]
;;

let%expect_test "unknown topic" =
  msg {|{"topic": "kline.1.BTCUSDT", "type": "snapshot", "data": [], "ts": 1}|};
  [%expect
    {|
    (Unknown
     "{\"topic\":\"kline.1.BTCUSDT\",\"type\":\"snapshot\",\"data\":[],\"ts\":1}")
    {"topic":"kline.1.BTCUSDT","type":"snapshot","data":[],"ts":1}
    |}]
;;

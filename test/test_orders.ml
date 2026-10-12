open! Core
open Bybit_protocol

let%expect_test "create order request" =
  Helpers.round_trip
    (module Create_order.Request)
    {|{ "category": "linear", "symbol": "BTCUSDT", "side": "Buy", "orderType": "Limit",
  "qty": "0.001", "price": "65000.00", "timeInForce": "PostOnly",
  "positionIdx": 0, "orderLinkId": "example-0001", "reduceOnly": false }|};
  [%expect
    {|
    ((category Linear)
     (params
      ((symbol BTCUSDT) (side Buy) (order_type Limit) (qty 0.001) (price (65000))
       (time_in_force (Post_only)) (reduce_only (false))
       (order_link_id (example-0001)) (position_idx (One_way)))))
    {"category":"linear","symbol":"BTCUSDT","side":"Buy","orderType":"Limit","qty":"0.001","price":"65000","timeInForce":"PostOnly","reduceOnly":false,"orderLinkId":"example-0001","positionIdx":0}
    |}]
;;

let%expect_test "create order request from constructors" =
  let params =
    Create_order.Params.limit
      (Symbol.of_string "BTCUSDT")
      ~side:Sell
      ~qty:(Size.of_string "0.002")
      ~price:(Price.of_string "70000.5")
      ~time_in_force:Post_only
  in
  print_endline
    (Yojson.Safe.to_string
       (Create_order.Request.yojson_of_t { category = Linear; params }));
  print_endline
    (Yojson.Safe.to_string
       (Create_order.Request.yojson_of_t
          { category = Linear
          ; params =
              Create_order.Params.market
                (Symbol.of_string "BTCUSDT")
                ~side:Buy
                ~qty:(Size.of_string "1")
                ~reduce_only:true
          }));
  [%expect
    {|
    {"category":"linear","symbol":"BTCUSDT","side":"Sell","orderType":"Limit","qty":"0.002","price":"70000.5","timeInForce":"PostOnly"}
    {"category":"linear","symbol":"BTCUSDT","side":"Buy","orderType":"Market","qty":"1","reduceOnly":true}
    |}]
;;

let%expect_test "create order response" =
  Helpers.round_trip_envelope
    (module Create_order.Response)
    {|{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "orderId": "1321003749386327552",
        "orderLinkId": "spot-test-postonly"
    },
    "retExtInfo": {},
    "time": 1672211918471
}|};
  [%expect
    {|
    ((ret_code 0) (ret_msg OK)
     (result
      ((order_id 1321003749386327552) (order_link_id (spot-test-postonly))))
     (ret_ext_info {}) (time 1672211918471))
    {"retCode":0,"retMsg":"OK","result":{"orderId":"1321003749386327552","orderLinkId":"spot-test-postonly"},"retExtInfo":{},"time":1672211918471}
    |}]
;;

let%expect_test "create batch" =
  Helpers.round_trip
    (module Create_batch.Request)
    {|{"category": "linear", "request": [
        {"symbol": "BTCUSDT", "side": "Buy", "orderType": "Limit", "qty": "0.001",
         "price": "65000", "timeInForce": "PostOnly", "orderLinkId": "b-1"},
        {"symbol": "BTCUSDT", "side": "Sell", "orderType": "Market", "qty": "0.001",
         "reduceOnly": true}]}|};
  let response =
    {|{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "list": [
            { "category": "spot", "symbol": "BTCUSDT", "orderId": "1666800494330512128",
              "orderLinkId": "spot-btc-03", "createAt": "1713434102752" },
            { "category": "spot", "symbol": "ATOMUSDT", "orderId": "1666800494330512129",
              "orderLinkId": "spot-atom-03", "createAt": "1713434102752" }
        ]
    },
    "retExtInfo": {
        "list": [
            { "code": 0, "msg": "OK" },
            { "code": 0, "msg": "OK" }
        ]
    },
    "time": 1713434102753
}|}
  in
  Helpers.round_trip_envelope (module Create_batch.Response) response;
  let envelope =
    Envelope.t_of_yojson
      Create_batch.Response.t_of_yojson
      (Yojson.Safe.from_string response)
  in
  print_s
    [%sexp
      (Create_batch.Ext_info.t_of_yojson envelope.ret_ext_info : Create_batch.Ext_info.t)];
  [%expect
    {|
    ((category Linear)
     (request
      (((symbol BTCUSDT) (side Buy) (order_type Limit) (qty 0.001)
        (price (65000)) (time_in_force (Post_only)) (reduce_only ())
        (order_link_id (b-1)) (position_idx ()))
       ((symbol BTCUSDT) (side Sell) (order_type Market) (qty 0.001) (price ())
        (time_in_force ()) (reduce_only (true)) (order_link_id ())
        (position_idx ())))))
    {"category":"linear","request":[{"symbol":"BTCUSDT","side":"Buy","orderType":"Limit","qty":"0.001","price":"65000","timeInForce":"PostOnly","orderLinkId":"b-1"},{"symbol":"BTCUSDT","side":"Sell","orderType":"Market","qty":"0.001","reduceOnly":true}]}
    ((ret_code 0) (ret_msg OK)
     (result
      ((list
        (((category Spot) (symbol BTCUSDT) (order_id 1666800494330512128)
          (order_link_id (spot-btc-03)) (create_at (1713434102752)))
         ((category Spot) (symbol ATOMUSDT) (order_id 1666800494330512129)
          (order_link_id (spot-atom-03)) (create_at (1713434102752)))))))
     (ret_ext_info
      "{\"list\":[{\"code\":0,\"msg\":\"OK\"},{\"code\":0,\"msg\":\"OK\"}]}")
     (time 1713434102753))
    {"retCode":0,"retMsg":"OK","result":{"list":[{"category":"spot","symbol":"BTCUSDT","orderId":"1666800494330512128","orderLinkId":"spot-btc-03","createAt":"1713434102752"},{"category":"spot","symbol":"ATOMUSDT","orderId":"1666800494330512129","orderLinkId":"spot-atom-03","createAt":"1713434102752"}]},"retExtInfo":{"list":[{"code":0,"msg":"OK"},{"code":0,"msg":"OK"}]},"time":1713434102753}
    ((list (((code 0) (msg OK)) ((code 0) (msg OK)))))
    |}]
;;

let%expect_test "cancel order" =
  Helpers.round_trip
    (module Cancel_order.Request)
    {|{"category": "linear", "symbol": "BTCUSDT", "orderLinkId": "linear-004"}|};
  Helpers.round_trip_envelope
    (module Cancel_order.Response)
    {|{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "orderId": "c6f055d9-7f21-4079-913d-e6523a9cfffa",
        "orderLinkId": "linear-004"
    },
    "retExtInfo": {},
    "time": 1672217377164
}|};
  [%expect
    {|
    ((category Linear) (symbol BTCUSDT) (order_id ())
     (order_link_id (linear-004)))
    {"category":"linear","symbol":"BTCUSDT","orderLinkId":"linear-004"}
    ((ret_code 0) (ret_msg OK)
     (result
      ((order_id c6f055d9-7f21-4079-913d-e6523a9cfffa)
       (order_link_id (linear-004))))
     (ret_ext_info {}) (time 1672217377164))
    {"retCode":0,"retMsg":"OK","result":{"orderId":"c6f055d9-7f21-4079-913d-e6523a9cfffa","orderLinkId":"linear-004"},"retExtInfo":{},"time":1672217377164}
    |}]
;;

let%expect_test "cancel all" =
  Helpers.round_trip
    (module Cancel_all.Request)
    {|{"category": "linear", "settleCoin": "USDT"}|};
  Helpers.round_trip_envelope
    (module Cancel_all.Response)
    {|{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "list": [
            { "orderId": "1616024329462743808", "orderLinkId": "1616024329462743809" },
            { "orderId": "1616024287544869632", "orderLinkId": "1616024287544869633" }
        ],
        "success": "1"
    },
    "retExtInfo": {},
    "time": 1707381118116
}|};
  [%expect
    {|
    ((category Linear) (symbol ()) (base_coin ()) (settle_coin (USDT))
     (order_filter ()))
    {"category":"linear","settleCoin":"USDT"}
    ((ret_code 0) (ret_msg OK)
     (result
      ((list
        (((order_id 1616024329462743808) (order_link_id (1616024329462743809)))
         ((order_id 1616024287544869632) (order_link_id (1616024287544869633)))))
       (success true)))
     (ret_ext_info {}) (time 1707381118116))
    {"retCode":0,"retMsg":"OK","result":{"list":[{"orderId":"1616024329462743808","orderLinkId":"1616024329462743809"},{"orderId":"1616024287544869632","orderLinkId":"1616024287544869633"}],"success":"1"},"retExtInfo":{},"time":1707381118116}
    |}]
;;

let%expect_test "amend order" =
  Helpers.round_trip
    (module Amend_order.Request)
    {|{"category": "linear", "symbol": "ETHUSDT", "orderId": "c6f055d9-7f21-4079-913d-e6523a9cfffa",
       "qty": "0.15", "price": "1610.50"}|};
  Helpers.round_trip_envelope
    (module Amend_order.Response)
    {|{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "orderId": "c6f055d9-7f21-4079-913d-e6523a9cfffa",
        "orderLinkId": "linear-004"
    },
    "retExtInfo": {},
    "time": 1672217093461
}|};
  [%expect
    {|
    ((category Linear) (symbol ETHUSDT)
     (order_id (c6f055d9-7f21-4079-913d-e6523a9cfffa)) (order_link_id ())
     (qty (0.15)) (price (1610.5)) (trigger_price ()))
    {"category":"linear","symbol":"ETHUSDT","orderId":"c6f055d9-7f21-4079-913d-e6523a9cfffa","qty":"0.15","price":"1610.5"}
    ((ret_code 0) (ret_msg OK)
     (result
      ((order_id c6f055d9-7f21-4079-913d-e6523a9cfffa)
       (order_link_id (linear-004))))
     (ret_ext_info {}) (time 1672217093461))
    {"retCode":0,"retMsg":"OK","result":{"orderId":"c6f055d9-7f21-4079-913d-e6523a9cfffa","orderLinkId":"linear-004"},"retExtInfo":{},"time":1672217093461}
    |}]
;;

let%expect_test "realtime orders" =
  Helpers.round_trip_envelope
    (module Realtime_order.Response)
    {|{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "list": [
            {
                "orderId": "fd4300ae-7847-404e-b947-b46980a4d140",
                "orderLinkId": "test-000005",
                "blockTradeId": "",
                "symbol": "ETHUSDT",
                "price": "1600.00",
                "qty": "0.10",
                "side": "Buy",
                "isLeverage": "",
                "positionIdx": 1,
                "orderStatus": "New",
                "cancelType": "UNKNOWN",
                "rejectReason": "EC_NoError",
                "avgPrice": "0",
                "leavesQty": "0.10",
                "leavesValue": "160",
                "cumExecQty": "0.00",
                "cumExecValue": "0",
                "cumExecFee": "0",
                "timeInForce": "GTC",
                "orderType": "Limit",
                "stopOrderType": "UNKNOWN",
                "orderIv": "",
                "triggerPrice": "0.00",
                "takeProfit": "2500.00",
                "stopLoss": "1500.00",
                "tpTriggerBy": "LastPrice",
                "slTriggerBy": "LastPrice",
                "triggerDirection": 0,
                "triggerBy": "UNKNOWN",
                "lastPriceOnCreated": "",
                "reduceOnly": false,
                "closeOnTrigger": false,
                "smpType": "None",
                "smpGroup": "0",
                "smpOrderId": "",
                "tpslMode": "Full",
                "tpLimitPrice": "",
                "slLimitPrice": "",
                "placeType": "",
                "createdTime": "1684738540559",
                "updatedTime": "1684738540561",
                "cumFeeDetail": { "MNT": "0.00242968" }
            }
        ],
        "nextPageCursor": "page_args%3Dfd4300ae-7847-404e-b947-b46980a4d140%26symbol%3D6%26",
        "category": "linear"
    },
    "retExtInfo": {},
    "time": 1684765770483
}|};
  [%expect
    {|
    ((ret_code 0) (ret_msg OK)
     (result
      ((category Linear)
       (list
        (((order_id fd4300ae-7847-404e-b947-b46980a4d140)
          (order_link_id (test-000005)) (symbol ETHUSDT) (side Buy)
          (order_type Limit) (price 1600) (qty 0.1) (time_in_force Gtc)
          (order_status New) (cum_exec_qty 0) (cum_exec_value 0) (avg_price (0))
          (leaves_qty (0.1)) (reduce_only false) (reject_reason No_error)
          (position_idx Hedge_buy) (created_time 1684738540559)
          (updated_time 1684738540561) (category ()) (closed_pnl ()))))
       (next_page_cursor
        (page_args%3Dfd4300ae-7847-404e-b947-b46980a4d140%26symbol%3D6%26))))
     (ret_ext_info {}) (time 1684765770483))
    {"retCode":0,"retMsg":"OK","result":{"category":"linear","list":[{"orderId":"fd4300ae-7847-404e-b947-b46980a4d140","orderLinkId":"test-000005","symbol":"ETHUSDT","side":"Buy","orderType":"Limit","price":"1600","qty":"0.1","timeInForce":"GTC","orderStatus":"New","cumExecQty":"0","cumExecValue":"0","avgPrice":"0","leavesQty":"0.1","reduceOnly":false,"rejectReason":"EC_NoError","positionIdx":1,"createdTime":"1684738540559","updatedTime":"1684738540561"}],"nextPageCursor":"page_args%3Dfd4300ae-7847-404e-b947-b46980a4d140%26symbol%3D6%26"},"retExtInfo":{},"time":1684765770483}
    |}]
;;

let%expect_test "execution list" =
  Helpers.round_trip_envelope
    (module Execution.Response)
    {|{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "nextPageCursor": "132766%3A2%2C132766%3A2",
        "category": "linear",
        "list": [
            {
                "symbol": "ETHPERP",
                "orderType": "Market",
                "underlyingPrice": "",
                "orderLinkId": "",
                "side": "Buy",
                "indexPrice": "",
                "orderId": "8c065341-7b52-4ca9-ac2c-37e31ac55c94",
                "stopOrderType": "UNKNOWN",
                "leavesQty": "0",
                "execTime": "1672282722429",
                "feeCurrency": "",
                "isMaker": false,
                "execFee": "0.071409",
                "feeRate": "0.0006",
                "execId": "e0cbe81d-0f18-5866-9415-cf319b5dab3b",
                "tradeIv": "",
                "blockTradeId": "",
                "markPrice": "1183.54",
                "execPrice": "1190.15",
                "markIv": "",
                "orderQty": "0.1",
                "orderPrice": "1236.9",
                "execValue": "119.015",
                "execType": "Trade",
                "execQty": "0.1",
                "closedSize": "",
                "extraFees": "",
                "seq": 4688002127
            }
        ]
    },
    "retExtInfo": {},
    "time": 1672283754510
}|};
  [%expect
    {|
    ((ret_code 0) (ret_msg OK)
     (result
      ((category Linear)
       (list
        (((exec_id e0cbe81d-0f18-5866-9415-cf319b5dab3b)
          (order_id 8c065341-7b52-4ca9-ac2c-37e31ac55c94) (order_link_id ())
          (symbol ETHPERP) (side Buy) (exec_price 1190.15) (exec_qty 0.1)
          (exec_value 119.015) (exec_fee 0.071409) (fee_rate (0.0006))
          (exec_type Trade) (is_maker false) (exec_time 1672282722429)
          (closed_size ()) (seq (4688002127)) (category ()))))
       (next_page_cursor (132766%3A2%2C132766%3A2))))
     (ret_ext_info {}) (time 1672283754510))
    {"retCode":0,"retMsg":"OK","result":{"category":"linear","list":[{"execId":"e0cbe81d-0f18-5866-9415-cf319b5dab3b","orderId":"8c065341-7b52-4ca9-ac2c-37e31ac55c94","orderLinkId":"","symbol":"ETHPERP","side":"Buy","execPrice":"1190.15","execQty":"0.1","execValue":"119.015","execFee":"0.071409","feeRate":"0.0006","execType":"Trade","isMaker":false,"execTime":"1672282722429","closedSize":"","seq":4688002127}],"nextPageCursor":"132766%3A2%2C132766%3A2"},"retExtInfo":{},"time":1672283754510}
    |}]
;;

open! Core
open Bybit_protocol

let%expect_test "instruments-info" =
  Helpers.round_trip_envelope
    (module Instruments_info)
    {|{
  "retCode": 0,
  "retMsg": "OK",
  "result": {
    "category": "linear",
    "list": [
      {
        "symbol": "BTCUSDT",
        "symbolId": 5,
        "contractType": "LinearPerpetual",
        "status": "Trading",
        "baseCoin": "BTC",
        "quoteCoin": "USDT",
        "leverageFilter": { "minLeverage": "1", "maxLeverage": "100.00", "leverageStep": "0.01" },
        "priceFilter": { "minPrice": "0.10", "maxPrice": "1999999.80", "tickSize": "0.10" },
        "lotSizeFilter": {
          "maxOrderQty": "1190.000",
          "minOrderQty": "0.001",
          "qtyStep": "0.001",
          "postOnlyMaxOrderQty": "1190.000",
          "maxMktOrderQty": "500.000",
          "minNotionalValue": "5"
        }
      }
    ],
    "nextPageCursor": ""
  },
  "retExtInfo": {},
  "time": 1735809771618
}|};
  [%expect
    {|
    ((ret_code 0) (ret_msg OK)
     (result
      ((category Linear)
       (list
        (((symbol BTCUSDT) (contract_type LinearPerpetual) (status Trading)
          (base_coin BTC) (quote_coin USDT)
          (leverage_filter
           ((min_leverage 1) (max_leverage 100) (leverage_step 0.01)))
          (price_filter ((min_price 0.1) (max_price 1999999.8) (tick_size 0.1)))
          (lot_size_filter
           ((max_order_qty 1190) (min_order_qty 0.001) (qty_step 0.001)
            (max_mkt_order_qty (500)) (min_notional_value (5)))))))
       (next_page_cursor (""))))
     (ret_ext_info {}) (time 1735809771618))
    {"retCode":0,"retMsg":"OK","result":{"category":"linear","list":[{"symbol":"BTCUSDT","contractType":"LinearPerpetual","status":"Trading","baseCoin":"BTC","quoteCoin":"USDT","leverageFilter":{"minLeverage":"1","maxLeverage":"100","leverageStep":"0.01"},"priceFilter":{"minPrice":"0.1","maxPrice":"1999999.8","tickSize":"0.1"},"lotSizeFilter":{"maxOrderQty":"1190","minOrderQty":"0.001","qtyStep":"0.001","maxMktOrderQty":"500","minNotionalValue":"5"}}],"nextPageCursor":""},"retExtInfo":{},"time":1735809771618}
    |}]
;;

let%expect_test "instrument to exchange-core" =
  let json =
    {|{"symbol": "BTCUSDT", "contractType": "LinearPerpetual", "status": "Trading",
       "baseCoin": "BTC", "quoteCoin": "USDT",
       "leverageFilter": { "minLeverage": "1", "maxLeverage": "100.00", "leverageStep": "0.01" },
       "priceFilter": { "minPrice": "0.10", "maxPrice": "1999999.80", "tickSize": "0.10" },
       "lotSizeFilter": { "maxOrderQty": "1190.000", "minOrderQty": "0.001", "qtyStep": "0.001" }}|}
  in
  let instrument =
    Instruments_info.Instrument.t_of_yojson (Yojson.Safe.from_string json)
  in
  print_s
    [%sexp
      (Instruments_info.Instrument.to_exchange_core instrument
       : Exchange_core.Instrument.t)];
  [%expect
    {|
    ((symbol BTCUSDT) (size_decimals 3) (price_tick 0.1)
     (max_significant_figures ()) (max_leverage 100)
     (fees ((taker_bps 3.5) (maker_bps 1))))
    |}]
;;

let%expect_test "orderbook" =
  Helpers.round_trip_envelope
    (module Orderbook)
    {|{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "s": "BTCUSDT",
        "a": [ [ "65557.7", "16.606555" ] ],
        "b": [ [ "65485.47", "47.081829" ] ],
        "ts": 1716863719031,
        "u": 230704,
        "seq": 1432604333,
        "cts": 1716863718905
    },
    "retExtInfo": {},
    "time": 1716863719382
}|};
  [%expect
    {|
    ((ret_code 0) (ret_msg OK)
     (result
      ((s BTCUSDT) (b (((price 65485.47) (size 47.081829))))
       (a (((price 65557.7) (size 16.606555)))) (ts 1716863719031) (u 230704)
       (seq 1432604333) (cts (1716863718905))))
     (ret_ext_info {}) (time 1716863719382))
    {"retCode":0,"retMsg":"OK","result":{"s":"BTCUSDT","b":[["65485.47","47.081829"]],"a":[["65557.7","16.606555"]],"ts":1716863719031,"u":230704,"seq":1432604333,"cts":1716863718905},"retExtInfo":{},"time":1716863719382}
    |}]
;;

let%expect_test "tickers" =
  Helpers.round_trip_envelope
    (module Tickers)
    {|{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "category": "inverse",
        "list": [
            {
                "symbol": "BTCUSD",
                "lastPrice": "120635.50",
                "indexPrice": "114890.92",
                "markPrice": "114898.43",
                "prevPrice24h": "105595.90",
                "price24hPcnt": "0.142425",
                "highPrice24h": "131309.30",
                "lowPrice24h": "102007.60",
                "prevPrice1h": "119806.10",
                "openInterest": "240113967",
                "openInterestValue": "2089.79",
                "turnover24h": "115.6907",
                "volume24h": "13713832.0000",
                "fundingRate": "0.0001",
                "nextFundingTime": "1760371200000",
                "predictedDeliveryPrice": "",
                "basisRate": "",
                "deliveryFeeRate": "",
                "deliveryTime": "0",
                "ask1Size": "9854",
                "bid1Price": "103401.00",
                "ask1Price": "109152.80",
                "bid1Size": "1063",
                "basis": "",
                "preOpenPrice": "",
                "preQty": "",
                "curPreListingPhase": "",
                "fundingIntervalHour": "8",
                "basisRateYear": "",
                "fundingCap": "0.005"
            }
        ]
    },
    "retExtInfo": {},
    "time": 1760352369814
}|};
  [%expect
    {|
    ((ret_code 0) (ret_msg OK)
     (result
      ((category Inverse)
       (list
        (((symbol BTCUSD) (last_price 120635.5) (mark_price 114898.43)
          (index_price 114890.92) (bid1_price (103401)) (bid1_size (1063))
          (ask1_price (109152.8)) (ask1_size (9854)) (funding_rate (0.0001))
          (next_funding_time 1760371200000) (open_interest (240113967))
          (volume24h (13713832)) (turnover24h (115.6907))
          (price24h_pcnt (0.142425)))))
       (next_page_cursor ())))
     (ret_ext_info {}) (time 1760352369814))
    {"retCode":0,"retMsg":"OK","result":{"category":"inverse","list":[{"symbol":"BTCUSD","lastPrice":"120635.5","markPrice":"114898.43","indexPrice":"114890.92","bid1Price":"103401","bid1Size":"1063","ask1Price":"109152.8","ask1Size":"9854","fundingRate":"0.0001","nextFundingTime":"1760371200000","openInterest":"240113967","volume24h":"13713832","turnover24h":"115.6907","price24hPcnt":"0.142425"}]},"retExtInfo":{},"time":1760352369814}
    |}]
;;

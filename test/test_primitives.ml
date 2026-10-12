open! Core
open Bybit_protocol

let show (type a) (module M : Codec.S with type t = a) json =
  let t = M.t_of_yojson (Yojson.Safe.from_string json) in
  printf
    "%s -> %s -> %s\n"
    json
    (Sexp.to_string (M.sexp_of_t t))
    (Yojson.Safe.to_string (M.yojson_of_t t))
;;

let%expect_test "enums" =
  show (module Side) {|"Buy"|};
  show (module Side.Or_empty) {|""|};
  show (module Category) {|"linear"|};
  show (module Order_type) {|"Limit"|};
  show (module Order_type) {|"UNKNOWN"|};
  show (module Time_in_force) {|"PostOnly"|};
  show (module Order_status) {|"PartiallyFilledCanceled"|};
  show (module Position_idx) {|2|};
  show (module Reject_reason) {|"EC_PostOnlyWillTakeLiquidity"|};
  show (module Reject_reason) {|"EC_SomethingNew"|};
  show (module Exec_type) {|"AdlTrade"|};
  [%expect
    {|
    "Buy" -> Buy -> "Buy"
    "" -> () -> ""
    "linear" -> Linear -> "linear"
    "Limit" -> Limit -> "Limit"
    "UNKNOWN" -> Unknown -> "UNKNOWN"
    "PostOnly" -> Post_only -> "PostOnly"
    "PartiallyFilledCanceled" -> Partially_filled_canceled -> "PartiallyFilledCanceled"
    2 -> Hedge_sell -> 2
    "EC_PostOnlyWillTakeLiquidity" -> Post_only_will_take_liquidity -> "EC_PostOnlyWillTakeLiquidity"
    "EC_SomethingNew" -> (Other EC_SomethingNew) -> "EC_SomethingNew"
    "AdlTrade" -> Adl_trade -> "AdlTrade"
    |}]
;;

let%expect_test "decimals and timestamps" =
  show (module Price) {|"65000.00"|};
  show (module Price.Or_empty) {|""|};
  show (module Size.Or_empty) {|"0.10"|};
  show (module Decimal) {|"-0.005"|};
  show (module Timestamp_ms) {|1672211918471|};
  show (module Timestamp_ms) {|"1672211918471"|};
  show (module Timestamp_ms.As_string) {|1672211918471|};
  show (module Timestamp_ms.As_string) {|"1672211918471"|};
  [%expect
    {|
    "65000.00" -> 65000 -> "65000"
    "" -> () -> ""
    "0.10" -> (0.1) -> "0.1"
    "-0.005" -> -0.005 -> "-0.005"
    1672211918471 -> 1672211918471 -> 1672211918471
    "1672211918471" -> 1672211918471 -> 1672211918471
    1672211918471 -> 1672211918471 -> "1672211918471"
    "1672211918471" -> 1672211918471 -> "1672211918471"
    |}]
;;

let%expect_test "ids" =
  let print_core id =
    print_s
      [%sexp
        (Order_id.to_exchange_core (Order_id.of_string id)
         : Exchange_core.Order_id.t option)]
  in
  print_core "1321003749386327552";
  print_core "fd4300ae-7847-404e-b947-b46980a4d140";
  print_core "99999999999999999999";
  print_s [%sexp (Order_link_id.create "example-0001" : Order_link_id.t Or_error.t)];
  print_s [%sexp (Order_link_id.create "has space" : Order_link_id.t Or_error.t)];
  print_s [%sexp (Order_link_id.create (String.make 37 'a') : Order_link_id.t Or_error.t)];
  [%expect
    {|
    (1321003749386327552)
    ()
    ()
    (Ok example-0001)
    (Error ("orderLinkId may only use A-Za-z0-9_-" "has space"))
    (Error
     ("orderLinkId must be 1 to 36 characters"
      aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa))
    |}]
;;

let%expect_test "topics" =
  List.iter
    [ "orderbook.50.BTCUSDT"
    ; "publicTrade.BTCUSDT"
    ; "tickers.BTCUSDT"
    ; "order"
    ; "order.linear"
    ; "execution.linear"
    ; "position"
    ; "wallet"
    ; "kline.1.BTCUSDT"
    ; "order.bogus"
    ]
    ~f:(fun s ->
      let t = Topic.of_string s in
      printf "%s -> %s -> %s\n" s (Sexp.to_string (Topic.sexp_of_t t)) (Topic.to_string t));
  [%expect
    {|
    orderbook.50.BTCUSDT -> (Orderbook(depth 50)(symbol BTCUSDT)) -> orderbook.50.BTCUSDT
    publicTrade.BTCUSDT -> (Public_trade BTCUSDT) -> publicTrade.BTCUSDT
    tickers.BTCUSDT -> (Tickers BTCUSDT) -> tickers.BTCUSDT
    order -> (Order()) -> order
    order.linear -> (Order(Linear)) -> order.linear
    execution.linear -> (Execution(Linear)) -> execution.linear
    position -> (Position()) -> position
    wallet -> Wallet -> wallet
    kline.1.BTCUSDT -> (Other kline.1.BTCUSDT) -> kline.1.BTCUSDT
    order.bogus -> (Other order.bogus) -> order.bogus
    |}]
;;

let%expect_test "exchange-core mappings" =
  List.iter Time_in_force.all ~f:(fun t ->
    print_s
      [%sexp
        (t : Time_in_force.t)
        , (Time_in_force.to_exchange_core t : Exchange_core.Tif.t option)]);
  print_s
    [%sexp
      (Reject_reason.to_exchange_core Post_only_will_take_liquidity
       : Exchange_core.Reject_reason.t option)];
  [%expect
    {|
    (Gtc (Gtc))
    (Ioc (Ioc))
    (Fok ())
    (Post_only (Alo))
    (Rpi ())
    ((Post_only_would_cross (best_bid ()) (best_ask ())))
    |}]
;;

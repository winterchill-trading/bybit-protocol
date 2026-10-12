open! Core

type t =
  | Subscribe_ack of Op_response.t
  | Auth_ack of Op_response.t
  | Pong of Op_response.t
  | Op_response of Op_response.t
  | Orderbook of Ws_orderbook.t
  | Public_trade of Public_trade.t
  | Ticker of Ws_ticker.t
  | Order of Realtime_order.t Private_push.t
  | Execution of Execution.t Private_push.t
  | Position of Position.Ws.t Private_push.t
  | Wallet of Wallet_balance.Account.t Private_push.t
  | Unknown of Json.t
[@@deriving sexp, compare, equal]

let yojson_of_t = function
  | Subscribe_ack r | Auth_ack r | Pong r | Op_response r -> Op_response.yojson_of_t r
  | Orderbook m -> Ws_orderbook.yojson_of_t m
  | Public_trade m -> Public_trade.yojson_of_t m
  | Ticker m -> Ws_ticker.yojson_of_t m
  | Order m -> Private_push.yojson_of_t Realtime_order.yojson_of_t m
  | Execution m -> Private_push.yojson_of_t Execution.yojson_of_t m
  | Position m -> Private_push.yojson_of_t Position.Ws.yojson_of_t m
  | Wallet m -> Private_push.yojson_of_t Wallet_balance.Account.yojson_of_t m
  | Unknown json -> json
;;

let t_of_yojson json =
  match Json.member json ~key:"op", Json.member json ~key:"topic" with
  | Some (`String op), _ ->
    let r = Op_response.t_of_yojson json in
    (match op with
     | "subscribe" | "unsubscribe" -> Subscribe_ack r
     | "auth" -> Auth_ack r
     | "ping" | "pong" -> Pong r
     | _ -> Op_response r)
  | _, Some topic ->
    (match Topic.t_of_yojson topic with
     | Orderbook _ -> Orderbook (Ws_orderbook.t_of_yojson json)
     | Public_trade _ -> Public_trade (Public_trade.t_of_yojson json)
     | Tickers _ -> Ticker (Ws_ticker.t_of_yojson json)
     | Order _ -> Order (Private_push.t_of_yojson Realtime_order.t_of_yojson json)
     | Execution _ -> Execution (Private_push.t_of_yojson Execution.t_of_yojson json)
     | Position _ -> Position (Private_push.t_of_yojson Position.Ws.t_of_yojson json)
     | Wallet -> Wallet (Private_push.t_of_yojson Wallet_balance.Account.t_of_yojson json)
     | Other _ -> Unknown json)
  | _ -> Unknown json
;;

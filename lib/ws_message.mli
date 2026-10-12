(** Server-to-client websocket messages. Messages with an [op] field are replies to
    requests ({!Op_response}); the others are decoded by [topic]. Unknown topics are kept
    as [Unknown]. *)

open! Core

type t =
  | Subscribe_ack of Op_response.t (** [op] ["subscribe"] or ["unsubscribe"] *)
  | Auth_ack of Op_response.t
  | Pong of Op_response.t
  (** public pongs reply with [op] ["ping"] and [ret_msg] ["pong"]; private ones with [op]
      ["pong"] *)
  | Op_response of Op_response.t (** any other [op] *)
  | Orderbook of Ws_orderbook.t
  | Public_trade of Public_trade.t
  | Ticker of Ws_ticker.t
  | Order of Realtime_order.t Private_push.t
  | Execution of Execution.t Private_push.t
  | Position of Position.Ws.t Private_push.t
  | Wallet of Wallet_balance.Account.t Private_push.t
  | Unknown of Json.t
[@@deriving sexp, compare, equal, yojson]

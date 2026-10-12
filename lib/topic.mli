(** Websocket topics. Public: [orderbook.<depth>.<symbol>] (depth 1, 50, 200 or 1000 for
    linear), [publicTrade.<symbol>], [tickers.<symbol>]. Private: [order], [execution],
    [position] (all-in-one, or categorised as [order.linear] etc.) and [wallet]. Anything
    else is [Other]. *)

open! Core

type t =
  | Orderbook of
      { depth : int
      ; symbol : Symbol.t
      }
  | Public_trade of Symbol.t
  | Tickers of Symbol.t
  | Order of Category.t option
  | Execution of Category.t option
  | Position of Category.t option
  | Wallet
  | Other of string
[@@deriving sexp, compare, equal, yojson]

val to_string : t -> string
val of_string : string -> t

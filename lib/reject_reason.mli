(** Order reject reason ([rejectReason]), e.g. ["EC_NoError"] on accepted orders and
    ["EC_PostOnlyWillTakeLiquidity"] when a post-only order would cross. Values not listed
    here decode to [Other]. *)

open! Core

type t =
  | No_error
  | Post_only_will_take_liquidity
  | No_enough_qty_to_fill
  | No_immediate_qty_to_fill
  | Qty_cannot_be_zero
  | Limit_order_invalid_price
  | Reach_risk_price_limit
  | Order_not_exist
  | By_self_match
  | Cancel_by_mmp
  | Other of string
[@@deriving sexp, compare, equal, hash, yojson]

val to_wire : t -> string
val of_wire : string -> t option

(** Venue-neutral reason, where one exists. [No_error] maps to [None]. *)
val to_exchange_core : t -> Exchange_core.Reject_reason.t option

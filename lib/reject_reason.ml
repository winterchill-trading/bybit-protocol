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
[@@deriving sexp, compare, equal, hash]

let to_wire = function
  | No_error -> "EC_NoError"
  | Post_only_will_take_liquidity -> "EC_PostOnlyWillTakeLiquidity"
  | No_enough_qty_to_fill -> "EC_NoEnoughQtyToFill"
  | No_immediate_qty_to_fill -> "EC_NoImmediateQtyToFill"
  | Qty_cannot_be_zero -> "EC_QtyCannotBeZero"
  | Limit_order_invalid_price -> "EC_LimitOrderInvalidPrice"
  | Reach_risk_price_limit -> "EC_ReachRiskPriceLimit"
  | Order_not_exist -> "EC_OrderNotExist"
  | By_self_match -> "EC_BySelfMatch"
  | Cancel_by_mmp -> "EC_CancelByMMP"
  | Other s -> s
;;

let of_wire = function
  | "EC_NoError" -> Some No_error
  | "EC_PostOnlyWillTakeLiquidity" -> Some Post_only_will_take_liquidity
  | "EC_NoEnoughQtyToFill" -> Some No_enough_qty_to_fill
  | "EC_NoImmediateQtyToFill" -> Some No_immediate_qty_to_fill
  | "EC_QtyCannotBeZero" -> Some Qty_cannot_be_zero
  | "EC_LimitOrderInvalidPrice" -> Some Limit_order_invalid_price
  | "EC_ReachRiskPriceLimit" -> Some Reach_risk_price_limit
  | "EC_OrderNotExist" -> Some Order_not_exist
  | "EC_BySelfMatch" -> Some By_self_match
  | "EC_CancelByMMP" -> Some Cancel_by_mmp
  | s -> Some (Other s)
;;

let yojson_of_t t : Yojson.Safe.t = `String (to_wire t)

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `String s ->
    (match of_wire s with
     | Some t -> t
     | None -> Json.error "reject_reason: unknown value" json)
  | _ -> Json.error "reject_reason: string expected" json
;;

let to_exchange_core : t -> Exchange_core.Reject_reason.t option = function
  | No_error -> None
  | Post_only_will_take_liquidity ->
    Some (Post_only_would_cross { best_bid = None; best_ask = None })
  | No_enough_qty_to_fill | No_immediate_qty_to_fill -> Some No_liquidity
  | Qty_cannot_be_zero -> Some Invalid_size
  | Limit_order_invalid_price | Reach_risk_price_limit -> Some Invalid_price
  | Order_not_exist -> Some Order_not_found
  | By_self_match -> Some Self_trade
  | Cancel_by_mmp -> Some (Unsupported "EC_CancelByMMP")
  | Other s -> Some (Unsupported s)
;;

open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t =
  { order_id : Order_id.t [@key "orderId"]
  ; order_link_id : Order_link_id.Or_empty.t [@key "orderLinkId"]
  ; symbol : Symbol.t
  ; side : Side.t
  ; order_type : Order_type.t [@key "orderType"]
  ; price : Price.t
  ; qty : Size.t
  ; time_in_force : Time_in_force.t [@key "timeInForce"]
  ; order_status : Order_status.t [@key "orderStatus"]
  ; cum_exec_qty : Size.t [@key "cumExecQty"]
  ; cum_exec_value : Usd.t [@key "cumExecValue"]
  ; avg_price : Price.Or_empty.t [@key "avgPrice"]
  ; leaves_qty : Size.Or_empty.t [@key "leavesQty"]
  ; reduce_only : bool [@key "reduceOnly"]
  ; reject_reason : Reject_reason.t [@key "rejectReason"]
  ; position_idx : Position_idx.t [@key "positionIdx"]
  ; created_time : Timestamp_ms.As_string.t [@key "createdTime"]
  ; updated_time : Timestamp_ms.As_string.t [@key "updatedTime"]
  ; category : Category.t option [@default None] [@yojson_drop_if Option.is_none]
  ; closed_pnl : Usd.t option
       [@key "closedPnl"] [@default None] [@yojson_drop_if Option.is_none]
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

module Response = struct
  type nonrec t = t Page.t [@@deriving sexp, compare, equal, yojson]
end

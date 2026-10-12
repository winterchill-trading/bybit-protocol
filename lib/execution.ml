open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t =
  { exec_id : Exec_id.t [@key "execId"]
  ; order_id : Order_id.t [@key "orderId"]
  ; order_link_id : Order_link_id.Or_empty.t [@key "orderLinkId"]
  ; symbol : Symbol.t
  ; side : Side.t
  ; exec_price : Price.t [@key "execPrice"]
  ; exec_qty : Size.t [@key "execQty"]
  ; exec_value : Usd.t [@key "execValue"]
  ; exec_fee : Usd.t [@key "execFee"]
  ; fee_rate : Decimal.Or_empty.t [@key "feeRate"]
  ; exec_type : Exec_type.t [@key "execType"]
  ; is_maker : bool [@key "isMaker"]
  ; exec_time : Timestamp_ms.As_string.t [@key "execTime"]
  ; closed_size : Size.Or_empty.t [@key "closedSize"]
  ; seq : int option [@default None] [@yojson_drop_if Option.is_none]
  ; category : Category.t option [@default None] [@yojson_drop_if Option.is_none]
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

module Response = struct
  type nonrec t = t Page.t [@@deriving sexp, compare, equal, yojson]
end

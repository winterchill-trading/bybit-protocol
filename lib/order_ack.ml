open! Core

type t =
  { order_id : Order_id.t [@key "orderId"]
  ; order_link_id : Order_link_id.Or_empty.t [@key "orderLinkId"]
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

(** [{"orderId": "...", "orderLinkId": "..."}], the [result] of create, cancel and amend.
    An acknowledgement only: these endpoints are asynchronous, the order's fate arrives on
    the [order] websocket topic or [GET /v5/order/realtime]. *)

open! Core

type t =
  { order_id : Order_id.t
  ; order_link_id : Order_link_id.Or_empty.t
  }
[@@deriving sexp, compare, equal, yojson]

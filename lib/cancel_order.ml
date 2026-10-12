open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Request = struct
  type t =
    { category : Category.t
    ; symbol : Symbol.t
    ; order_id : Order_id.t option
         [@key "orderId"] [@default None] [@yojson_drop_if Option.is_none]
    ; order_link_id : Order_link_id.t option
         [@key "orderLinkId"] [@default None] [@yojson_drop_if Option.is_none]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

module Response = Order_ack

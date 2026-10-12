open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Request = struct
  type t =
    { category : Category.t
    ; request : Create_order.Params.t list
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

module Item = struct
  type t =
    { category : Category.t
    ; symbol : Symbol.t
    ; order_id : Order_id.t [@key "orderId"]
    ; order_link_id : Order_link_id.Or_empty.t [@key "orderLinkId"]
    ; create_at : Timestamp_ms.As_string.t option
         [@key "createAt"] [@default None] [@yojson_drop_if Option.is_none]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

module Response = struct
  type t = { list : Item.t list }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

module Ext_info = struct
  module Status = struct
    type t =
      { code : int
      ; msg : string
      }
    [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

    let error t = Envelope.Error.of_code t.code
  end

  type t = { list : Status.t list }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

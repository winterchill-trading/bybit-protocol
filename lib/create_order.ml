open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Params = struct
  type t =
    { symbol : Symbol.t
    ; side : Side.t
    ; order_type : Order_type.t [@key "orderType"]
    ; qty : Size.t
    ; price : Price.t option [@default None] [@yojson_drop_if Option.is_none]
    ; time_in_force : Time_in_force.t option
         [@key "timeInForce"] [@default None] [@yojson_drop_if Option.is_none]
    ; reduce_only : bool option
         [@key "reduceOnly"] [@default None] [@yojson_drop_if Option.is_none]
    ; order_link_id : Order_link_id.t option
         [@key "orderLinkId"] [@default None] [@yojson_drop_if Option.is_none]
    ; position_idx : Position_idx.t option
         [@key "positionIdx"] [@default None] [@yojson_drop_if Option.is_none]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

  let limit
    ?time_in_force
    ?reduce_only
    ?order_link_id
    ?position_idx
    symbol
    ~side
    ~qty
    ~price
    =
    { symbol
    ; side
    ; order_type = Limit
    ; qty
    ; price = Some price
    ; time_in_force
    ; reduce_only
    ; order_link_id
    ; position_idx
    }
  ;;

  let market ?reduce_only ?order_link_id ?position_idx symbol ~side ~qty =
    { symbol
    ; side
    ; order_type = Market
    ; qty
    ; price = None
    ; time_in_force = None
    ; reduce_only
    ; order_link_id
    ; position_idx
    }
  ;;
end

module Request = struct
  type t =
    { category : Category.t
    ; params : Params.t
    }
  [@@deriving sexp, compare, equal]

  let yojson_of_t { category; params } : Yojson.Safe.t =
    match Params.yojson_of_t params with
    | `Assoc fields -> `Assoc (("category", Category.yojson_of_t category) :: fields)
    | other -> other
  ;;

  let t_of_yojson json =
    { category = Category.t_of_yojson (Json.member_exn json ~key:"category")
    ; params = Params.t_of_yojson json
    }
  ;;
end

module Response = Order_ack

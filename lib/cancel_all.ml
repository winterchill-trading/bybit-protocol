open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Request = struct
  type t =
    { category : Category.t
    ; symbol : Symbol.t option [@default None] [@yojson_drop_if Option.is_none]
    ; base_coin : string option
         [@key "baseCoin"] [@default None] [@yojson_drop_if Option.is_none]
    ; settle_coin : string option
         [@key "settleCoin"] [@default None] [@yojson_drop_if Option.is_none]
    ; order_filter : string option
         [@key "orderFilter"] [@default None] [@yojson_drop_if Option.is_none]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

module Response = struct
  module Flag = struct
    type t = bool [@@deriving sexp, compare, equal]

    let yojson_of_t t : Yojson.Safe.t = `String (if t then "1" else "0")

    let t_of_yojson (json : Yojson.Safe.t) =
      match json with
      | `String "1" -> true
      | `String "0" -> false
      | _ -> Json.error "success: \"1\" or \"0\" expected" json
    ;;
  end

  type t =
    { list : Order_ack.t list
    ; success : Flag.t
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

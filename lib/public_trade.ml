open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Trade = struct
  type t =
    { time : Timestamp_ms.t [@key "T"]
    ; symbol : Symbol.t [@key "s"]
    ; side : Side.t [@key "S"]
    ; size : Size.t [@key "v"]
    ; price : Price.t [@key "p"]
    ; tick_direction : string option
         [@key "L"] [@default None] [@yojson_drop_if Option.is_none]
    ; trade_id : Exec_id.t [@key "i"]
    ; block_trade : bool [@key "BT"] [@default false]
    ; rpi : bool option [@key "RPI"] [@default None] [@yojson_drop_if Option.is_none]
    ; seq : int option [@default None] [@yojson_drop_if Option.is_none]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

type t =
  { topic : Topic.t
  ; type_ : Update_type.t [@key "type"]
  ; ts : Timestamp_ms.t
  ; data : Trade.t list
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

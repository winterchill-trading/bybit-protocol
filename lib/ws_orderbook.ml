open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Data = struct
  type t =
    { s : Symbol.t
    ; b : Book_level.t list
    ; a : Book_level.t list
    ; u : int
    ; seq : int
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

type t =
  { topic : Topic.t
  ; type_ : Update_type.t [@key "type"]
  ; ts : Timestamp_ms.t
  ; data : Data.t
  ; cts : Timestamp_ms.t option [@default None] [@yojson_drop_if Option.is_none]
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

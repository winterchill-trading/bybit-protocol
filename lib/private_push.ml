open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type 'a t =
  { id : string
  ; topic : Topic.t
  ; creation_time : Timestamp_ms.t [@key "creationTime"]
  ; data : 'a list
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

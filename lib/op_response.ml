open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t =
  { success : bool option [@default None] [@yojson_drop_if Option.is_none]
  ; ret_msg : string option [@default None] [@yojson_drop_if Option.is_none]
  ; conn_id : string option [@default None] [@yojson_drop_if Option.is_none]
  ; req_id : string option [@default None] [@yojson_drop_if Option.is_none]
  ; op : string
  ; args : string list option [@default None] [@yojson_drop_if Option.is_none]
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

let is_failure t = Option.equal Bool.equal t.success (Some false)

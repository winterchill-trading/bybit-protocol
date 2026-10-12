open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type 'a t =
  { category : Category.t
  ; list : 'a list
  ; next_page_cursor : string option
       [@key "nextPageCursor"] [@default None] [@yojson_drop_if Option.is_none]
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

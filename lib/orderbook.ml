open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t =
  { s : Symbol.t
  ; b : Book_level.t list
  ; a : Book_level.t list
  ; ts : Timestamp_ms.t
  ; u : int
  ; seq : int
  ; cts : Timestamp_ms.t option [@default None] [@yojson_drop_if Option.is_none]
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

let to_exchange_core t : Exchange_core.L2.t =
  let level ({ price; size } : Book_level.t) : Exchange_core.L2.Level.t =
    { px = price; sz = size; n = 0 }
  in
  { symbol = t.s
  ; time = Timestamp_ms.to_int_ms t.ts * 1_000_000
  ; bids = List.map t.b ~f:level
  ; asks = List.map t.a ~f:level
  }
;;

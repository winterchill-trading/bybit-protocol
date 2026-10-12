(** [GET /v5/market/orderbook]: book snapshot,
    [{"s": "BTCUSDT", "b": [[px, sz], ...], "a": [...], "ts": ..., "u": ..., "seq": ..., "cts": ...}].
    Bids are sorted best (highest) first, asks best (lowest) first. *)

open! Core

type t =
  { s : Symbol.t
  ; b : Book_level.t list
  ; a : Book_level.t list
  ; ts : Timestamp_ms.t (** when the system generated the data *)
  ; u : int (** update id *)
  ; seq : int (** cross sequence *)
  ; cts : Timestamp_ms.t option (** matching-engine time *)
  }
[@@deriving sexp, compare, equal, yojson]

(** Order counts are not sent by Bybit; [n] is set to 0. [time] is [ts] in nanoseconds. *)
val to_exchange_core : t -> Exchange_core.L2.t

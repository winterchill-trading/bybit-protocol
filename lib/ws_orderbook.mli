(** [orderbook.<depth>.<symbol>] pushes:
    [{"topic", "type": "snapshot" | "delta", "ts", "data": {"s", "b", "a", "u", "seq"}, "cts"}].
    A snapshot resets the local book (also when [u = 1], a service restart). In a delta a
    level with size ["0"] is deleted, a new price inserted, an existing one replaced. *)

open! Core

module Data : sig
  type t =
    { s : Symbol.t
    ; b : Book_level.t list
    ; a : Book_level.t list
    ; u : int
    ; seq : int
    }
  [@@deriving sexp, compare, equal, yojson]
end

type t =
  { topic : Topic.t
  ; type_ : Update_type.t
  ; ts : Timestamp_ms.t
  ; data : Data.t
  ; cts : Timestamp_ms.t option
  }
[@@deriving sexp, compare, equal, yojson]

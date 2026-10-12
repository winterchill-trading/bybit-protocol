(** Order type: ["Limit"] or ["Market"]. ["UNKNOWN"] appears in some responses (e.g. on
    conditional orders) and is not valid in requests. *)

open! Core

type t =
  | Limit
  | Market
  | Unknown
[@@deriving sexp, compare, equal, hash, enumerate, yojson]

val to_wire : t -> string
val of_wire : string -> t option

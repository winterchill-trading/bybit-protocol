(** Websocket push type: ["snapshot"] replaces local state, ["delta"] updates it. *)

open! Core

type t =
  | Snapshot
  | Delta
[@@deriving sexp, compare, equal, hash, enumerate, yojson]

val to_wire : t -> string
val of_wire : string -> t option

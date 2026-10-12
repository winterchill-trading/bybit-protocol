(** One order book level, a [[price, size]] pair of decimal strings, e.g.
    [["65485.47", "47.081829"]]. In deltas a size of ["0"] deletes the level. *)

open! Core

type t =
  { price : Price.t
  ; size : Size.t
  }
[@@deriving sexp, compare, equal, yojson]

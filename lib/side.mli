(** Order or trade side: {!Exchange_core.Side} with Bybit's encoding, ["Buy"] or ["Sell"]. *)

open! Core

type t = Exchange_core.Side.t =
  | Buy
  | Sell
[@@deriving sexp, compare, equal, hash, enumerate, yojson]

val to_wire : t -> string
val of_wire : string -> t option
val of_is_buy : bool -> t
val is_buy : t -> bool
val flip : t -> t
val sign : t -> int

(** Position side: [""] (no position) decodes to [None]. *)
module Or_empty : Or_empty.S with type value := t

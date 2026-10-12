(** Position index, a JSON integer: [0] one-way mode, [1] hedge-mode buy side, [2]
    hedge-mode sell side. *)

open! Core

type t =
  | One_way
  | Hedge_buy
  | Hedge_sell
[@@deriving sexp, compare, equal, hash, enumerate, yojson]

val to_int : t -> int
val of_int : int -> t option

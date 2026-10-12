(** Execution type ([execType]); [Trade] for ordinary fills. Unlisted values decode to
    [Other]. *)

open! Core

type t =
  | Trade
  | Adl_trade
  | Funding
  | Bust_trade
  | Delivery
  | Settle
  | Block_trade
  | Move_position
  | Unknown
  | Other of string
[@@deriving sexp, compare, equal, hash, yojson]

val to_wire : t -> string
val of_wire : string -> t option

(** Product category: ["linear"] (USDT/USDC perpetuals and futures), ["inverse"], ["spot"]
    or ["option"]. This library targets [Linear]. *)

open! Core

type t =
  | Linear
  | Inverse
  | Spot
  | Option
[@@deriving sexp, compare, equal, hash, enumerate, yojson]

val to_wire : t -> string
val of_wire : string -> t option

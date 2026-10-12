(** Time in force: ["GTC"], ["IOC"], ["FOK"], ["PostOnly"] or ["RPI"] (retail price
    improvement, maker only). Market orders are always IOC. *)

open! Core

type t =
  | Gtc
  | Ioc
  | Fok
  | Post_only
  | Rpi
[@@deriving sexp, compare, equal, hash, enumerate, yojson]

val to_wire : t -> string
val of_wire : string -> t option

(** [Gtc], [Ioc] and [Post_only] (as [Alo]) have venue-neutral counterparts; [Fok] and
    [Rpi] do not. *)
val to_exchange_core : t -> Exchange_core.Tif.t option

val of_exchange_core : Exchange_core.Tif.t -> t

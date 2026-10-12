(** Instrument name, e.g. ["BTCUSDT"]: {!Exchange_core.Symbol}, a JSON string. *)

open! Core

include module type of struct
  include Exchange_core.Symbol
end

val yojson_of_t : t -> Yojson.Safe.t
val t_of_yojson : Yojson.Safe.t -> t

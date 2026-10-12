open! Core

(** Decodes [json], prints the sexp, re-encodes and prints the JSON, then re-decodes and
    reports any mismatch. *)
val round_trip : (module Bybit_protocol.Codec.S with type t = 'a) -> string -> unit

(** Same for a REST response: the envelope with [M] as its [result]. *)
val round_trip_envelope
  :  (module Bybit_protocol.Codec.S with type t = 'a)
  -> string
  -> unit

(** Milliseconds since the Unix epoch. Bybit sends these as JSON integers in some places
    ([time], [ts], [creationTime], [T]) and as decimal strings in others ([createdTime],
    [execTime], [nextFundingTime]). Both decoders accept either form; [t] encodes as an
    integer and {!As_string.t} as a string, so each field re-encodes as Bybit sends it. *)

open! Core

type t [@@deriving sexp, compare, equal, hash, yojson]

include Comparable.S with type t := t

val of_int_ms : int -> t
val to_int_ms : t -> int
val of_time_ns : Time_ns.t -> t
val to_time_ns : t -> Time_ns.t

module As_string : sig
  type nonrec t = t [@@deriving sexp, compare, equal, yojson]
end

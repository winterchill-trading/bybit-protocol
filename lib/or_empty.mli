(** Optional values that Bybit encodes as an empty string when absent, e.g.
    ["avgPrice": ""] on an unfilled order or ["liqPrice": ""] when out of range. [None]
    encodes as [""]. *)

open! Core

module type Value = sig
  type t [@@deriving sexp, compare, equal]

  val of_string : string -> t
  val to_string : t -> string
end

module type S = sig
  type value
  type t = value option [@@deriving sexp, compare, equal, yojson]
end

module Make (M : Value) : S with type value := M.t

(** Exchange-assigned order id ([orderId]). Bybit sends a string: a decimal number for
    some products (["1321003749386327552"]) and a UUID for others
    (["fd4300ae-7847-404e-b947-b46980a4d140"]), so this is not {!Exchange_core.Order_id}
    (an [int64]); see {!to_exchange_core}. *)

open! Core

type t [@@deriving sexp, compare, equal, hash, yojson]

include Comparable.S with type t := t
include Hashable.S with type t := t
include Stringable.S with type t := t

(** [Some] when the id is a decimal number that fits in an [int64]. *)
val to_exchange_core : t -> Exchange_core.Order_id.t option

val of_exchange_core : Exchange_core.Order_id.t -> t

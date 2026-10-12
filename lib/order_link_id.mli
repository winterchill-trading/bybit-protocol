(** Client order id ([orderLinkId]): {!Exchange_core.Client_order_id}, a JSON string.
    Bybit accepts at most 36 characters from [A-Za-z0-9_-]; {!create} checks that, while
    [of_string] and the decoder accept anything the server sends. *)

open! Core

include module type of struct
  include Exchange_core.Client_order_id
end

val yojson_of_t : t -> Yojson.Safe.t
val t_of_yojson : Yojson.Safe.t -> t
val create : string -> t Or_error.t

(** Responses send [""] when no client id was given. *)
module Or_empty : Or_empty.S with type value := t

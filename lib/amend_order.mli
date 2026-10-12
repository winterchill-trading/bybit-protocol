(** [POST /v5/order/amend]. Give [order_id] or [order_link_id]; omit fields that do not
    change. The [result] is an {!Order_ack.t}. *)

open! Core

module Request : sig
  type t =
    { category : Category.t
    ; symbol : Symbol.t
    ; order_id : Order_id.t option
    ; order_link_id : Order_link_id.t option
    ; qty : Size.t option
    ; price : Price.t option
    ; trigger_price : Price.t option
    }
  [@@deriving sexp, compare, equal, yojson]
end

module Response : sig
  type t = Order_ack.t [@@deriving sexp, compare, equal, yojson]
end

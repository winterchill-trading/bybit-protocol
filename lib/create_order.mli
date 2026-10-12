(** [POST /v5/order/create]. The [result] is an {!Order_ack.t}. Conditional and TP/SL
    parameters are not modelled. *)

open! Core

module Params : sig
  (** The order itself, shared with {!Create_batch}. *)
  type t =
    { symbol : Symbol.t
    ; side : Side.t
    ; order_type : Order_type.t
    ; qty : Size.t
    ; price : Price.t option (** required for [Limit] *)
    ; time_in_force : Time_in_force.t option (** default [GTC]; market orders are [IOC] *)
    ; reduce_only : bool option
    ; order_link_id : Order_link_id.t option
    ; position_idx : Position_idx.t option (** required in hedge mode *)
    }
  [@@deriving sexp, compare, equal, yojson]

  val limit
    :  ?time_in_force:Time_in_force.t
    -> ?reduce_only:bool
    -> ?order_link_id:Order_link_id.t
    -> ?position_idx:Position_idx.t
    -> Symbol.t
    -> side:Side.t
    -> qty:Size.t
    -> price:Price.t
    -> t

  val market
    :  ?reduce_only:bool
    -> ?order_link_id:Order_link_id.t
    -> ?position_idx:Position_idx.t
    -> Symbol.t
    -> side:Side.t
    -> qty:Size.t
    -> t
end

module Request : sig
  (** [{"category": "linear", ...Params}] *)
  type t =
    { category : Category.t
    ; params : Params.t
    }
  [@@deriving sexp, compare, equal, yojson]
end

module Response : sig
  type t = Order_ack.t [@@deriving sexp, compare, equal, yojson]
end

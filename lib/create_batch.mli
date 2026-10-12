(** [POST /v5/order/create-batch]: up to 20 orders for [linear]. Per-order success is in
    the envelope's [retExtInfo] ({!Ext_info}), not in the top-level [retCode]. (*
    UNVERIFIED: only a spot example was available; assumed the same shape for linear. *) *)

open! Core

module Request : sig
  (** [{"category": "linear", "request": [...]}] *)
  type t =
    { category : Category.t
    ; request : Create_order.Params.t list
    }
  [@@deriving sexp, compare, equal, yojson]
end

module Item : sig
  type t =
    { category : Category.t
    ; symbol : Symbol.t
    ; order_id : Order_id.t (** [""] for a rejected item *)
    ; order_link_id : Order_link_id.Or_empty.t
    ; create_at : Timestamp_ms.As_string.t option
    }
  [@@deriving sexp, compare, equal, yojson]
end

module Response : sig
  (** [{"list": [...]}] *)
  type t = { list : Item.t list } [@@deriving sexp, compare, equal, yojson]
end

module Ext_info : sig
  module Status : sig
    (** [{"code": 0, "msg": "OK"}]; [code] is a [retCode]. *)
    type t =
      { code : int
      ; msg : string
      }
    [@@deriving sexp, compare, equal, yojson]

    val error : t -> Envelope.Error.t option
  end

  (** [{"list": [...]}], in the order of the request. *)
  type t = { list : Status.t list } [@@deriving sexp, compare, equal, yojson]
end

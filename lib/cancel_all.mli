(** [POST /v5/order/cancel-all]. For [linear], one of [symbol], [base_coin] or
    [settle_coin] is required. *)

open! Core

module Request : sig
  type t =
    { category : Category.t
    ; symbol : Symbol.t option
    ; base_coin : string option
    ; settle_coin : string option
    ; order_filter : string option
    (** [Order], [StopOrder] or [OpenOrder]; omitted = all *)
    }
  [@@deriving sexp, compare, equal, yojson]
end

module Response : sig
  (** [{"list": [...], "success": "1"}]; [success] is ["1"] or ["0"]. *)
  type t =
    { list : Order_ack.t list
    ; success : bool
    }
  [@@deriving sexp, compare, equal, yojson]
end

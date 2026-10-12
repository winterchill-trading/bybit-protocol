(** An order as returned by [GET /v5/order/realtime] (open orders) and pushed on the
    private [order] websocket topic. Fields that may be [""] use [Or_empty]; [closedPnl]
    and [category] appear on the websocket topic only. *)

open! Core

type t =
  { order_id : Order_id.t
  ; order_link_id : Order_link_id.Or_empty.t
  ; symbol : Symbol.t
  ; side : Side.t
  ; order_type : Order_type.t
  ; price : Price.t
  ; qty : Size.t
  ; time_in_force : Time_in_force.t
  ; order_status : Order_status.t
  ; cum_exec_qty : Size.t
  ; cum_exec_value : Usd.t
  ; avg_price : Price.Or_empty.t (** [""] (or ["0"]) before the first fill *)
  ; leaves_qty : Size.Or_empty.t
  ; reduce_only : bool
  ; reject_reason : Reject_reason.t
  ; position_idx : Position_idx.t
  ; created_time : Timestamp_ms.As_string.t
  ; updated_time : Timestamp_ms.As_string.t
  ; category : Category.t option
  ; closed_pnl : Usd.t option
  }
[@@deriving sexp, compare, equal, yojson]

module Response : sig
  type nonrec t = t Page.t [@@deriving sexp, compare, equal, yojson]
end

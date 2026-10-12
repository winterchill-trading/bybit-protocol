(** A fill, as returned by [GET /v5/execution/list] and pushed on the private [execution]
    websocket topic. There is no [closedPnl] here; realised PnL is on the [order] topic
    ({!Realtime_order.closed_pnl}) and in {!Position.cum_realised_pnl}. *)

open! Core

type t =
  { exec_id : Exec_id.t
  ; order_id : Order_id.t
  ; order_link_id : Order_link_id.Or_empty.t
  ; symbol : Symbol.t
  ; side : Side.t
  ; exec_price : Price.t
  ; exec_qty : Size.t
  ; exec_value : Usd.t
  ; exec_fee : Usd.t
  ; fee_rate : Decimal.Or_empty.t
  ; exec_type : Exec_type.t
  ; is_maker : bool
  ; exec_time : Timestamp_ms.As_string.t
  ; closed_size : Size.Or_empty.t (** position size closed by this fill *)
  ; seq : int option
  ; category : Category.t option (** websocket only *)
  }
[@@deriving sexp, compare, equal, yojson]

module Response : sig
  type nonrec t = t Page.t [@@deriving sexp, compare, equal, yojson]
end

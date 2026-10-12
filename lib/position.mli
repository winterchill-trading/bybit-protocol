(** A position, as returned by [GET /v5/position/list] and pushed on the private
    [position] websocket topic. The REST endpoint calls the average entry price
    [avgPrice]; the websocket topic calls it [entryPrice]: use {!Ws} for the latter. *)

open! Core

type t =
  { position_idx : Position_idx.t
  ; symbol : Symbol.t
  ; side : Side.Or_empty.t (** [""] (no position) decodes to [None] *)
  ; size : Size.t (** always non-negative; direction is [side] *)
  ; avg_price : Price.t
  ; position_value : Usd.Or_empty.t
  ; unrealised_pnl : Usd.t
  ; cum_realised_pnl : Usd.t
  ; cur_realised_pnl : Usd.t option
  ; leverage : Decimal.Or_empty.t (** [""] under portfolio margin *)
  ; liq_price : Price.Or_empty.t (** [""] when out of range *)
  ; mark_price : Price.t
  ; position_status : string option (** [Normal], [Liq] or [Adl] *)
  ; created_time : Timestamp_ms.As_string.t
  ; updated_time : Timestamp_ms.As_string.t
  ; category : Category.t option
  ; seq : int option
  }
[@@deriving sexp, compare, equal, yojson]

(** Signed size: positive long, negative short, as {!Exchange_core} uses it. *)
val signed_size : t -> Size.t

(** The websocket encoding, with [entryPrice] in place of [avgPrice]. *)
module Ws : sig
  type nonrec t = t [@@deriving sexp, compare, equal, yojson]
end

module Response : sig
  type nonrec t = t Page.t [@@deriving sexp, compare, equal, yojson]
end

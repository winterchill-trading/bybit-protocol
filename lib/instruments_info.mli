(** [GET /v5/market/instruments-info?category=linear]: instrument trading rules. The
    [result] is an {!Instrument.t} {!Page.t}. *)

open! Core

module Leverage_filter : sig
  type t =
    { min_leverage : Decimal.t
    ; max_leverage : Decimal.t
    ; leverage_step : Decimal.t
    }
  [@@deriving sexp, compare, equal, yojson]
end

module Price_filter : sig
  type t =
    { min_price : Price.t
    ; max_price : Price.t
    ; tick_size : Price.t
    }
  [@@deriving sexp, compare, equal, yojson]
end

module Lot_size_filter : sig
  type t =
    { max_order_qty : Size.t (** limit and post-only maximum *)
    ; min_order_qty : Size.t
    ; qty_step : Size.t
    ; max_mkt_order_qty : Size.t option
    ; min_notional_value : Usd.t option
    }
  [@@deriving sexp, compare, equal, yojson]
end

module Instrument : sig
  type t =
    { symbol : Symbol.t
    ; contract_type : string (** e.g. ["LinearPerpetual"] *)
    ; status : string (** e.g. ["Trading"] *)
    ; base_coin : string
    ; quote_coin : string
    ; leverage_filter : Leverage_filter.t
    ; price_filter : Price_filter.t
    ; lot_size_filter : Lot_size_filter.t
    }
  [@@deriving sexp, compare, equal, yojson]

  (** Size decimals come from the number of fractional digits of [qtyStep] (exact when the
      step is a power of ten); max leverage is rounded down. *)
  val to_exchange_core : t -> Exchange_core.Instrument.t
end

type t = Instrument.t Page.t [@@deriving sexp, compare, equal, yojson]

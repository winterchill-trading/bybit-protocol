(** [GET /v5/market/tickers?category=linear]: a {!Ticker.t} {!Page.t} (no
    [nextPageCursor]). *)

open! Core

module Ticker : sig
  type t =
    { symbol : Symbol.t
    ; last_price : Price.t
    ; mark_price : Price.t
    ; index_price : Price.t
    ; bid1_price : Price.Or_empty.t (** [""] when the side is empty *)
    ; bid1_size : Size.Or_empty.t
    ; ask1_price : Price.Or_empty.t
    ; ask1_size : Size.Or_empty.t
    ; funding_rate : Decimal.Or_empty.t
    ; next_funding_time : Timestamp_ms.As_string.t
    ; open_interest : Size.t option
    ; volume24h : Size.t option
    ; turnover24h : Usd.t option
    ; price24h_pcnt : Decimal.t option
    }
  [@@deriving sexp, compare, equal, yojson]
end

type t = Ticker.t Page.t [@@deriving sexp, compare, equal, yojson]

(** [tickers.<symbol>] pushes (every 100 ms for derivatives):
    [{"topic", "type": "snapshot" | "delta", "data": {...}, "cs", "ts"}]. In a delta, a
    missing field has not changed: keep the previous value ({!Data.apply}). (* UNVERIFIED:
    no delta example was available; assumed [symbol] is always present and every other
    field may be absent. *) *)

open! Core

module Data : sig
  type t =
    { symbol : Symbol.t
    ; last_price : Price.t option
    ; mark_price : Price.t option
    ; index_price : Price.t option
    ; bid1_price : Price.t option
    ; bid1_size : Size.t option
    ; ask1_price : Price.t option
    ; ask1_size : Size.t option
    ; funding_rate : Decimal.t option
    ; next_funding_time : Timestamp_ms.As_string.t option
    ; open_interest : Size.t option
    ; volume24h : Size.t option
    ; turnover24h : Usd.t option
    ; price24h_pcnt : Decimal.t option
    }
  [@@deriving sexp, compare, equal, yojson]

  (** [apply t ~delta] takes each field from [delta] when present, else from [t]. *)
  val apply : t -> delta:t -> t
end

type t =
  { topic : Topic.t
  ; type_ : Update_type.t
  ; data : Data.t
  ; cs : int option (** cross sequence *)
  ; ts : Timestamp_ms.t
  }
[@@deriving sexp, compare, equal, yojson]

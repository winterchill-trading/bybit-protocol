open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Ticker = struct
  type t =
    { symbol : Symbol.t
    ; last_price : Price.t [@key "lastPrice"]
    ; mark_price : Price.t [@key "markPrice"]
    ; index_price : Price.t [@key "indexPrice"]
    ; bid1_price : Price.Or_empty.t [@key "bid1Price"]
    ; bid1_size : Size.Or_empty.t [@key "bid1Size"]
    ; ask1_price : Price.Or_empty.t [@key "ask1Price"]
    ; ask1_size : Size.Or_empty.t [@key "ask1Size"]
    ; funding_rate : Decimal.Or_empty.t [@key "fundingRate"]
    ; next_funding_time : Timestamp_ms.As_string.t [@key "nextFundingTime"]
    ; open_interest : Size.t option
         [@key "openInterest"] [@default None] [@yojson_drop_if Option.is_none]
    ; volume24h : Size.t option [@default None] [@yojson_drop_if Option.is_none]
    ; turnover24h : Usd.t option [@default None] [@yojson_drop_if Option.is_none]
    ; price24h_pcnt : Decimal.t option
         [@key "price24hPcnt"] [@default None] [@yojson_drop_if Option.is_none]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

type t = Ticker.t Page.t [@@deriving sexp, compare, equal, yojson]

open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Data = struct
  type t =
    { symbol : Symbol.t
    ; last_price : Price.t option
         [@key "lastPrice"] [@default None] [@yojson_drop_if Option.is_none]
    ; mark_price : Price.t option
         [@key "markPrice"] [@default None] [@yojson_drop_if Option.is_none]
    ; index_price : Price.t option
         [@key "indexPrice"] [@default None] [@yojson_drop_if Option.is_none]
    ; bid1_price : Price.t option
         [@key "bid1Price"] [@default None] [@yojson_drop_if Option.is_none]
    ; bid1_size : Size.t option
         [@key "bid1Size"] [@default None] [@yojson_drop_if Option.is_none]
    ; ask1_price : Price.t option
         [@key "ask1Price"] [@default None] [@yojson_drop_if Option.is_none]
    ; ask1_size : Size.t option
         [@key "ask1Size"] [@default None] [@yojson_drop_if Option.is_none]
    ; funding_rate : Decimal.t option
         [@key "fundingRate"] [@default None] [@yojson_drop_if Option.is_none]
    ; next_funding_time : Timestamp_ms.As_string.t option
         [@key "nextFundingTime"] [@default None] [@yojson_drop_if Option.is_none]
    ; open_interest : Size.t option
         [@key "openInterest"] [@default None] [@yojson_drop_if Option.is_none]
    ; volume24h : Size.t option [@default None] [@yojson_drop_if Option.is_none]
    ; turnover24h : Usd.t option [@default None] [@yojson_drop_if Option.is_none]
    ; price24h_pcnt : Decimal.t option
         [@key "price24hPcnt"] [@default None] [@yojson_drop_if Option.is_none]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

  let apply t ~delta =
    let ( <|> ) d prev = Option.first_some d prev in
    { symbol = delta.symbol
    ; last_price = delta.last_price <|> t.last_price
    ; mark_price = delta.mark_price <|> t.mark_price
    ; index_price = delta.index_price <|> t.index_price
    ; bid1_price = delta.bid1_price <|> t.bid1_price
    ; bid1_size = delta.bid1_size <|> t.bid1_size
    ; ask1_price = delta.ask1_price <|> t.ask1_price
    ; ask1_size = delta.ask1_size <|> t.ask1_size
    ; funding_rate = delta.funding_rate <|> t.funding_rate
    ; next_funding_time = delta.next_funding_time <|> t.next_funding_time
    ; open_interest = delta.open_interest <|> t.open_interest
    ; volume24h = delta.volume24h <|> t.volume24h
    ; turnover24h = delta.turnover24h <|> t.turnover24h
    ; price24h_pcnt = delta.price24h_pcnt <|> t.price24h_pcnt
    }
  ;;
end

type t =
  { topic : Topic.t
  ; type_ : Update_type.t [@key "type"]
  ; data : Data.t
  ; cs : int option [@default None] [@yojson_drop_if Option.is_none]
  ; ts : Timestamp_ms.t
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

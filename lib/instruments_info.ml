open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Leverage_filter = struct
  type t =
    { min_leverage : Decimal.t [@key "minLeverage"]
    ; max_leverage : Decimal.t [@key "maxLeverage"]
    ; leverage_step : Decimal.t [@key "leverageStep"]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

module Price_filter = struct
  type t =
    { min_price : Price.t [@key "minPrice"]
    ; max_price : Price.t [@key "maxPrice"]
    ; tick_size : Price.t [@key "tickSize"]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

module Lot_size_filter = struct
  type t =
    { max_order_qty : Size.t [@key "maxOrderQty"]
    ; min_order_qty : Size.t [@key "minOrderQty"]
    ; qty_step : Size.t [@key "qtyStep"]
    ; max_mkt_order_qty : Size.t option
         [@key "maxMktOrderQty"] [@default None] [@yojson_drop_if Option.is_none]
    ; min_notional_value : Usd.t option
         [@key "minNotionalValue"] [@default None] [@yojson_drop_if Option.is_none]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

module Instrument = struct
  type t =
    { symbol : Symbol.t
    ; contract_type : string [@key "contractType"]
    ; status : string
    ; base_coin : string [@key "baseCoin"]
    ; quote_coin : string [@key "quoteCoin"]
    ; leverage_filter : Leverage_filter.t [@key "leverageFilter"]
    ; price_filter : Price_filter.t [@key "priceFilter"]
    ; lot_size_filter : Lot_size_filter.t [@key "lotSizeFilter"]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

  let to_exchange_core t =
    let size_decimals =
      match String.lsplit2 (Size.to_string t.lot_size_filter.qty_step) ~on:'.' with
      | None -> 0
      | Some (_, frac) -> String.length frac
    in
    let max_leverage =
      Decimal.to_units t.leverage_filter.max_leverage / Decimal.units_per_one
    in
    Exchange_core.Instrument.create
      t.symbol
      ~size_decimals
      ~price_tick:t.price_filter.tick_size
      ~max_leverage
  ;;
end

type t = Instrument.t Page.t [@@deriving sexp, compare, equal, yojson]

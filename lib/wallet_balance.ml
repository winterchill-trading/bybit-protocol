open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Coin = struct
  type t =
    { coin : string
    ; wallet_balance : Usd.t [@key "walletBalance"]
    ; equity : Usd.t
    ; unrealised_pnl : Usd.t option
         [@key "unrealisedPnl"] [@default None] [@yojson_drop_if Option.is_none]
    ; cum_realised_pnl : Usd.t option
         [@key "cumRealisedPnl"] [@default None] [@yojson_drop_if Option.is_none]
    ; usd_value : Usd.t option
         [@key "usdValue"] [@default None] [@yojson_drop_if Option.is_none]
    ; locked : Usd.t option [@default None] [@yojson_drop_if Option.is_none]
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

module Account = struct
  type t =
    { account_type : string [@key "accountType"]
    ; total_equity : Usd.t [@key "totalEquity"]
    ; total_wallet_balance : Usd.t [@key "totalWalletBalance"]
    ; total_margin_balance : Usd.t [@key "totalMarginBalance"]
    ; total_available_balance : Usd.t [@key "totalAvailableBalance"]
    ; total_perp_upl : Usd.t option
         [@key "totalPerpUPL"] [@default None] [@yojson_drop_if Option.is_none]
    ; total_initial_margin : Usd.t option
         [@key "totalInitialMargin"] [@default None] [@yojson_drop_if Option.is_none]
    ; total_maintenance_margin : Usd.t option
         [@key "totalMaintenanceMargin"] [@default None] [@yojson_drop_if Option.is_none]
    ; coin : Coin.t list
    }
  [@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]
end

type t = { list : Account.t list }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

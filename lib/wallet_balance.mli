(** [GET /v5/account/wallet-balance?accountType=UNIFIED] and the private [wallet]
    websocket topic. Account-level amounts are in USD; coin-level amounts are in units of
    the coin (USDT for USDT perpetuals), typed as {!Usd.t}. *)

open! Core

module Coin : sig
  type t =
    { coin : string
    ; wallet_balance : Usd.t
    ; equity : Usd.t
    ; unrealised_pnl : Usd.t option
    ; cum_realised_pnl : Usd.t option
    ; usd_value : Usd.t option
    ; locked : Usd.t option
    }
  [@@deriving sexp, compare, equal, yojson]
end

module Account : sig
  type t =
    { account_type : string (** ["UNIFIED"] *)
    ; total_equity : Usd.t
    ; total_wallet_balance : Usd.t
    ; total_margin_balance : Usd.t
    ; total_available_balance : Usd.t
    ; total_perp_upl : Usd.t option
    ; total_initial_margin : Usd.t option
    ; total_maintenance_margin : Usd.t option
    ; coin : Coin.t list
    }
  [@@deriving sexp, compare, equal, yojson]
end

(** The REST [result]: [{"list": [...]}]. *)
type t = { list : Account.t list } [@@deriving sexp, compare, equal, yojson]

(** Quote-currency (USDT) amounts: values, fees, PnL and balances. Re-exported from
    {!Exchange_core.Usd}; encoded as decimal strings (["65557.7"]). *)

open! Core

include module type of struct
  include Exchange_core.Usd
end

(** [""] decodes to [None]. *)
module Or_empty : Or_empty.S with type value := t

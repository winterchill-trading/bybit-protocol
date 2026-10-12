(** Prices (limit, mark, index, entry and liquidation prices). Re-exported from
    {!Exchange_core.Price}; encoded as decimal strings (["65557.7"]). *)

open! Core

include module type of struct
  include Exchange_core.Price
end

(** [""] decodes to [None]. *)
module Or_empty : Or_empty.S with type value := t

(** Quantities in base-asset units (order qty, position size, book sizes). Re-exported
    from {!Exchange_core.Size}; encoded as decimal strings (["65557.7"]). *)

open! Core

include module type of struct
  include Exchange_core.Size
end

(** [""] decodes to [None]. *)
module Or_empty : Or_empty.S with type value := t

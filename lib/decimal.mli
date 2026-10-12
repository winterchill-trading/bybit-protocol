(** Dimensionless decimals (leverage, funding and fee rates, percentages), encoded as
    decimal strings. A distinct {!Fixed_decimal} instance, so it never unifies with
    {!Price}, {!Size} or {!Usd}. *)

open! Core
include Fixed_decimal.S

(** [""] decodes to [None]. *)
module Or_empty : Or_empty.S with type value := t

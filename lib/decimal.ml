open! Core
module T = Fixed_decimal.Make ()
include T
module Or_empty = Or_empty.Make (T)

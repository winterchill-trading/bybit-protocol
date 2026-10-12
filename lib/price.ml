open! Core
include Exchange_core.Price
module Or_empty = Or_empty.Make (Exchange_core.Price)

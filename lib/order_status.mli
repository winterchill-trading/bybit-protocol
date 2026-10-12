(** Order status. Open: [New], [PartiallyFilled], [Untriggered]. Closed: [Rejected],
    [PartiallyFilledCanceled] (spot only), [Filled], [Cancelled], [Deactivated].
    [Triggered] is transient. *)

open! Core

type t =
  | New
  | Partially_filled
  | Untriggered
  | Rejected
  | Partially_filled_canceled
  | Filled
  | Cancelled
  | Triggered
  | Deactivated
[@@deriving sexp, compare, equal, hash, enumerate, yojson]

val to_wire : t -> string
val of_wire : string -> t option

(** [true] for [New], [Partially_filled], [Untriggered] and [Triggered]. *)
val is_open : t -> bool

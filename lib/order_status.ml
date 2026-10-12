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
[@@deriving sexp, compare, equal, hash, enumerate]

let to_wire = function
  | New -> "New"
  | Partially_filled -> "PartiallyFilled"
  | Untriggered -> "Untriggered"
  | Rejected -> "Rejected"
  | Partially_filled_canceled -> "PartiallyFilledCanceled"
  | Filled -> "Filled"
  | Cancelled -> "Cancelled"
  | Triggered -> "Triggered"
  | Deactivated -> "Deactivated"
;;

let of_wire = function
  | "New" -> Some New
  | "PartiallyFilled" -> Some Partially_filled
  | "Untriggered" -> Some Untriggered
  | "Rejected" -> Some Rejected
  | "PartiallyFilledCanceled" -> Some Partially_filled_canceled
  | "Filled" -> Some Filled
  | "Cancelled" -> Some Cancelled
  | "Triggered" -> Some Triggered
  | "Deactivated" -> Some Deactivated
  | _ -> None
;;

let yojson_of_t t : Yojson.Safe.t = `String (to_wire t)

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `String s ->
    (match of_wire s with
     | Some t -> t
     | None -> Json.error "order_status: unknown value" json)
  | _ -> Json.error "order_status: string expected" json
;;

let is_open = function
  | New | Partially_filled | Untriggered | Triggered -> true
  | Rejected | Partially_filled_canceled | Filled | Cancelled | Deactivated -> false
;;

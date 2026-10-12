open! Core

type t =
  | Limit
  | Market
  | Unknown
[@@deriving sexp, compare, equal, hash, enumerate]

let to_wire = function
  | Limit -> "Limit"
  | Market -> "Market"
  | Unknown -> "UNKNOWN"
;;

let of_wire = function
  | "Limit" -> Some Limit
  | "Market" -> Some Market
  | "UNKNOWN" -> Some Unknown
  | _ -> None
;;

let yojson_of_t t : Yojson.Safe.t = `String (to_wire t)

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `String s ->
    (match of_wire s with
     | Some t -> t
     | None -> Json.error "order_type: unknown value" json)
  | _ -> Json.error "order_type: string expected" json
;;

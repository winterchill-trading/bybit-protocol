open! Core

type t =
  | One_way
  | Hedge_buy
  | Hedge_sell
[@@deriving sexp, compare, equal, hash, enumerate]

let to_int = function
  | One_way -> 0
  | Hedge_buy -> 1
  | Hedge_sell -> 2
;;

let of_int = function
  | 0 -> Some One_way
  | 1 -> Some Hedge_buy
  | 2 -> Some Hedge_sell
  | _ -> None
;;

let yojson_of_t t : Yojson.Safe.t = `Int (to_int t)

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `Int i ->
    (match of_int i with
     | Some t -> t
     | None -> Json.error "positionIdx: 0, 1 or 2 expected" json)
  | _ -> Json.error "positionIdx: integer expected" json
;;

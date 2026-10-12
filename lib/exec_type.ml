open! Core

type t =
  | Trade
  | Adl_trade
  | Funding
  | Bust_trade
  | Delivery
  | Settle
  | Block_trade
  | Move_position
  | Unknown
  | Other of string
[@@deriving sexp, compare, equal, hash]

let to_wire = function
  | Trade -> "Trade"
  | Adl_trade -> "AdlTrade"
  | Funding -> "Funding"
  | Bust_trade -> "BustTrade"
  | Delivery -> "Delivery"
  | Settle -> "Settle"
  | Block_trade -> "BlockTrade"
  | Move_position -> "MovePosition"
  | Unknown -> "UNKNOWN"
  | Other s -> s
;;

let of_wire = function
  | "Trade" -> Some Trade
  | "AdlTrade" -> Some Adl_trade
  | "Funding" -> Some Funding
  | "BustTrade" -> Some Bust_trade
  | "Delivery" -> Some Delivery
  | "Settle" -> Some Settle
  | "BlockTrade" -> Some Block_trade
  | "MovePosition" -> Some Move_position
  | "UNKNOWN" -> Some Unknown
  | s -> Some (Other s)
;;

let yojson_of_t t : Yojson.Safe.t = `String (to_wire t)

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `String s ->
    (match of_wire s with
     | Some t -> t
     | None -> Json.error "exec_type: unknown value" json)
  | _ -> Json.error "exec_type: string expected" json
;;

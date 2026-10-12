open! Core
include Exchange_core.Side

let to_wire = function
  | Buy -> "Buy"
  | Sell -> "Sell"
;;

let of_wire = function
  | "Buy" -> Some Buy
  | "Sell" -> Some Sell
  | _ -> None
;;

let yojson_of_t t : Yojson.Safe.t = `String (to_wire t)

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `String s ->
    (match of_wire s with
     | Some t -> t
     | None -> Json.error "side: unknown value" json)
  | _ -> Json.error "side: string expected" json
;;

module Or_empty = Or_empty.Make (struct
    include Exchange_core.Side

    let to_string = to_wire

    let of_string s =
      match of_wire s with
      | Some t -> t
      | None -> Json.error "side: unknown value" (`String s)
    ;;
  end)

open! Core

type t =
  | Linear
  | Inverse
  | Spot
  | Option
[@@deriving sexp, compare, equal, hash, enumerate]

let to_wire = function
  | Linear -> "linear"
  | Inverse -> "inverse"
  | Spot -> "spot"
  | Option -> "option"
;;

let of_wire = function
  | "linear" -> Some Linear
  | "inverse" -> Some Inverse
  | "spot" -> Some Spot
  | "option" -> Some Option
  | _ -> None
;;

let yojson_of_t t : Yojson.Safe.t = `String (to_wire t)

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `String s ->
    (match of_wire s with
     | Some t -> t
     | None -> Json.error "category: unknown value" json)
  | _ -> Json.error "category: string expected" json
;;

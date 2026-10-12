open! Core

type t =
  | Gtc
  | Ioc
  | Fok
  | Post_only
  | Rpi
[@@deriving sexp, compare, equal, hash, enumerate]

let to_wire = function
  | Gtc -> "GTC"
  | Ioc -> "IOC"
  | Fok -> "FOK"
  | Post_only -> "PostOnly"
  | Rpi -> "RPI"
;;

let of_wire = function
  | "GTC" -> Some Gtc
  | "IOC" -> Some Ioc
  | "FOK" -> Some Fok
  | "PostOnly" -> Some Post_only
  | "RPI" -> Some Rpi
  | _ -> None
;;

let yojson_of_t t : Yojson.Safe.t = `String (to_wire t)

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `String s ->
    (match of_wire s with
     | Some t -> t
     | None -> Json.error "time_in_force: unknown value" json)
  | _ -> Json.error "time_in_force: string expected" json
;;

let to_exchange_core : t -> Exchange_core.Tif.t option = function
  | Gtc -> Some Gtc
  | Ioc -> Some Ioc
  | Post_only -> Some Alo
  | Fok | Rpi -> None
;;

let of_exchange_core : Exchange_core.Tif.t -> t = function
  | Gtc -> Gtc
  | Ioc -> Ioc
  | Alo -> Post_only
;;

open! Core

type t =
  { price : Price.t
  ; size : Size.t
  }
[@@deriving sexp, compare, equal]

let yojson_of_t { price; size } : Yojson.Safe.t =
  `List [ Price.yojson_of_t price; Size.yojson_of_t size ]
;;

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `List [ price; size ] ->
    { price = Price.t_of_yojson price; size = Size.t_of_yojson size }
  | _ -> Json.error "book level: [price, size] expected" json
;;

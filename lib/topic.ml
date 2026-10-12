open! Core

type t =
  | Orderbook of
      { depth : int
      ; symbol : Symbol.t
      }
  | Public_trade of Symbol.t
  | Tickers of Symbol.t
  | Order of Category.t option
  | Execution of Category.t option
  | Position of Category.t option
  | Wallet
  | Other of string
[@@deriving sexp, compare, equal]

let with_category name = function
  | None -> name
  | Some category -> name ^ "." ^ Category.to_wire category
;;

let to_string = function
  | Orderbook { depth; symbol } ->
    sprintf "orderbook.%d.%s" depth (Symbol.to_string symbol)
  | Public_trade symbol -> "publicTrade." ^ Symbol.to_string symbol
  | Tickers symbol -> "tickers." ^ Symbol.to_string symbol
  | Order category -> with_category "order" category
  | Execution category -> with_category "execution" category
  | Position category -> with_category "position" category
  | Wallet -> "wallet"
  | Other s -> s
;;

let of_string s =
  let private_ make category =
    match category with
    | None -> make None
    | Some c ->
      (match Category.of_wire c with
       | Some c -> make (Some c)
       | None -> Other s)
  in
  match String.split s ~on:'.' with
  | [ "orderbook"; depth; symbol ] ->
    (match Int.of_string_opt depth with
     | Some depth -> Orderbook { depth; symbol = Symbol.of_string symbol }
     | None -> Other s)
  | [ "publicTrade"; symbol ] -> Public_trade (Symbol.of_string symbol)
  | [ "tickers"; symbol ] -> Tickers (Symbol.of_string symbol)
  | [ "order" ] -> Order None
  | [ "order"; c ] -> private_ (fun c -> Order c) (Some c)
  | [ "execution" ] -> Execution None
  | [ "execution"; c ] -> private_ (fun c -> Execution c) (Some c)
  | [ "position" ] -> Position None
  | [ "position"; c ] -> private_ (fun c -> Position c) (Some c)
  | [ "wallet" ] -> Wallet
  | _ -> Other s
;;

let yojson_of_t t : Yojson.Safe.t = `String (to_string t)

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `String s -> of_string s
  | _ -> Json.error "topic: string expected" json
;;

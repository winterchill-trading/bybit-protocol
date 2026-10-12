open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

module Error = struct
  type t =
    | Request_parameter_error
    | Request_time_out_of_window
    | Invalid_api_key
    | Invalid_signature
    | Permission_denied
    | Rate_limited
    | Server_error
    | Order_not_exists
    | Price_out_of_range
    | Wallet_balance_insufficient
    | Available_balance_insufficient
    | Qty_truncated_to_zero
    | Position_mode_not_modified
    | Leverage_not_modified
    | Duplicate_order_link_id
    | Order_processing
    | Spot_order_not_exists
    | Other of int
  [@@deriving sexp, compare, equal, hash]

  let to_code = function
    | Request_parameter_error -> 10001
    | Request_time_out_of_window -> 10002
    | Invalid_api_key -> 10003
    | Invalid_signature -> 10004
    | Permission_denied -> 10005
    | Rate_limited -> 10006
    | Server_error -> 10016
    | Order_not_exists -> 110001
    | Price_out_of_range -> 110003
    | Wallet_balance_insufficient -> 110004
    | Available_balance_insufficient -> 110007
    | Qty_truncated_to_zero -> 110017
    | Position_mode_not_modified -> 110025
    | Leverage_not_modified -> 110043
    | Duplicate_order_link_id -> 110072
    | Order_processing -> 110079
    | Spot_order_not_exists -> 170213
    | Other code -> code
  ;;

  let of_code = function
    | 0 -> None
    | 10001 -> Some Request_parameter_error
    | 10002 -> Some Request_time_out_of_window
    | 10003 -> Some Invalid_api_key
    | 10004 -> Some Invalid_signature
    | 10005 -> Some Permission_denied
    | 10006 -> Some Rate_limited
    | 10016 -> Some Server_error
    | 110001 -> Some Order_not_exists
    | 110003 -> Some Price_out_of_range
    | 110004 -> Some Wallet_balance_insufficient
    | 110007 -> Some Available_balance_insufficient
    | 110017 -> Some Qty_truncated_to_zero
    | 110025 -> Some Position_mode_not_modified
    | 110043 -> Some Leverage_not_modified
    | 110072 -> Some Duplicate_order_link_id
    | 110079 -> Some Order_processing
    | 170213 -> Some Spot_order_not_exists
    | code -> Some (Other code)
  ;;

  let yojson_of_t t : Yojson.Safe.t = `Int (to_code t)

  let t_of_yojson (json : Yojson.Safe.t) =
    match json with
    | `Int code ->
      (match of_code code with
       | Some t -> t
       | None -> Json.error "retCode 0 is not an error" json)
    | _ -> Json.error "retCode: integer expected" json
  ;;
end

type 'a t =
  { ret_code : int [@key "retCode"]
  ; ret_msg : string [@key "retMsg"]
  ; result : 'a
  ; ret_ext_info : Json.t [@key "retExtInfo"] [@default `Assoc []]
  ; time : Timestamp_ms.t
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

type error =
  { error : Error.t
  ; ret_msg : string
  }
[@@deriving sexp, compare, equal]

let decode json ~result_of_yojson =
  let ret_code =
    match Json.member_exn json ~key:"retCode" with
    | `Int code -> code
    | other -> Json.error "retCode: integer expected" other
  in
  match Error.of_code ret_code with
  | None -> Ok (t_of_yojson result_of_yojson json).result
  | Some error ->
    let ret_msg =
      match Json.member json ~key:"retMsg" with
      | Some (`String s) -> s
      | _ -> ""
    in
    Error { error; ret_msg }
;;

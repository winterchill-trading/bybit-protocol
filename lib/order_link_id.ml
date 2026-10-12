open! Core
include Exchange_core.Client_order_id

let yojson_of_t t : Yojson.Safe.t = `String (to_string t)

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `String s -> of_string s
  | _ -> Json.error "orderLinkId: string expected" json
;;

let create s =
  let valid_char c = Char.is_alphanum c || Char.equal c '-' || Char.equal c '_' in
  if String.is_empty s || Int.(String.length s > 36)
  then Or_error.error_s [%message "orderLinkId must be 1 to 36 characters" s]
  else if not (String.for_all s ~f:valid_char)
  then Or_error.error_s [%message "orderLinkId may only use A-Za-z0-9_-" s]
  else Ok (of_string s)
;;

module Or_empty = Or_empty.Make (Exchange_core.Client_order_id)

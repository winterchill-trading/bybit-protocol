open! Core

module T = struct
  type t = string [@@deriving sexp, compare, equal, hash]

  let of_string = Fn.id
  let to_string = Fn.id
end

include T
include Comparable.Make (T)
include Hashable.Make (T)

let yojson_of_t t : Yojson.Safe.t = `String t

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `String s -> s
  | _ -> Json.error "orderId: string expected" json
;;

let to_exchange_core t =
  if (not (String.is_empty t)) && String.for_all t ~f:Char.is_digit
  then Option.try_with (fun () -> Exchange_core.Order_id.of_int64 (Int64.of_string t))
  else None
;;

let of_exchange_core id = Exchange_core.Order_id.to_string id

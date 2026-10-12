open! Core

module T = struct
  type t = int [@@deriving sexp, compare, equal, hash]
end

include T
include Comparable.Make (T)

let of_int_ms = Fn.id
let to_int_ms = Fn.id
let of_time_ns t = Time_ns.to_int_ns_since_epoch t / 1_000_000
let to_time_ns t = Time_ns.of_int_ns_since_epoch (t * 1_000_000)

let t_of_yojson json =
  match Int.of_string_opt (Json.string_or_int json) with
  | Some t -> t
  | None -> Json.error "timestamp: integer milliseconds expected" json
;;

let yojson_of_t t : Yojson.Safe.t = `Int t

module As_string = struct
  type nonrec t = t [@@deriving sexp, compare, equal]

  let t_of_yojson = t_of_yojson
  let yojson_of_t t : Yojson.Safe.t = `String (Int.to_string t)
end

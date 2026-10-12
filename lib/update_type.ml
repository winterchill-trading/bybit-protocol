open! Core

type t =
  | Snapshot
  | Delta
[@@deriving sexp, compare, equal, hash, enumerate]

let to_wire = function
  | Snapshot -> "snapshot"
  | Delta -> "delta"
;;

let of_wire = function
  | "snapshot" -> Some Snapshot
  | "delta" -> Some Delta
  | _ -> None
;;

let yojson_of_t t : Yojson.Safe.t = `String (to_wire t)

let t_of_yojson (json : Yojson.Safe.t) =
  match json with
  | `String s ->
    (match of_wire s with
     | Some t -> t
     | None -> Json.error "update_type: unknown value" json)
  | _ -> Json.error "update_type: string expected" json
;;

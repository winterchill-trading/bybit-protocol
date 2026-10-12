open! Core

module type Value = sig
  type t [@@deriving sexp, compare, equal]

  val of_string : string -> t
  val to_string : t -> string
end

module type S = sig
  type value
  type t = value option [@@deriving sexp, compare, equal, yojson]
end

module Make (M : Value) = struct
  type t = M.t option [@@deriving sexp, compare, equal]

  let yojson_of_t : t -> Yojson.Safe.t = function
    | None -> `String ""
    | Some v -> `String (M.to_string v)
  ;;

  let t_of_yojson (json : Yojson.Safe.t) : t =
    match json with
    | `String "" | `Null -> None
    | `String s -> Some (M.of_string s)
    | _ -> Json.error "string expected" json
  ;;
end

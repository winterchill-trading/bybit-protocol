open! Core
open Bybit_protocol

let round_trip (type a) (module M : Codec.S with type t = a) s =
  let decoded = M.t_of_yojson (Yojson.Safe.from_string s) in
  print_s (M.sexp_of_t decoded);
  let encoded = Yojson.Safe.to_string (M.yojson_of_t decoded) in
  print_endline encoded;
  let decoded' = M.t_of_yojson (Yojson.Safe.from_string encoded) in
  if not (M.equal decoded decoded')
  then print_s [%message "round trip mismatch" ~_:(M.sexp_of_t decoded' : Sexp.t)]
;;

let round_trip_envelope (type a) (module M : Codec.S with type t = a) s =
  round_trip
    (module struct
      type t = M.t Envelope.t [@@deriving sexp, equal]

      let t_of_yojson = Envelope.t_of_yojson M.t_of_yojson
      let yojson_of_t = Envelope.yojson_of_t M.yojson_of_t
    end)
    s
;;

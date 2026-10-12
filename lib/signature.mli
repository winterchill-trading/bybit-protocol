(** Request signing (HMAC-SHA256, lowercase hex). Pure: callers supply the clock.

    REST: [sign] over [timestamp ^ api_key ^ recv_window ^ payload], where [payload] is
    the query string for GET (exactly as sent) and the JSON body for POST (the exact bytes
    sent: serialise once, sign that string, send the same string). Sent in [X-BAPI-SIGN].
    (* UNVERIFIED: whether the GET query string is signed before or after
    percent-encoding; this signs whatever string the caller passes. *) *)

open! Core

(** [sign ~secret ~timestamp ~api_key ~recv_window ~payload]. [timestamp] is the
    [X-BAPI-TIMESTAMP] value in ms; [recv_window] the [X-BAPI-RECV-WINDOW] value (Bybit's
    default is 5000; it must be in the signed string even when the default is used). *)
val sign
  :  secret:string
  -> timestamp:int
  -> api_key:string
  -> recv_window:int
  -> payload:string
  -> string

(** The [X-BAPI-*] headers for a signed request. *)
val headers
  :  secret:string
  -> timestamp:int
  -> api_key:string
  -> recv_window:int
  -> payload:string
  -> (string * string) list

(** Websocket auth signature: HMAC of ["GET/realtime" ^ expires], [expires] in ms and in
    the future. *)
val ws_auth : secret:string -> expires:int -> string

(** [hmac_sha256_hex ~key msg], exposed for tests. *)
val hmac_sha256_hex : key:string -> string -> string

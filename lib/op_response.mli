(** Server replies to an [op]: subscribe/unsubscribe/auth acks and pongs.
    - subscribe ack:
      [{"success": true, "ret_msg": "", "op": "subscribe", "conn_id": "..."}]
    - public pong:
      [{"success": true, "ret_msg": "pong", "conn_id": "...", "req_id": "", "op": "ping"}]
    - private pong:
      [{"req_id": "test", "op": "pong", "args": ["1675418560633"], "conn_id": "..."}] (*
      UNVERIFIED: the auth ack and failure replies were not documented; assumed this same
      shape with [success = false] and the reason in [ret_msg]. *) *)

open! Core

type t =
  { success : bool option (** absent on private pongs *)
  ; ret_msg : string option
  ; conn_id : string option
  ; req_id : string option
  ; op : string
  ; args : string list option
  }
[@@deriving sexp, compare, equal, yojson]

(** [success] is [Some false]. *)
val is_failure : t -> bool

(** Client-to-server websocket messages, all [{"req_id"?, "op", "args"?}]:
    - subscribe: [{"op": "subscribe", "args": ["orderbook.50.BTCUSDT", ...]}]
    - unsubscribe: same with ["unsubscribe"]
    - ping: [{"op": "ping"}], recommended every 20 seconds
    - auth (private stream, first message):
      [{"op": "auth", "args": [api_key, expires, signature]}] *)

open! Core

type t =
  | Subscribe of
      { req_id : string option
      ; args : Topic.t list
      }
  | Unsubscribe of
      { req_id : string option
      ; args : Topic.t list
      }
  | Ping of { req_id : string option }
  | Auth of
      { req_id : string option
      ; api_key : string
      ; expires : int (** ms, in the future *)
      ; signature : string
      }
[@@deriving sexp, compare, equal, yojson]

val op : t -> string

(** An [Auth] message signed with {!Signature.ws_auth}. *)
val auth : ?req_id:string -> api_key:string -> secret:string -> expires:int -> unit -> t

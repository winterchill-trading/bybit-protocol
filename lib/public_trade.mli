(** [publicTrade.<symbol>] pushes:
    [{"topic", "type": "snapshot", "ts", "data": [{"T", "s", "S", "v", "p", "L", "i", "BT", "seq"}]}],
    up to 1024 trades per message, oldest first. *)

open! Core

module Trade : sig
  type t =
    { time : Timestamp_ms.t (** [T], fill time *)
    ; symbol : Symbol.t (** [s] *)
    ; side : Side.t (** [S], taker side *)
    ; size : Size.t (** [v] *)
    ; price : Price.t (** [p] *)
    ; tick_direction : string option (** [L]: [PlusTick], [ZeroPlusTick], ... *)
    ; trade_id : Exec_id.t (** [i] *)
    ; block_trade : bool (** [BT] *)
    ; rpi : bool option
    (** [RPI] (* UNVERIFIED: listed in the field table, absent from the example *) *)
    ; seq : int option
    }
  [@@deriving sexp, compare, equal, yojson]
end

type t =
  { topic : Topic.t
  ; type_ : Update_type.t
  ; ts : Timestamp_ms.t
  ; data : Trade.t list
  }
[@@deriving sexp, compare, equal, yojson]

(** The common REST response envelope,
    [{"retCode": 0, "retMsg": "OK", "result": {...}, "retExtInfo": {}, "time": 1672211918471}].
    [retCode = 0] means success. *)

open! Core

module Error : sig
  (** Known non-zero [retCode]s (docs error page); anything else is [Other code]. *)
  type t =
    | Request_parameter_error (** 10001 *)
    | Request_time_out_of_window (** 10002: timestamp outside [recv_window] *)
    | Invalid_api_key (** 10003 *)
    | Invalid_signature (** 10004 *)
    | Permission_denied (** 10005 *)
    | Rate_limited (** 10006 *)
    | Server_error (** 10016 *)
    | Order_not_exists (** 110001 *)
    | Price_out_of_range (** 110003 *)
    | Wallet_balance_insufficient (** 110004 *)
    | Available_balance_insufficient (** 110007 *)
    | Qty_truncated_to_zero (** 110017: qty rounds to zero by [qtyStep] *)
    | Position_mode_not_modified (** 110025 *)
    | Leverage_not_modified (** 110043 *)
    | Duplicate_order_link_id (** 110072 *)
    | Order_processing (** 110079: order is processing, retry later *)
    | Spot_order_not_exists (** 170213 *)
    | Other of int
  [@@deriving sexp, compare, equal, hash, yojson]

  (** [None] for [0] (success). *)
  val of_code : int -> t option

  val to_code : t -> int
end

type 'a t =
  { ret_code : int
  ; ret_msg : string
  ; result : 'a
  ; ret_ext_info : Json.t (** [{}] except for batch endpoints *)
  ; time : Timestamp_ms.t
  }
[@@deriving sexp, compare, equal, yojson]

type error =
  { error : Error.t
  ; ret_msg : string
  }
[@@deriving sexp, compare, equal]

(** Decodes the envelope and, only when [retCode = 0], its [result] with
    [result_of_yojson]. Error envelopes often carry [{}] as [result], which the endpoint
    decoder would reject. (* UNVERIFIED: no error example was available; assumed to use
    the same keys. *) *)
val decode
  :  Yojson.Safe.t
  -> result_of_yojson:(Yojson.Safe.t -> 'a)
  -> ('a, error) Result.t

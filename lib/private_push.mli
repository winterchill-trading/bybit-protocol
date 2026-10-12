(** Private topic pushes ([order], [execution], [position], [wallet]):
    [{"id": "...", "topic": "order", "creationTime": 1672364262474, "data": [...]}]. *)

open! Core

type 'a t =
  { id : string
  ; topic : Topic.t
  ; creation_time : Timestamp_ms.t
  ; data : 'a list
  }
[@@deriving sexp, compare, equal, yojson]

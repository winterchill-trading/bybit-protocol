(** Execution id ([execId] on fills, [i] on public trades), a UUID string such as
    ["e0cbe81d-0f18-5866-9415-cf319b5dab3b"]. Not {!Exchange_core.Trade_id}, which is an
    integer. *)

open! Core

type t [@@deriving sexp, compare, equal, hash, yojson]

include Comparable.S with type t := t
include Hashable.S with type t := t
include Stringable.S with type t := t

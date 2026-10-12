(** The [result] of list endpoints:
    [{"category": "linear", "list": [...], "nextPageCursor": "..."}]. [nextPageCursor] is
    absent on some endpoints (tickers) and [""] on the last page. *)

open! Core

type 'a t =
  { category : Category.t
  ; list : 'a list
  ; next_page_cursor : string option
  }
[@@deriving sexp, compare, equal, yojson]

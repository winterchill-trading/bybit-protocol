open! Core
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type t =
  { position_idx : Position_idx.t [@key "positionIdx"]
  ; symbol : Symbol.t
  ; side : Side.Or_empty.t
  ; size : Size.t
  ; avg_price : Price.t [@key "avgPrice"]
  ; position_value : Usd.Or_empty.t [@key "positionValue"]
  ; unrealised_pnl : Usd.t [@key "unrealisedPnl"]
  ; cum_realised_pnl : Usd.t [@key "cumRealisedPnl"]
  ; cur_realised_pnl : Usd.t option
       [@key "curRealisedPnl"] [@default None] [@yojson_drop_if Option.is_none]
  ; leverage : Decimal.Or_empty.t
  ; liq_price : Price.Or_empty.t [@key "liqPrice"]
  ; mark_price : Price.t [@key "markPrice"]
  ; position_status : string option
       [@key "positionStatus"] [@default None] [@yojson_drop_if Option.is_none]
  ; created_time : Timestamp_ms.As_string.t [@key "createdTime"]
  ; updated_time : Timestamp_ms.As_string.t [@key "updatedTime"]
  ; category : Category.t option [@default None] [@yojson_drop_if Option.is_none]
  ; seq : int option [@default None] [@yojson_drop_if Option.is_none]
  }
[@@deriving sexp, compare, equal, yojson] [@@yojson.allow_extra_fields]

let signed_size t =
  match t.side with
  | Some Sell -> Size.neg t.size
  | Some Buy | None -> t.size
;;

module Ws = struct
  type nonrec t = t [@@deriving sexp, compare, equal]

  let rename_key (json : Yojson.Safe.t) ~from ~to_ : Yojson.Safe.t =
    match json with
    | `Assoc fields ->
      `Assoc
        (List.map fields ~f:(fun (k, v) -> if String.equal k from then to_, v else k, v))
    | other -> other
  ;;

  let t_of_yojson json = t_of_yojson (rename_key json ~from:"entryPrice" ~to_:"avgPrice")
  let yojson_of_t t = rename_key (yojson_of_t t) ~from:"avgPrice" ~to_:"entryPrice"
end

module Response = struct
  type nonrec t = t Page.t [@@deriving sexp, compare, equal, yojson]
end

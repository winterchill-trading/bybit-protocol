open! Core
open Bybit_protocol

(* The first seconds of a real BTCUSDT minute on the public linear stream (publicTrade,
   orderbook.1, orderbook.50, tickers), one frame per line as received. Every frame must
   decode without error, without falling back to [Unknown], and survive a re-encoding. *)

let dir = "fixtures/bybit-BTCUSDT-2026-10-12T15-05"

let frames file =
  In_channel.read_lines (dir ^/ file) |> List.filter ~f:(Fn.non String.is_empty)
;;

let decode line =
  Or_error.try_with (fun () -> Ws_message.t_of_yojson (Yojson.Safe.from_string line))
;;

let round_trips message =
  let encoded = Yojson.Safe.to_string (Ws_message.yojson_of_t message) in
  Ws_message.equal message (Ws_message.t_of_yojson (Yojson.Safe.from_string encoded))
;;

let kind : Ws_message.t -> string = function
  | Subscribe_ack _ -> "ack"
  | Auth_ack _ | Op_response _ | Pong _ -> "op"
  | Orderbook _ -> "orderbook"
  | Public_trade _ -> "trade"
  | Ticker _ -> "ticker"
  | Order _ | Execution _ | Position _ | Wallet _ -> "private"
  | Unknown _ -> "unknown"
;;

let%expect_test "every frame decodes" =
  List.iter [ "trades.jsonl"; "bbo.jsonl"; "l2.jsonl"; "funding.jsonl" ] ~f:(fun file ->
    let decoded = List.map (frames file) ~f:decode in
    let ok = List.filter_map decoded ~f:Result.ok in
    let errors = List.length decoded - List.length ok in
    let kinds =
      List.map ok ~f:kind
      |> List.sort_and_group ~compare:String.compare
      |> List.map ~f:(fun group -> List.hd_exn group, List.length group)
    in
    let not_round_tripping = List.count ok ~f:(Fn.non round_trips) in
    print_s
      [%message
        file
          ~frames:(List.length decoded : int)
          (kinds : (string * int) list)
          (errors : int)
          (not_round_tripping : int)]);
  [%expect
    {|
    (trades.jsonl (frames 80) (kinds ((ack 1) (trade 79))) (errors 0)
     (not_round_tripping 0))
    (bbo.jsonl (frames 150) (kinds ((ack 1) (orderbook 149))) (errors 0)
     (not_round_tripping 0))
    (l2.jsonl (frames 200) (kinds ((ack 1) (orderbook 199))) (errors 0)
     (not_round_tripping 0))
    (funding.jsonl (frames 100) (kinds ((ack 1) (ticker 99))) (errors 0)
     (not_round_tripping 0))
    |}]
;;

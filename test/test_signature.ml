open! Core
open Bybit_protocol

(* Expected values cross-checked with [openssl dgst -sha256 -hmac test-secret]. *)

let secret = "test-secret"
let api_key = "XXXXXXXXXX"
let timestamp = 1672211918471

let%expect_test "RFC 4231 test case 2" =
  print_endline (Signature.hmac_sha256_hex ~key:"Jefe" "what do ya want for nothing?");
  [%expect {| 5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843 |}]
;;

let%expect_test "POST body" =
  let payload =
    {|{"category":"linear","symbol":"BTCUSDT","side":"Buy","orderType":"Limit","qty":"0.001","price":"65000"}|}
  in
  print_endline (Signature.sign ~secret ~timestamp ~api_key ~recv_window:5000 ~payload);
  [%expect {| b49ec180a58b139641b68e7799e1404e4fd5440ccbc39c879a646cd2d0e86c88 |}]
;;

let%expect_test "GET query string and headers" =
  Signature.headers
    ~secret
    ~timestamp
    ~api_key
    ~recv_window:5000
    ~payload:"category=linear&symbol=BTCUSDT"
  |> List.iter ~f:(fun (k, v) -> printf "%s: %s\n" k v);
  [%expect
    {|
    X-BAPI-API-KEY: XXXXXXXXXX
    X-BAPI-TIMESTAMP: 1672211918471
    X-BAPI-RECV-WINDOW: 5000
    X-BAPI-SIGN: 8a103e9e9e09a7d38217d9f5f9260f198cba3974cfd050a9888360886d2039ba
    |}]
;;

let%expect_test "websocket auth" =
  print_endline (Signature.ws_auth ~secret ~expires:1662350400000);
  [%expect {| f072aab6fa18cd774da998325df6cfc87c3ccf10d5722e6b43b570c5feaf6172 |}]
;;

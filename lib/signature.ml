open! Core

let hmac_sha256_hex ~key msg =
  let mac = Cryptokit.hash_string (Cryptokit.MAC.hmac_sha256 key) msg in
  Cryptokit.transform_string (Cryptokit.Hexa.encode ()) mac
;;

let sign ~secret ~timestamp ~api_key ~recv_window ~payload =
  hmac_sha256_hex
    ~key:secret
    (Int.to_string timestamp ^ api_key ^ Int.to_string recv_window ^ payload)
;;

let headers ~secret ~timestamp ~api_key ~recv_window ~payload =
  [ "X-BAPI-API-KEY", api_key
  ; "X-BAPI-TIMESTAMP", Int.to_string timestamp
  ; "X-BAPI-RECV-WINDOW", Int.to_string recv_window
  ; "X-BAPI-SIGN", sign ~secret ~timestamp ~api_key ~recv_window ~payload
  ]
;;

let ws_auth ~secret ~expires =
  hmac_sha256_hex ~key:secret ("GET/realtime" ^ Int.to_string expires)
;;

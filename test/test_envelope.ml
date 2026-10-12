open! Core
open Bybit_protocol

let decode json =
  Envelope.decode (Yojson.Safe.from_string json) ~result_of_yojson:Order_ack.t_of_yojson
  |> [%sexp_of: (Order_ack.t, Envelope.error) Result.t]
  |> print_s
;;

let%expect_test "success" =
  decode
    {|{"retCode": 0, "retMsg": "OK",
       "result": {"orderId": "1321003749386327552", "orderLinkId": "spot-test-postonly"},
       "retExtInfo": {}, "time": 1672211918471}|};
  [%expect
    {| (Ok ((order_id 1321003749386327552) (order_link_id (spot-test-postonly)))) |}]
;;

(* UNVERIFIED: error envelope shape assumed to use the same keys. *)
let%expect_test "errors skip the result decoder" =
  decode
    {|{"retCode": 10004, "retMsg": "Error sign, please check your signature generation algorithm.",
       "result": {}, "retExtInfo": {}, "time": 1672211918471}|};
  decode {|{"retCode": 110079, "retMsg": "processing", "result": {}, "time": 1}|};
  decode {|{"retCode": 999999, "retMsg": "new", "result": null, "time": 1}|};
  [%expect
    {|
    (Error
     ((error Invalid_signature)
      (ret_msg "Error sign, please check your signature generation algorithm.")))
    (Error ((error Order_processing) (ret_msg processing)))
    (Error ((error (Other 999999)) (ret_msg new)))
    |}]
;;

let%expect_test "codes round trip" =
  List.iter [ 10001; 10002; 10006; 110007; 110017; 110072; 170213; 12345 ] ~f:(fun code ->
    let error = Option.value_exn (Envelope.Error.of_code code) in
    assert (Int.equal code (Envelope.Error.to_code error));
    print_s [%sexp (code : int), (error : Envelope.Error.t)]);
  print_s [%sexp (Envelope.Error.of_code 0 : Envelope.Error.t option)];
  [%expect
    {|
    (10001 Request_parameter_error)
    (10002 Request_time_out_of_window)
    (10006 Rate_limited)
    (110007 Available_balance_insufficient)
    (110017 Qty_truncated_to_zero)
    (110072 Duplicate_order_link_id)
    (170213 Spot_order_not_exists)
    (12345 (Other 12345))
    ()
    |}]
;;

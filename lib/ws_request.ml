open! Core

type t =
  | Subscribe of
      { req_id : string option
      ; args : Topic.t list
      }
  | Unsubscribe of
      { req_id : string option
      ; args : Topic.t list
      }
  | Ping of { req_id : string option }
  | Auth of
      { req_id : string option
      ; api_key : string
      ; expires : int
      ; signature : string
      }
[@@deriving sexp, compare, equal]

let op = function
  | Subscribe _ -> "subscribe"
  | Unsubscribe _ -> "unsubscribe"
  | Ping _ -> "ping"
  | Auth _ -> "auth"
;;

let auth ?req_id ~api_key ~secret ~expires () =
  Auth { req_id; api_key; expires; signature = Signature.ws_auth ~secret ~expires }
;;

let yojson_of_t t : Yojson.Safe.t =
  let req_id, args =
    match t with
    | Subscribe { req_id; args } | Unsubscribe { req_id; args } ->
      req_id, Some (List.map args ~f:Topic.yojson_of_t)
    | Ping { req_id } -> req_id, None
    | Auth { req_id; api_key; expires; signature } ->
      req_id, Some [ `String api_key; `Int expires; `String signature ]
  in
  `Assoc
    (List.filter_opt
       [ Option.map req_id ~f:(fun r -> "req_id", `String r)
       ; Some ("op", `String (op t))
       ; Option.map args ~f:(fun a -> "args", `List a)
       ])
;;

let t_of_yojson json =
  let req_id =
    match Json.member json ~key:"req_id" with
    | Some (`String r) -> Some r
    | _ -> None
  in
  let args () =
    match Json.member json ~key:"args" with
    | Some (`List args) -> args
    | Some `Null | None -> []
    | Some other -> Json.error "args: list expected" other
  in
  let string = function
    | `String s -> s
    | other -> Json.error "string expected" other
  in
  match Json.tag json ~key:"op" with
  | "subscribe" -> Subscribe { req_id; args = List.map (args ()) ~f:Topic.t_of_yojson }
  | "unsubscribe" ->
    Unsubscribe { req_id; args = List.map (args ()) ~f:Topic.t_of_yojson }
  | "ping" -> Ping { req_id }
  | "auth" ->
    (match args () with
     | [ api_key; expires; signature ] ->
       Auth
         { req_id
         ; api_key = string api_key
         ; expires = Timestamp_ms.to_int_ms (Timestamp_ms.t_of_yojson expires)
         ; signature = string signature
         }
     | _ -> Json.error "auth: [api_key, expires, signature] expected" json)
  | _ -> Json.error "unknown op" json
;;

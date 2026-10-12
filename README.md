# bybit-protocol

Bybit v5 wire types and JSON codecs (category `linear`, USDT perpetuals).

Built with [OxCaml](https://oxcaml.org) and the Jane Street library stack (Base, Core).

## Build

```sh
opam switch create 5.2.0+ox --repos ox=git+https://github.com/oxcaml/opam-repository.git,default
opam pin add fixed-decimal https://github.com/winterchill-trading/fixed-decimal.git --no-action
opam pin add exchange-core https://github.com/winterchill-trading/exchange-core.git --no-action
opam install . --deps-only --with-test
dune build && dune test
```

## Modules

All modules live under `Bybit_protocol`. Wire types derive `sexp`, `compare`, `equal`
and `yojson` (via `ppx_yojson_conv`) and match Bybit's v5 HTTP and websocket API for
`category=linear`. [docs/bybit-v5-spec.md](docs/bybit-v5-spec.md) holds the reference
notes the codecs were written against.

### Primitives

The venue-neutral primitives live in
[exchange-core](https://github.com/winterchill-trading/exchange-core) and are re-exported
with type equalities where the wire format allows it (`Bybit_protocol.Price.t =
Exchange_core.Price.t`, `Side.t = Exchange_core.Side.t`, ...).

| Module | Description |
| --- | --- |
| `Price`, `Size`, `Usd` | `Exchange_core.Price`, `Size`, `Usd`, decimal strings; `Or_empty` submodules map `""` to `None` |
| `Decimal` | Dimensionless decimals (leverage, funding and fee rates) |
| `Or_empty` | Functor for optional values encoded as `""` |
| `Symbol` | `Exchange_core.Symbol` (`"BTCUSDT"`) |
| `Category` | `linear` / `inverse` / `spot` / `option` |
| `Side` | `Exchange_core.Side` as `"Buy"` / `"Sell"`; `Side.Or_empty` for flat positions |
| `Order_type` | `Limit` / `Market` / `UNKNOWN` |
| `Time_in_force` | `GTC` / `IOC` / `FOK` / `PostOnly` / `RPI`, with `Exchange_core.Tif` mapping |
| `Order_status` | All nine v5 statuses, `is_open` |
| `Position_idx` | `0` one-way, `1` hedge buy, `2` hedge sell |
| `Reject_reason` | `EC_*` reasons, `Other` for the rest, `Exchange_core.Reject_reason` mapping |
| `Exec_type` | `Trade`, `Funding`, `AdlTrade`, ..., `Other` |
| `Timestamp_ms` | Epoch ms; decodes integers and strings, `As_string` re-encodes as a string |
| `Order_id` | Bybit's string order id (UUID or digits), `to_exchange_core` when numeric |
| `Order_link_id` | `Exchange_core.Client_order_id`; `create` checks the 36-char `[A-Za-z0-9_-]` rule |
| `Exec_id` | Execution / public trade id (UUID string) |
| `Book_level` | `[price, size]` string pair |
| `Json`, `Codec` | Opaque JSON helpers; `module type S` satisfied by every wire type |

### REST

| Module | Endpoint |
| --- | --- |
| `Envelope` | `{retCode, retMsg, result, retExtInfo, time}` as `'a t`; `decode` skips `result` on errors; `Envelope.Error` known retCodes |
| `Page` | `{category, list, nextPageCursor}` list results |
| `Instruments_info` | `GET /v5/market/instruments-info` (lot size, price and leverage filters, `to_exchange_core`) |
| `Orderbook` | `GET /v5/market/orderbook` (`to_exchange_core` gives an `L2.t`) |
| `Tickers` | `GET /v5/market/tickers` |
| `Create_order` | `POST /v5/order/create` (`Params`, `Request`, `Response`) |
| `Create_batch` | `POST /v5/order/create-batch` with per-item `Ext_info` from `retExtInfo` |
| `Cancel_order`, `Cancel_all`, `Amend_order` | `POST /v5/order/cancel`, `cancel-all`, `amend` |
| `Order_ack` | `{orderId, orderLinkId}` result shared by create, cancel and amend |
| `Realtime_order` | `GET /v5/order/realtime` and the `order` topic |
| `Execution` | `GET /v5/execution/list` and the `execution` topic |
| `Position` | `GET /v5/position/list` (`avgPrice`); `Position.Ws` for the topic (`entryPrice`) |
| `Wallet_balance` | `GET /v5/account/wallet-balance` and the `wallet` topic |
| `Signature` | HMAC-SHA256 signing for `X-BAPI-SIGN` and websocket auth (pure) |

### WebSocket

| Module | Description |
| --- | --- |
| `Topic` | `orderbook.<depth>.<symbol>`, `publicTrade.<symbol>`, `tickers.<symbol>`, `order[.linear]`, `execution[.linear]`, `position[.linear]`, `wallet` |
| `Ws_request` | `subscribe` / `unsubscribe` / `ping` / `auth` ops (`auth` signs for you) |
| `Op_response` | Subscribe and auth acks, public and private pongs |
| `Update_type` | `snapshot` / `delta` |
| `Ws_orderbook` | Orderbook pushes |
| `Public_trade` | Public trade pushes (`T s S v p L i BT`) |
| `Ws_ticker` | Ticker pushes, all fields optional, `Data.apply` merges a delta |
| `Private_push` | `{id, topic, creationTime, data}` for private topics |
| `Ws_message` | Server message variant, decoded by `op`, then `topic` |

## UNVERIFIED

These could not be confirmed from the docs and are implemented by assumption (marked
`UNVERIFIED` in the source):

- Error envelopes use the same keys with a non-zero `retCode`; `result` may be `{}` or
  `null`, so `Envelope.decode` does not decode it.
- The GET signing string uses the query string exactly as sent; `Signature.sign` signs
  whatever the caller passes.
- Linear-specific examples for tickers, position list and create-batch (inverse/spot
  examples were used, assuming the same shape).
- Websocket subscribe failures and the auth ack use the `Op_response` shape
  (`success: false`, reason in `ret_msg`).
- Ticker deltas always include `symbol`; every other field may be absent.
- The `RPI` flag on public trades may be absent (`rpi : bool option`).
- Reduce-only rejection has no dedicated retCode here (110017 is "orderQty will be
  truncated to zero").
- Recv window maximum, rate limits and orderbook depth 500 (docs list 1, 50, 200, 1000)
  are not modelled.

## Differences from the Bybit API

- Only the fields listed in each module are kept; response decoders ignore unknown fields.
  Conditional orders, TP/SL, SMP, fee details (`cumFeeDetail`, `extraFees`) and option
  fields are not modelled.
- Decimals are re-encoded in their shortest form (`"65000.00"` becomes `"65000"`), and
  digits past the 8th decimal place are dropped when parsing.
- Coin-level wallet amounts are typed `Usd.t` even for non-USD coins.
- `Order_id` and `Exec_id` are strings, not `Exchange_core.Order_id` / `Trade_id`
  (integers): Bybit uses UUIDs for many products.
- `orderbook` pushes keep `depth` as any integer; `Topic.of_string` does not check it.
- Error retCodes 110017 and 110079 follow the docs ("qty truncated to zero", "order is
  processing"); post-only rejection is `Reject_reason.Post_only_will_take_liquidity` on
  the order, not a retCode.
- Unknown websocket topics decode to `Ws_message.Unknown`, unknown reject reasons and
  exec types to `Other`.

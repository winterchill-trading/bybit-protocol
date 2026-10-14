# AGENTS.md (lib/)

Library `bybit_protocol`: types and codecs only, no I/O.

- REST types sit behind `Envelope` (`retCode`, `retMsg`, `result`) and `Envelope.Error`.
  `Page` covers cursor pagination; cursors are opaque strings.
- Websocket types: `Topic` and `Ws_request` for subscribe and auth, `Op_response` for acks,
  `Ws_orderbook` and `Ws_ticker` for market data (`Ws_ticker.Data.apply` merges deltas),
  `Private_push` and `Ws_message` for the private stream.
- `Signature` signs REST requests and the websocket auth step. The GET signing string is the
  query string as sent.
- Build: `dune build --root .. @bybit-protocol/all` from the repository root.

# Bybit V5 API spec: category=linear (USDT perpetuals)

Sources: https://bybit-exchange.github.io/docs/v5/... (fetched 2026-10-12 via WebFetch; quotes are from the fetched text, examples are copied from the docs, abridged only where marked).

Hosts (per brief): REST `https://api.bybit.com`; WS public `wss://stream.bybit.com/v5/public/linear`; WS private `wss://stream.bybit.com/v5/private`.
Note: several doc examples use `api-testnet.bybit.com`; the production host above was taken from the brief and is not re-verified against the docs.

Items marked **UNVERIFIED** could not be fetched or confirmed from the docs. Summary list at the end.

---

## 0. Common envelope

REST responses (all examples in the docs):
```json
{
    "retCode": 0,
    "retMsg": "OK",
    "result": { },
    "retExtInfo": {},
    "time": 1672211918471
}
```
- `retCode` (integer): 0 = success.
- `retMsg` (string): "OK" on success.
- `result` (object): endpoint payload.
- `retExtInfo` (object): usually `{}`; batch endpoints put per-item status here.
- `time` (integer): server timestamp, ms.
- Error envelope shape: **UNVERIFIED** (no error example fetched). Assumed same keys with non-zero `retCode`.

Numbers are sent and returned as **strings** for prices, quantities and amounts (e.g. `"65557.7"`). Timestamps are ms integers or ms-as-strings (see each field).

---

## 1. Authentication (REST)

Headers on every authenticated request (page "HTTP Headers for Authenticated Endpoints"):

| Header | Value |
|---|---|
| `X-BAPI-API-KEY` | API key |
| `X-BAPI-TIMESTAMP` | UTC timestamp in milliseconds |
| `X-BAPI-SIGN` | signature (lowercase hex for HMAC) |
| `X-BAPI-RECV-WINDOW` | optional, ms; default 5000 |
| `X-Referer` or `Referer` | broker users only |

Signing string:
- GET: `timestamp + apiKey + recv_window + queryString`
- POST: `timestamp + apiKey + recv_window + jsonBodyString`

Where `timestamp` = the same value sent in `X-BAPI-TIMESTAMP`, `recv_window` = the same value sent in `X-BAPI-RECV-WINDOW` (5000 if default is used, and the value must still be included in the string), `queryString` = the query string as sent (for GET), `jsonBodyString` = the exact JSON body bytes sent (for POST). Concatenation is plain string concatenation with no separators.

Algorithm: HMAC-SHA256 keyed with the API secret; output encoded as lowercase hex; sent in `X-BAPI-SIGN`. (RSA_SHA256 with base64 also supported; not needed here.)

Notes:
- Recv window: default 5000 ms. Maximum value: **UNVERIFIED** (not stated on the fetched page). Smaller is safer; requests may fail if transit exceeds the window.
- Error 10002 = timestamp outside the window.
- Error 10004 = bad signature.
- Sending the body: the signed string must match the body bytes exactly (serialize once, sign that string, send the same string).

Pseudo-code of the signing string (no code language specified in brief; shown as text):
```
payload = str(timestamp) + apiKey + str(recvWindow) + (queryString for GET | bodyJson for POST)
sign    = lowercase_hex(HMAC_SHA256(key=apiSecret, msg=payload))
```

Example query string for GET endpoints: the docs do not show a sample signed request string; **UNVERIFIED** whether the queryString must be percent-encoded as sent (assumed: sign exactly the string appended to the URL).

---

## 2. REST endpoints

### 2.1 GET /v5/market/instruments-info (public)

Query params (category=linear):

| Name | Required | Type | Description |
|---|---|---|---|
| category | true | string | `spot`, `linear`, `inverse`, `option` |
| symbol | false | string | e.g. `BTCUSDT`, uppercase |
| symbolType | false | string | linear/inverse/spot only |
| status | false | string | symbol status filter |
| baseCoin | false | string | linear/inverse/option |
| limit | false | integer | 1 to 1000, default 500 |
| cursor | false | string | `nextPageCursor` from previous response |

Response (abridged linear example from docs):
```json
{
  "retCode": 0,
  "retMsg": "OK",
  "result": {
    "category": "linear",
    "list": [
      {
        "symbol": "BTCUSDT",
        "symbolId": 5,
        "contractType": "LinearPerpetual",
        "status": "Trading",
        "baseCoin": "BTC",
        "quoteCoin": "USDT",
        "leverageFilter": { "minLeverage": "1", "maxLeverage": "100.00", "leverageStep": "0.01" },
        "priceFilter": { "minPrice": "0.10", "maxPrice": "1999999.80", "tickSize": "0.10" },
        "lotSizeFilter": {
          "maxOrderQty": "1190.000",
          "minOrderQty": "0.001",
          "qtyStep": "0.001",
          "postOnlyMaxOrderQty": "1190.000",
          "maxMktOrderQty": "500.000",
          "minNotionalValue": "5"
        }
      }
    ],
    "nextPageCursor": ""
  },
  "retExtInfo": {},
  "time": 1735809771618
}
```
Field definitions (linear/inverse, result.list[]):
- `symbol` string; `symbolId` integer; `contractType` string; `status` string; `baseCoin`, `quoteCoin` string; `launchTime`, `deliveryTime` string (ms); `priceScale` string; `unifiedMarginTrade`, `fundingInterval`, `settleCoin`, `copyTrading`, `upperFundingRate`, `lowerFundingRate`, `displayName`, `fullName`, `marketRegion`, `underlyingTicker`, `tags`, `forbidUplWithdrawal`, `riskParameters`, `isPreListing`, `preListingInfo` present (not detailed).
- `leverageFilter.minLeverage`, `.maxLeverage`, `.leverageStep` (string)
- `priceFilter.minPrice`, `.maxPrice`, `.tickSize` (string). **tickSize** = price step.
- `lotSizeFilter.minOrderQty` (string), `.maxOrderQty` (string; limit/PostOnly max), `.maxMktOrderQty` (string; market max), `.qtyStep` (string; **qty step**), `.postOnlyMaxOrderQty` (string; **deprecated**, use `maxOrderQty`), `.minNotionalValue` (string).
- Brief said `postOnlyMaxOrderSize`: the docs name is `postOnlyMaxOrderQty`. Spot uses `postOnlyMaxLimitOrderSize` instead.
- Paginated: `result.nextPageCursor`; default limit 500.

### 2.2 GET /v5/market/orderbook (public)

Query: `category` (required, `linear`), `symbol` (required, uppercase), `limit` (optional; linear default 25, range 1 to 1000).

Response:
```json
{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "s": "BTCUSDT",
        "a": [ [ "65557.7", "16.606555" ] ],
        "b": [ [ "65485.47", "47.081829" ] ],
        "ts": 1716863719031,
        "u": 230704,
        "seq": 1432604333,
        "cts": 1716863718905
    },
    "retExtInfo": {},
    "time": 1716863719382
}
```
- `s` string symbol
- `b` array of `[price, size]` (string pairs), sorted price descending (best bid first)
- `a` array of `[price, size]` (string pairs), sorted price ascending (best ask first)
- `ts` integer ms: time the system generated the data
- `u` integer: update ID
- `seq` integer: cross sequence; smaller = generated earlier
- `cts` integer ms: matching-engine timestamp (correlates with `T` in publicTrade)
- Snapshot format. RPI orders are not included.

### 2.3 GET /v5/market/tickers (public)

Query: `category` (required, `linear`), `symbol` (optional, uppercase). (`baseCoin`, `expDate` are option-only.)

Docs example is inverse (same schema for linear); **linear-specific example UNVERIFIED**. Example:
```json
{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "category": "inverse",
        "list": [
            {
                "symbol": "BTCUSD",
                "lastPrice": "120635.50",
                "indexPrice": "114890.92",
                "markPrice": "114898.43",
                "prevPrice24h": "105595.90",
                "price24hPcnt": "0.142425",
                "highPrice24h": "131309.30",
                "lowPrice24h": "102007.60",
                "prevPrice1h": "119806.10",
                "openInterest": "240113967",
                "openInterestValue": "2089.79",
                "turnover24h": "115.6907",
                "volume24h": "13713832.0000",
                "fundingRate": "0.0001",
                "nextFundingTime": "1760371200000",
                "predictedDeliveryPrice": "",
                "basisRate": "",
                "deliveryFeeRate": "",
                "deliveryTime": "0",
                "ask1Size": "9854",
                "bid1Price": "103401.00",
                "ask1Price": "109152.80",
                "bid1Size": "1063",
                "basis": "",
                "preOpenPrice": "",
                "preQty": "",
                "curPreListingPhase": "",
                "fundingIntervalHour": "8",
                "basisRateYear": "",
                "fundingCap": "0.005"
            }
        ]
    },
    "retExtInfo": {},
    "time": 1760352369814
}
```
Field definitions (result.list[]): `symbol`, `lastPrice`, `markPrice`, `bid1Price`, `ask1Price`, `bid1Size`, `ask1Size`, `fundingRate` (all string), `nextFundingTime` (string ms), `indexPrice`, `openInterest` (both sides), `turnover24h`, `volume24h`, `price24hPcnt`, `highPrice24h`, `lowPrice24h` (string).

### 2.4 POST /v5/order/create (private)

Body (category=linear):

| Parameter | Required | Type | Values / notes |
|---|---|---|---|
| category | true | string | `linear` |
| symbol | true | string | e.g. `BTCUSDT` |
| side | true | string | `Buy`, `Sell` |
| orderType | true | string | `Market`, `Limit` |
| qty | true | string | positive; always order by qty for perps |
| price | false | string | required for Limit; ignored for Market |
| triggerDirection | false | integer | `1` (rises to trigger), `2` (falls to trigger) |
| triggerPrice | false | string | conditional orders |
| triggerBy | false | string | `LastPrice`, `IndexPrice`, `MarkPrice` |
| timeInForce | false | string | `GTC` (default), `IOC`, `FOK`, `PostOnly`, `RPI`. Market always `IOC`. |
| positionIdx | false | integer | `0` one-way, `1` hedge Buy, `2` hedge Sell. Required in hedge mode. |
| orderLinkId | false | string | max 36 chars; letters, digits, `-`, `_`; unique |
| takeProfit | false | string | |
| stopLoss | false | string | |
| tpTriggerBy | false | string | `LastPrice` (default), `IndexPrice`, `MarkPrice` |
| slTriggerBy | false | string | `LastPrice` (default), `IndexPrice`, `MarkPrice` |
| reduceOnly | false | boolean | true = can only shrink position; TP/SL cannot be set when true |
| closeOnTrigger | false | boolean | |
| smpType | false | string | self-match-prevention type |
| tpslMode | false | string | `Full` or `Partial` (Partial required for limit TP/SL) |
| tpLimitPrice / slLimitPrice | false | string | Partial mode with Limit TP/SL order types |
| tpOrderType / slOrderType | false | string | `Market` (default), `Limit`; Full mode only Market |
| bboSideType | false | string | `Queue`, `Counterparty` |
| bboLevel | false | string | `1` to `5` |

Request example (typed from the parameter table; not a verbatim docs example):
```json
{ "category": "linear", "symbol": "BTCUSDT", "side": "Buy", "orderType": "Limit",
  "qty": "0.001", "price": "65000.00", "timeInForce": "PostOnly",
  "positionIdx": 0, "orderLinkId": "example-0001", "reduceOnly": false }
```

Response (docs example, spot-typed; the shape is the same for linear):
```json
{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "orderId": "1321003749386327552",
        "orderLinkId": "spot-test-postonly"
    },
    "retExtInfo": {},
    "time": 1672211918471
}
```
- `orderId` string, `orderLinkId` string.
- The create is **asynchronous**: the response is an acknowledgement only. Confirm status via the private `order` WS topic or GET /v5/order/realtime.

Enums: side `Buy|Sell`; orderType `Market|Limit`; timeInForce `GTC|IOC|FOK|PostOnly|RPI`; positionIdx `0|1|2`.

Limits (docs): up to 500 active orders per symbol per account (perps/futures); up to 10 active conditional orders per symbol per account. Rate-limit figures: see `/docs/v5/rate-limit#trade` (**UNVERIFIED**, not fetched).

### 2.5 POST /v5/order/create-batch (private)

Body:
- `category` (string, required): `linear`
- `request` (array, required): items below

Item fields (linear-applicable): `symbol` (req), `side` (req), `orderType` (req), `qty` (req), `price`, `triggerDirection`, `triggerPrice`, `triggerBy`, `timeInForce` (default GTC), `positionIdx`, `orderLinkId`, `takeProfit`, `stopLoss`, `tpTriggerBy`, `slTriggerBy`, `reduceOnly`, `closeOnTrigger`, `smpType`, `tpslMode`, `tpLimitPrice`, `slLimitPrice`, `tpOrderType`, `slOrderType`. (`isLeverage`, `marketUnit`, `orderFilter`, `orderIv`, `mmp` are spot/option only.)

Max per request for linear: **20** (docs: "20 orders (linear)").

Response (docs example is spot; linear shape same):
```json
{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "list": [
            { "category": "spot", "symbol": "BTCUSDT", "orderId": "1666800494330512128",
              "orderLinkId": "spot-btc-03", "createAt": "1713434102752" },
            { "category": "spot", "symbol": "ATOMUSDT", "orderId": "1666800494330512129",
              "orderLinkId": "spot-atom-03", "createAt": "1713434102752" }
        ]
    },
    "retExtInfo": {
        "list": [
            { "code": 0, "msg": "OK" },
            { "code": 0, "msg": "OK" }
        ]
    },
    "time": 1713434102753
}
```
- `result.list[]`: `category`, `symbol`, `orderId`, `orderLinkId`, `createAt` (ms string).
- `retExtInfo.list[]`: `code` (number), `msg` (string); same order as `result.list`. Per-item success/failure must be read from here, not from the top-level `retCode`.
- Linear batch example: **UNVERIFIED** (only spot example fetched).

### 2.6 POST /v5/order/cancel (private)

Body:
| Name | Required | Type | Notes |
|---|---|---|---|
| category | true | string | `linear` |
| symbol | true | string | uppercase |
| orderId | one of | string | |
| orderLinkId | one of | string | |

Rules: must give `orderId` or `orderLinkId`. If both are given and disagree, `orderId` wins. Only unfilled or partially filled orders can be cancelled.

Response:
```json
{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "orderId": "c6f055d9-7f21-4079-913d-e6523a9cfffa",
        "orderLinkId": "linear-004"
    },
    "retExtInfo": {},
    "time": 1672217377164
}
```
Asynchronous acknowledgement; confirm via WS or realtime query.

### 2.7 POST /v5/order/cancel-all (private)

Body:
| Name | Required | Type | Notes |
|---|---|---|---|
| category | true | string | `linear` |
| symbol | conditional | string | required for linear unless baseCoin or settleCoin passed |
| baseCoin | conditional | string | |
| settleCoin | conditional | string | required for linear/inverse if symbol or baseCoin not passed |
| orderFilter | false | string | linear/inverse: `Order`, `StopOrder`, `OpenOrder`. Omitted = all kinds incl. conditional, TP/SL, trailing stop |
| stopOrderType | false | string | `Stop`; only with orderFilter=`StopOrder` |

Response:
```json
{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "list": [
            { "orderId": "1616024329462743808", "orderLinkId": "1616024329462743809" },
            { "orderId": "1616024287544869632", "orderLinkId": "1616024287544869633" }
        ],
        "success": "1"
    },
    "retExtInfo": {},
    "time": 1707381118116
}
```
`result.success`: string, "1" = success, "0" = failure.

### 2.8 POST /v5/order/amend (private)

Body:
| Name | Required | Type | Notes |
|---|---|---|---|
| category | true | string | `linear` |
| symbol | true | string | |
| orderId | one of | string | |
| orderLinkId | one of | string | |
| qty | false | string | new qty; omit if unchanged |
| price | false | string | new price; omit if unchanged |
| triggerPrice | false | string | conditional orders |
| tpslMode | false | string | `Full` or `Partial` |
| takeProfit | false | string | `"0"` cancels TP |
| stopLoss | false | string | `"0"` cancels SL |
| tpTriggerBy, slTriggerBy, triggerBy | false | string | |
| tpLimitPrice, slLimitPrice | false | string | |

Response:
```json
{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "orderId": "c6f055d9-7f21-4079-913d-e6523a9cfffa",
        "orderLinkId": "linear-004"
    },
    "retExtInfo": {},
    "time": 1672217093461
}
```

### 2.9 GET /v5/order/realtime (private, open orders)

Query (category=linear):
| Name | Required | Type | Notes |
|---|---|---|---|
| category | true | string | `linear` |
| symbol | one of (linear) | string | uppercase |
| baseCoin | one of (linear) | string | |
| settleCoin | one of (linear) | string | |
| orderId | false | string | |
| orderLinkId | false | string | |
| openOnly | false | integer | `0` (default) open only; `1` also returns up to the latest 500 closed records. Ignored with orderId/orderLinkId |
| orderFilter | false | string | `Order`, `StopOrder`, `tpslOrder`, `OcoOrder`, `BidirectionalTpslOrder` |
| limit | false | integer | 1 to 50, default 20 |
| cursor | false | string | `nextPageCursor` |

Response (linear, from docs):
```json
{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "list": [
            {
                "orderId": "fd4300ae-7847-404e-b947-b46980a4d140",
                "orderLinkId": "test-000005",
                "blockTradeId": "",
                "symbol": "ETHUSDT",
                "price": "1600.00",
                "qty": "0.10",
                "side": "Buy",
                "isLeverage": "",
                "positionIdx": 1,
                "orderStatus": "New",
                "cancelType": "UNKNOWN",
                "rejectReason": "EC_NoError",
                "avgPrice": "0",
                "leavesQty": "0.10",
                "leavesValue": "160",
                "cumExecQty": "0.00",
                "cumExecValue": "0",
                "cumExecFee": "0",
                "timeInForce": "GTC",
                "orderType": "Limit",
                "stopOrderType": "UNKNOWN",
                "orderIv": "",
                "triggerPrice": "0.00",
                "takeProfit": "2500.00",
                "stopLoss": "1500.00",
                "tpTriggerBy": "LastPrice",
                "slTriggerBy": "LastPrice",
                "triggerDirection": 0,
                "triggerBy": "UNKNOWN",
                "lastPriceOnCreated": "",
                "reduceOnly": false,
                "closeOnTrigger": false,
                "smpType": "None",
                "smpGroup": "0",
                "smpOrderId": "",
                "tpslMode": "Full",
                "tpLimitPrice": "",
                "slLimitPrice": "",
                "placeType": "",
                "createdTime": "1684738540559",
                "updatedTime": "1684738540561",
                "cumFeeDetail": { "MNT": "0.00242968" }
            }
        ],
        "nextPageCursor": "page_args%3Dfd4300ae-7847-404e-b947-b46980a4d140%26symbol%3D6%26",
        "category": "linear"
    },
    "retExtInfo": {},
    "time": 1684765770483
}
```
Field notes:
- `orderStatus` (string): see Enum section 4 (`New`, `PartiallyFilled`, `Untriggered`, `Rejected`, `Filled`, `Cancelled`, `Triggered`, `Deactivated`). Brief's list (New/PartiallyFilled/Filled/Cancelled/Rejected) is a subset.
- `cumExecQty`, `cumExecValue`, `cumExecFee` (string). `cumExecFee` is **deprecated for linear**; use `cumFeeDetail`.
- `avgPrice` (string): `""` when no average price (docs); the example shows `"0"` for an unfilled order.
- `leavesQty`, `leavesValue` (string).
- `qty`, `price` (string); `side` `Buy|Sell`; `orderType` `Market|Limit`; `timeInForce` string; `reduceOnly` boolean; `createdTime`, `updatedTime` string ms.
- Sub-enum values for `timeInForce`, `orderStatus` are the enum page values.
- `result.category` = `linear`.

### 2.10 GET /v5/execution/list (private, fills)

Query:
| Name | Required | Type | Notes |
|---|---|---|---|
| category | true | string | `linear` |
| symbol | false | string | |
| orderId | false | string | |
| orderLinkId | false | string | |
| baseCoin | false | string | |
| settleCoin | false | string | |
| startTime | false | integer | ms |
| endTime | false | integer | ms |
| execType | false | string | |
| limit | false | integer | 1 to 100, default 50 |
| cursor | false | string | |

Time window: no time params = last 7 days. Only startTime or only endTime = 7 days from that value. Both given: `endTime - startTime` <= 7 days. Priority: orderId > orderLinkId > symbol > baseCoin.

Response (linear, from docs):
```json
{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "nextPageCursor": "132766%3A2%2C132766%3A2",
        "category": "linear",
        "list": [
            {
                "symbol": "ETHPERP",
                "orderType": "Market",
                "underlyingPrice": "",
                "orderLinkId": "",
                "side": "Buy",
                "indexPrice": "",
                "orderId": "8c065341-7b52-4ca9-ac2c-37e31ac55c94",
                "stopOrderType": "UNKNOWN",
                "leavesQty": "0",
                "execTime": "1672282722429",
                "feeCurrency": "",
                "isMaker": false,
                "execFee": "0.071409",
                "feeRate": "0.0006",
                "execId": "e0cbe81d-0f18-5866-9415-cf319b5dab3b",
                "tradeIv": "",
                "blockTradeId": "",
                "markPrice": "1183.54",
                "execPrice": "1190.15",
                "markIv": "",
                "orderQty": "0.1",
                "orderPrice": "1236.9",
                "execValue": "119.015",
                "execType": "Trade",
                "execQty": "0.1",
                "closedSize": "",
                "extraFees": "",
                "seq": 4688002127
            }
        ]
    },
    "retExtInfo": {},
    "time": 1672283754510
}
```
Field definitions (result.list[]):
- `execId` string (unique execution ID)
- `execPrice` string
- `execQty` string
- `execFee` string (fee for this execution)
- `feeRate` string
- `execType` string (`Trade`, `AdlTrade`, `Funding`, `BustTrade`, `Settle`, ... see enum)
- `execValue` string
- `isMaker` boolean (true = maker)
- `side` string `Buy|Sell`
- `orderId`, `orderLinkId` string
- `execTime` string ms
- `closedSize` string (size of position closed by this execution)
- `seq` integer; `feeCurrency`, `extraFees` present
- **closedPnl: NOT present in this endpoint.** Brief asked for `closedPnl?`. Realised PnL per closing fill is not in `/v5/execution/list` per the docs. It appears on the private `order` WS topic (`closedPnl`). Use `cumRealisedPnl` on position for cumulative figure.
- Sort: `execTime` descending. Pagination: `result.nextPageCursor`.

### 2.11 GET /v5/position/list (private)

Query:
| Name | Required | Type | Notes |
|---|---|---|---|
| category | true | string | `linear` |
| symbol | one of | string | if passed, returns data even if no position |
| settleCoin | one of | string | for linear, either symbol or settleCoin required; symbol has priority |
| limit | false | integer | 1 to 200, default 20 |
| cursor | false | string | |

Response (docs example is `inverse`; linear shape same; abridged; linear-specific example UNVERIFIED):
```json
{
  "retCode": 0,
  "retMsg": "OK",
  "result": {
    "list": [
      {
        "positionIdx": 0,
        "riskId": 1,
        "riskLimitValue": "150",
        "symbol": "BTCUSD",
        "side": "Sell",
        "size": "300",
        "avgPrice": "27464.50441675",
        "positionValue": "0.01092319",
        "tradeMode": 0,
        "positionStatus": "Normal",
        "leverage": "10",
        "markPrice": "28224.50",
        "liqPrice": "",
        "positionIM": "0.00010923",
        "positionMM": "0.0000015",
        "unrealisedPnl": "-0.00029413",
        "curRealisedPnl": "0.00013123",
        "cumRealisedPnl": "-0.00096902",
        "createdTime": "1676538056258",
        "updatedTime": "1697673600012"
      }
    ],
    "nextPageCursor": "",
    "category": "inverse"
  },
  "retExtInfo": {},
  "time": 1697684980172
}
```
Full docs example also has `breakEvenPrice`, `takeProfit`, `stopLoss`, `seq`, `isReduceOnly` (omitted here).

Field definitions (result.list[]):
- `symbol` string
- `side` string: `Buy` = long, `Sell` = short, `""` = empty position
- `size` string, always positive
- `avgPrice` string: average entry price (docs)
- `positionValue` string
- `unrealisedPnl` string
- `cumRealisedPnl` string (all-time for perps)
- `curRealisedPnl` string
- `leverage` string (`""` in portfolio margin)
- `liqPrice` string (`""` when out of range; cross margin is an estimate)
- `markPrice` string
- `positionIdx` integer: `0` one-way, `1` buy-side hedge, `2` sell-side hedge
- `positionStatus` string: `Normal`, `Liq`, `Adl`
- `positionIM`, `positionMM` string
- `tradeMode` integer: deprecated, always 0
- `createdTime`, `updatedTime` string ms
- Brief's `positionValue` present. Brief's `avgPrice` present.

### 2.12 GET /v5/account/wallet-balance (private)

Query:
| Name | Required | Type | Notes |
|---|---|---|---|
| accountType | true | string | `UNIFIED` |
| coin | false | string | comma-separated, e.g. `USDT,USDC`. Omitted = only non-zero assets |

Response (accountType UNIFIED, docs):
```json
{
    "retCode": 0,
    "retMsg": "OK",
    "result": {
        "list": [
            {
                "totalEquity": "3.31216591",
                "accountIMRate": "0",
                "accountIMRateByMp": "0",
                "totalMarginBalance": "3.00326056",
                "totalInitialMargin": "0",
                "totalInitialMarginByMp": "0",
                "accountType": "UNIFIED",
                "totalAvailableBalance": "3.00326056",
                "accountMMRate": "0",
                "accountMMRateByMp": "0",
                "totalPerpUPL": "0",
                "totalWalletBalance": "3.00326056",
                "accountLTV": "0",
                "totalMaintenanceMargin": "0",
                "totalMaintenanceMarginByMp": "0",
                "coin": [
                    {
                        "availableToBorrow": "3",
                        "bonus": "0",
                        "accruedInterest": "0",
                        "availableToWithdraw": "0",
                        "totalOrderIM": "0",
                        "equity": "0",
                        "totalPositionMM": "0",
                        "usdValue": "0",
                        "spotHedgingQty": "0.01592413",
                        "unrealisedPnl": "0",
                        "collateralSwitch": true,
                        "borrowAmount": "0.0",
                        "totalPositionIM": "0",
                        "walletBalance": "0",
                        "cumRealisedPnl": "0",
                        "locked": "0",
                        "marginCollateral": true,
                        "coin": "BTC",
                        "spotBorrow": "0"
                    }
                ]
            }
        ]
    },
    "retExtInfo": {},
    "time": 1690872862481
}
```
Field definitions:
- Account level (result.list[]): `totalEquity` (USD; sum of asset equity in USD), `totalWalletBalance` (USD), `totalMarginBalance` (= totalWalletBalance + totalPerpUPL), `totalAvailableBalance` (cross margin: totalMarginBalance - Haircut - totalInitialMargin), `totalInitialMargin`, `totalMaintenanceMargin`, `accountIMRate`, `accountMMRate`, `accountType`, `totalPerpUPL`, `accountLTV`.
- Coin level (coin[]): `coin` string; `walletBalance` string; `equity` string (= walletBalance - spotBorrow + unrealisedPnl + option value); `locked` (open spot orders); `unrealisedPnl`; `cumRealisedPnl`; `usdValue`; `totalOrderIM`; `totalPositionIM`; `totalPositionMM`; `borrowAmount`; `spotBorrow`; `accruedInterest`; `collateralSwitch`, `marginCollateral` (boolean).
- **`availableToWithdraw` is deprecated for UNIFIED** (since 9 Jan 2025); docs point to "Get Transferable Amount (Unified)" or "Get All Coins Balance". Do not use it for sizing orders.
- Brief said "coin[] walletBalance": confirmed.

---

## 3. Error codes

From https://bybit-exchange.github.io/docs/v5/error (exact retMsg as listed):

| retCode | retMsg (exact) | Meaning |
|---|---|---|
| 10001 | "Request parameter error" | invalid/malformed param |
| 10002 | "The request time exceeds the time window range." | timestamp outside recv window |
| 10003 | "API key is invalid. Check whether the key and domain are matched" (text truncated on source) | key does not match environment/domain |
| 10004 | "Error sign, please check your signature generation algorithm." | bad signature |
| 10005 | "Permission denied, please check your API key permissions." | key lacks permission |
| 10006 | "Too many visits. Exceeded the API Rate Limit." | rate limit |
| 10016 | "Server error." | internal |
| 110001 | "Order does not exist" | no matching order |
| 110003 | "Order price exceeds the allowable range" | price out of bounds |
| 110004 | "Wallet balance is insufficient" | |
| 110007 | "Available balance is insufficient" | available (not total) balance |
| 110017 | "orderQty will be truncated to zero" | **brief said "reduce-only": docs say this message is for qty rounding to zero by qtyStep.** Reduce-only error text: not in the fetched table; **UNVERIFIED** |
| 110025 | "Position mode has not been modified." | |
| 110043 | "Set leverage has not been modified." | |
| 110072 | "OrderLinkedID is duplicate" | |
| 110079 | "The order is processing and can not be operated, please try again later" | **brief said "post-only would take": docs text is "order is processing". Post-only reject is `EC_PostOnlyWillTakeLiquidity` in the RejectReason enum, not a retCode.** |
| 170213 | "Order does not exist." | Spot |

Implementation implication: 110017 and 110079 must be matched on their docs meanings; post-only crossing is detected from `rejectReason == EC_PostOnlyWillTakeLiquidity` on the order (WS or realtime), not from retCode.

---

## 4. Enums (https://bybit-exchange.github.io/docs/v5/enum)

- **OrderStatus**: `New` (open), `PartiallyFilled` (open), `Untriggered` (conditional created, open), `Rejected` (closed), `PartiallyFilledCanceled` (spot only), `Filled` (closed), `Cancelled` (closed; derivatives may show executed qty), `Triggered` (transient), `Deactivated` (UTA spot TP/SL/OCO cancelled before trigger).
- **TimeInForce**: `GTC`, `IOC`, `FOK`, `PostOnly`, `RPI`.
- **OrderType**: `Market`, `Limit`; `UNKNOWN` appears in responses, not valid as request.
- **Side**: `Buy`, `Sell` (enum page does not define Side; values from endpoint docs).
- **PositionIdx**: `0`, `1`, `2`.
- **StopOrderType**: `TakeProfit`, `StopLoss`, `TrailingStop`, `Stop`, `PartialTakeProfit`, `PartialStopLoss`, `tpslOrder`, `OcoOrder`, `MmRateClose`, `BidirectionalTpslOrder`.
- **RejectReason**: `EC_NoError`, `EC_PostOnlyWillTakeLiquidity`, `EC_NoEnoughQtyToFill`, `EC_NoImmediateQtyToFill`, `EC_QtyCannotBeZero`, `EC_LimitOrderInvalidPrice`, `EC_ReachRiskPriceLimit`, `EC_OrderNotExist`, `EC_BySelfMatch`, `EC_CancelByMMP`, ... (full list on enum page; the rest are not needed for linear basics).
- **ExecType**: `Trade`, `AdlTrade`, `Funding`, `BustTrade`, `Delivery`, `Settle`, `BlockTrade`, `MovePosition`, `FutureSpread`, `ForwardSplitSettle`, `ReverseSplitSettle`, `UNKNOWN`.
- **TickDirection**: `PlusTick`, `ZeroPlusTick`, `MinusTick`, `ZeroMinusTick`.

---

## 5. WebSocket: connection, subscribe, heartbeat

Endpoints (per brief): public `wss://stream.bybit.com/v5/public/linear`, private `wss://stream.bybit.com/v5/private`.

Subscribe request:
```json
{ "req_id": "test", "op": "subscribe", "args": ["orderbook.1.BTCUSDT", "publicTrade.BTCUSDT", "orderbook.1.ETHUSDT"] }
```
`req_id` optional.

Subscribe ack (shapes from the docs' connect page):
- Private: `{"success": true, "ret_msg": "", "op": "subscribe", "conn_id": "cejreassvfrsfvb9v1a0-2m"}`
- Public (spot example in docs): `{"success": true, "ret_msg": "subscribe", "conn_id": "2324d924-aa4d-45b0-a858-7b8be29ab52b", "req_id": "10001", "op": "subscribe"}`
- Public linear-specific ack: **UNVERIFIED** (the docs show spot example only; treat as the same shape).

Failure response shape: **UNVERIFIED**.

Ping:
```json
{ "req_id": "100001", "op": "ping" }
```
`req_id` optional. Pong responses:
- Public linear/inverse: `{"success": true, "ret_msg": "pong", "conn_id": "465772b1-7630-4fdc-a492-e003e6f0f260", "req_id": "", "op": "ping"}`
- Private: `{"req_id": "test", "op": "pong", "args": ["1675418560633"], "conn_id": "cfcb4ocsvfriu23r3er0-1b"}`
- Public spot: `{"success": true, "ret_msg": "pong", "conn_id": "0970e817-426e-429a-a679-ff7f55e0b16a", "op": "ping"}`

Heartbeat rule: send `{"op":"ping"}` **every 20 seconds** (docs: "we recommend that you send the ping heartbeat packet every 20 seconds"). Without ping/pong or server data, the connection is cut after **10 minutes** by default. Private streams and order entry accept `max_active_time` query param from 30s to 600s (e.g. `?max_active_time=1m`). Disconnect timing is not exact (ticker scans every 30s).

Limits: do not connect/disconnect frequently; no more than 500 connections per 5 minutes per WS domain; public args array length must not exceed 21,000 characters per connection (for linear: no args-count limit stated).

Snapshot vs delta and reconnection: on reconnect, re-subscribe and treat the next snapshot as authoritative.

---

## 6. WebSocket public topics

### 6.1 orderbook: `orderbook.{depth}.{symbol}`

- Depth values on docs page: **1, 50, 200, 1000** for linear/inverse/spot; 25, 100 for option. **500 is NOT listed for linear.** Brief asked for 500: **UNVERIFIED / not in docs**.
- Subscribe example: `"orderbook.1.BTCUSDT"`. Docs example uses `orderbook.50.BTCUSDT`.
- Behavior: first message is a `snapshot`, then `delta` messages on changes. A new `snapshot` means reset the local book. `u == 1` on a snapshot indicates a service restart: overwrite the local book.
- Delta apply: for each `[price, size]`: if size == "0", delete the price level; if price is new, insert; if existing, replace size.

Snapshot example (docs; `...` in the source denotes omitted levels, shown here as-is):
```json
{
  "topic": "orderbook.50.BTCUSDT",
  "type": "snapshot",
  "ts": 1672304484978,
  "data": {
    "s": "BTCUSDT",
    "b": [ ["16493.50", "0.006"], ["16493.00", "0.100"] ],
    "a": [ ["16611.00", "0.029"], ["16612.00", "0.213"] ],
    "u": 18521288,
    "seq": 7961638724
  },
  "cts": 1672304484976
}
```
Delta example (docs):
```json
{
  "topic": "orderbook.50.BTCUSDT",
  "type": "delta",
  "ts": 1687940967466,
  "data": {
    "s": "BTCUSDT",
    "b": [
      ["30247.20", "30.028"],
      ["30245.40", "0.224"],
      ["30242.10", "1.593"],
      ["30240.30", "1.305"],
      ["30240.00", "0"]
    ],
    "a": [
      ["30248.70", "0"],
      ["30249.30", "0.892"],
      ["30249.50", "1.778"],
      ["30249.60", "0"],
      ["30251.90", "2.947"],
      ["30252.20", "0.659"],
      ["30252.50", "4.591"]
    ],
    "u": 177400507,
    "seq": 66544703342
  },
  "cts": 1687940967464
}
```
Fields: `topic`, `type` (`snapshot|delta`), `ts` (ms, system generated), `data.s`, `data.b` (`[price,size]` string pairs, descending), `data.a` (ascending), `data.u` (update id), `data.seq` (cross sequence), `cts` (matching engine ms).

Subscribe JSON for orderbook: confirmed format is the general subscribe above (docs show pybit only for orderbook).

### 6.2 publicTrade: `publicTrade.{symbol}`

Subscribe: `{"op":"subscribe","args":["publicTrade.BTCUSDT"]}` (general format; docs show pybit only).

Message (docs):
```json
{
    "topic": "publicTrade.BTCUSDT",
    "type": "snapshot",
    "ts": 1672304486868,
    "data": [
        {
            "T": 1672304486865,
            "s": "BTCUSDT",
            "S": "Buy",
            "v": "0.001",
            "p": "16578.50",
            "L": "PlusTick",
            "i": "20f43950-d8dd-5b31-9112-a178eb6023af",
            "BT": false,
            "seq": 1783284617
        }
    ]
}
```
Fields in `data[]`:
- `T` number (ms, fill time)
- `s` string
- `S` string: taker side `Buy|Sell`
- `v` string: trade size
- `p` string: trade price
- `L` string: tick direction (enum `PlusTick|ZeroPlusTick|MinusTick|ZeroMinusTick`)
- `i` string: trade ID
- `BT` boolean: block trade
- `RPI` boolean: RPI trade (in field table; **not present in the example**; presence **UNVERIFIED**)
- `seq` integer: cross sequence
- Top-level: `topic`, `type` (`snapshot`), `ts`.
- Up to 1024 trades per message; multiple messages may share a `seq`. Data sorted by fill time ascending.

### 6.3 tickers: `tickers.{symbol}`

- Push frequency: 100 ms for derivatives.
- Subscribe: `{"op":"subscribe","args":["tickers.BTCUSDT"]}` (general format).
- Snapshot (docs, linear perpetual):
```json
{
  "topic": "tickers.BTCUSDT",
  "type": "snapshot",
  "data": {
    "symbol": "BTCUSDT",
    "tickDirection": "MinusTick",
    "price24hPcnt": "-0.158315",
    "lastPrice": "66666.60",
    "prevPrice24h": "79206.20",
    "highPrice24h": "79266.30",
    "lowPrice24h": "65076.90",
    "prevPrice1h": "66666.60",
    "markPrice": "66666.60",
    "indexPrice": "115418.19",
    "openInterest": "492373.72",
    "openInterestValue": "32824881841.75",
    "turnover24h": "4936790807.6521",
    "volume24h": "73191.3870",
    "fundingIntervalHour": "8",
    "fundingCap": "0.005",
    "nextFundingTime": "1760342400000",
    "fundingRate": "-0.005",
    "bid1Price": "66666.60",
    "bid1Size": "23789.165",
    "ask1Price": "66666.70",
    "ask1Size": "23775.469",
    "preOpenPrice": "",
    "preQty": "",
    "curPreListingPhase": ""
  },
  "cs": 9532239429,
  "ts": 1760325052630
}
```
- Delta: `type` = `"delta"` is listed, **no delta example in docs (UNVERIFIED shape)**. Rule (docs): "If a response param is not found in the message, then its value has not changed." So merge: keep previous values for absent fields.
- `cs` = cross sequence (integer); `ts` ms.

---

## 7. WebSocket private topics

Auth must be sent first on the private connection, then subscribe.

### 7.1 Auth

```json
{
    "req_id": "10001",
    "op": "auth",
    "args": [
        "api_key",
        1662350400000,
        "signature"
    ]
}
```
- Args: `[apiKey, expires, signature]`. Docs call the first arg `api_key` (name in docs text); the brief used `apiKey` in the description (value is the key; name is positional).
- `expires`: integer ms, **greater than current timestamp**. Docs example: `int((time.time() + 1) * 1000)`.
- `signature` = lowercase hex of HMAC_SHA256(key=apiSecret, msg = "GET/realtime" + str(expires)). (Docs Python example.)
- Auth success/failure response: the docs connect page does not show the auth ack body; the private subscribe ack example is `{"success": true, "ret_msg": "", "op": "subscribe", "conn_id": "..."}`. **Auth ack body UNVERIFIED** (assumed `{"success":true,"op":"auth",...}`).
- Note: the auth page (/docs/v5/websocket/private/auth) returned 404 during fetch; info above is from the general connect page.

### 7.2 order: `order` (all-in-one) or `order.linear`

Subscribe: `{"op":"subscribe","args":["order"]}` or `["order.linear"]`. All-in-one and categorised topics cannot be mixed in one request (per docs for execution/position; order docs state the categorised topic names).

Message (docs example, `category: option` payload; field names identical for linear):
```json
{
    "id": "5923240c6880ab-c59f-420b-9adb-3639adc9dd90",
    "topic": "order",
    "creationTime": 1672364262474,
    "data": [
        {
            "symbol": "ETH-30DEC22-1400-C",
            "orderId": "5cf98598-39a7-459e-97bf-76ca765ee020",
            "side": "Sell",
            "orderType": "Market",
            "cancelType": "UNKNOWN",
            "price": "72.5",
            "qty": "1",
            "orderIv": "",
            "timeInForce": "IOC",
            "orderStatus": "Filled",
            "orderLinkId": "",
            "lastPriceOnCreated": "",
            "reduceOnly": false,
            "leavesQty": "",
            "leavesValue": "",
            "cumExecQty": "1",
            "cumExecValue": "75",
            "avgPrice": "75",
            "blockTradeId": "",
            "positionIdx": 0,
            "cumExecFee": "0.358635",
            "closedPnl": "0",
            "createdTime": "1672364262444",
            "updatedTime": "1672364262457",
            "rejectReason": "EC_NoError",
            "stopOrderType": "",
            "tpslMode": "",
            "triggerPrice": "",
            "takeProfit": "",
            "stopLoss": "",
            "tpTriggerBy": "",
            "slTriggerBy": "",
            "tpLimitPrice": "",
            "slLimitPrice": "",
            "triggerDirection": 0,
            "triggerBy": "",
            "closeOnTrigger": false,
            "category": "option",
            "placeType": "price",
            "smpType": "None",
            "smpGroup": "0",
            "smpOrderId": "",
            "feeCurrency": "",
            "cumFeeDetail": { "MNT": "0.00242968" },
            "rpiTakerAccess": false,
            "rpiMatchedQty": "0"
        }
    ]
}
```
Key fields for linear (data[]): `orderId`, `orderLinkId`, `orderStatus` (enum section 4), `cumExecQty`, `cumExecValue`, `avgPrice` (`""` if none), `leavesQty`, `price`, `qty`, `side`, `orderType`, `timeInForce`, `reduceOnly`, `rejectReason`, `closedPnl` (string; realised PnL on this order; present on order topic, **not** on execution topic), `createdTime`, `updatedTime` (ms strings), `positionIdx`, `category`, `symbol`, `cumExecFee` (deprecated for linear; use `cumFeeDetail`), `cumFeeDetail`, `tpslMode`, `triggerPrice`, `triggerBy`, `takeProfit`, `stopLoss`, `closeOnTrigger`, `smpType`.
Top-level: `id`, `topic`, `creationTime` (ms).

### 7.3 execution: `execution` or `execution.linear`

Subscribe: `{"op":"subscribe","args":["execution"]}`. Categorised: `execution.linear`.

Message (docs):
```json
{
    "topic": "execution",
    "id": "386825804_BTCUSDT_140612148849382",
    "creationTime": 1746270400355,
    "data": [
        {
            "category": "linear",
            "symbol": "BTCUSDT",
            "closedSize": "0.5",
            "execFee": "26.3725275",
            "execId": "0ab1bdf7-4219-438b-b30a-32ec863018f7",
            "execPrice": "95900.1",
            "execQty": "0.5",
            "execType": "Trade",
            "execValue": "47950.05",
            "feeRate": "0.00055",
            "tradeIv": "",
            "markIv": "",
            "blockTradeId": "",
            "markPrice": "95901.48",
            "indexPrice": "",
            "underlyingPrice": "",
            "leavesQty": "0",
            "orderId": "9aac161b-8ed6-450d-9cab-c5cc67c21784",
            "orderLinkId": "",
            "orderPrice": "94942.5",
            "orderQty": "0.5",
            "orderType": "Market",
            "stopOrderType": "UNKNOWN",
            "side": "Sell",
            "execTime": "1746270400353",
            "isLeverage": "0",
            "isMaker": false,
            "seq": 140612148849382,
            "marketUnit": "",
            "execPnl": "0.05",
            "createType": "CreateByUser",
            "extraFees": [ { "feeCoin": "USDT", "feeType": "GST", "subFeeType": "IND_GST", "feeRate": "0.0000675", "fee": "0.006403779" } ],
            "feeCurrency": "USDT"
        }
    ]
}
```
Fields (data[]): `execId`, `execPrice`, `execQty`, `execFee`, `feeRate`, `execType`, `execValue`, `isMaker` (boolean), `side`, `orderId`, `orderLinkId`, `execTime` (ms string), `closedSize`, `orderPrice`, `orderQty`, `orderType`, `leavesQty`, `markPrice`, `seq`, `execPnl` (present in example; not in the docs' field table), `createType`, `extraFees`, `feeCurrency`, `category`, `symbol`.
- No `closedPnl` on execution topic; use `closedPnl` on order topic.

### 7.4 position: `position` or `position.linear`

Subscribe: `{"op":"subscribe","args":["position"]}`.

Message (docs):
```json
{
    "id": "1003076014fb7eedb-c7e6-45d6-a8c1-270f0169171a",
    "topic": "position",
    "creationTime": 1697682317044,
    "data": [
        {
            "positionIdx": 2,
            "tradeMode": 0,
            "riskId": 1,
            "riskLimitValue": "2000000",
            "symbol": "BTCUSDT",
            "side": "",
            "size": "0",
            "entryPrice": "0",
            "leverage": "10",
            "breakEvenPrice": "93556.73034991",
            "positionValue": "0",
            "positionBalance": "0",
            "markPrice": "28184.5",
            "positionIM": "0",
            "positionIMByMp": "0",
            "positionMM": "0",
            "positionMMByMp": "0",
            "takeProfit": "0",
            "stopLoss": "0",
            "trailingStop": "0",
            "unrealisedPnl": "0",
            "curRealisedPnl": "1.26",
            "cumRealisedPnl": "-25.06579337",
            "sessionAvgPrice": "0",
            "createdTime": "1694402496913",
            "updatedTime": "1697682317038",
            "tpslMode": "Full",
            "liqPrice": "0",
            "bustPrice": "",
            "category": "linear",
            "positionStatus": "Normal",
            "adlRankIndicator": 0,
            "autoAddMargin": 0,
            "leverageSysUpdatedTime": "",
            "mmrSysUpdatedTime": "",
            "seq": 8327597863,
            "isReduceOnly": false
        }
    ]
}
```
- `avgPrice` is **not** a field here. Use `entryPrice` (average entry). `sessionAvgPrice` is a USDC contract field.
- Other fields: `symbol`, `side` (`Buy` long, `Sell` short, `""` empty), `size` (string, positive), `unrealisedPnl`, `cumRealisedPnl`, `leverage`, `liqPrice`, `positionValue`, `positionIdx` (0/1/2), `positionStatus` (`Normal|Liq|Adl`), `markPrice`, `createdTime`, `updatedTime`.

### 7.5 wallet: `wallet`

Subscribe: `{"op":"subscribe","args":["wallet"]}`.

Message (docs, abridged):
```json
{
  "id": "592324d2bce751-ad38-48eb-8f42-4671d1fb4d4e",
  "topic": "wallet",
  "creationTime": 1700034722104,
  "data": [
    {
      "accountType": "UNIFIED",
      "totalEquity": "10262.91335023",
      "totalWalletBalance": "9684.46297164",
      "totalMarginBalance": "9684.46297164",
      "totalAvailableBalance": "9556.6056555",
      "coin": [
        {
          "coin": "BTC",
          "equity": "0.00102964",
          "walletBalance": "0.00102964",
          "locked": "0",
          "borrowAmount": "0",
          "spotBorrow": "0"
        }
      ]
    }
  ]
}
```
- Top-level fields are the same names as REST account-level (section 2.12). Coin-level fields as REST: `coin`, `equity`, `walletBalance`, `locked`, `usdValue`, `borrowAmount`, `spotBorrow`, `accruedInterest`, `totalOrderIM`, `totalPositionIM`, `totalPositionMM`, `unrealisedPnl`, `cumRealisedPnl`, `collateralSwitch`, `marginCollateral`.
- No snapshot is sent on subscribe; unrealised PnL changes do not trigger an event (docs).
- Deprecated: `availableToWithdraw`, `free`, `availableToBorrow`.

---

## 8. Brief items: status

| Brief item | Status |
|---|---|
| instruments-info lotSizeFilter qtyStep/minOrderQty, priceFilter tickSize, leverageFilter | Confirmed |
| orderbook s, b, a, ts, u, seq | Confirmed (plus cts) |
| tickers lastPrice, markPrice, bid1Price, ask1Price, fundingRate | Confirmed; linear-specific example UNVERIFIED (inverse shown) |
| order/create fields and response orderId, orderLinkId | Confirmed |
| create-batch | Confirmed (spot example; linear example UNVERIFIED) |
| cancel (orderId or orderLinkId) | Confirmed |
| cancel-all | Confirmed |
| amend | Confirmed |
| order/realtime orderStatus, cumExecQty, avgPrice, leavesQty | Confirmed; enum from /enum page |
| execution/list execId, execPrice, execQty, execFee, isMaker, side | Confirmed; **closedPnl NOT present** (use closedSize; closedPnl on order WS) |
| position/list size, side, avgPrice, unrealisedPnl, leverage, liqPrice, positionValue | Confirmed except: field is `avgPrice` in REST; in WS it is `entryPrice`. Linear example UNVERIFIED (inverse shown) |
| wallet-balance UNIFIED totalEquity, totalWalletBalance, totalMarginBalance, coin[] walletBalance | Confirmed |
| Error codes | Confirmed; 110017 and 110079 messages differ from brief (see section 3) |
| Auth headers and HMAC | Confirmed; recv-window max UNVERIFIED |
| Public topics orderbook.1/50/200/500 | 500 NOT in docs for linear (1, 50, 200, 1000 listed) |
| publicTrade fields T,s,S,v,p,L,i,BT | Confirmed; RPI listed in table, not in example |
| tickers snapshot/delta | Snapshot confirmed; delta example UNVERIFIED (merge rule confirmed) |
| subscribe JSON and ack | Confirmed (general, not per-topic) |
| ping/pong and 20s heartbeat | Confirmed |
| Private auth op | Confirmed; ack body UNVERIFIED; auth page 404, content from connect page |
| Private order/execution/position/wallet topics | Confirmed (example payloads fetched) |

---

## 9. UNVERIFIED items (consolidated)

1. Error envelope shape for non-zero retCode (no error example fetched).
2. Recv window maximum value (docs give default 5000 only).
3. Exact encoding of queryString in the signed GET string (percent-encoding; assumed sign exactly what is sent).
4. Linear-specific examples for tickers, position/list, create-batch (only inverse/spot examples fetched).
5. Reduce-only rejection retCode/message (110017 is the qty-to-zero message in docs).
6. Orderbook WS depth 500 for linear (docs list 1, 50, 200, 1000).
7. Public WS subscribe ack for linear (spot example shown); WS subscribe failure response shape.
8. Private WS auth ack body.
9. Ticker WS delta message example (rule only).
10. publicTrade `RPI` field presence in payloads.
11. Rate limit numbers (/docs/v5/rate-limit not fetched).
12. Production host behavior (docs examples use testnet host).
13. Position list: the brief's `avgPrice` on REST confirmed; WS uses `entryPrice`.

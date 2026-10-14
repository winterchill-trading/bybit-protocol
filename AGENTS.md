# AGENTS.md

## Purpose

Bybit v5 wire types, JSON codecs and HMAC-SHA256 signing for REST and websocket auth, for the
`linear` category (USDT perpetuals). No I/O: a client or simulator uses these types to talk to
the API, and `docs/bybit-v5-spec.md` records the shapes they follow.

## Layout

| Path | Holds |
| --- | --- |
| `lib/` | Library `bybit_protocol`: primitives, REST envelope and request types, websocket messages, `Codec`, `Signature` (see `lib/AGENTS.md`) |
| `test/` | Expect and Quickcheck tests, recorded-minute decoding (see `test/AGENTS.md`) |
| `docs/` | `bybit-v5-spec.md`: the reference notes the types follow (see `docs/AGENTS.md`) |
| `.github/` | CI workflow (see `.github/AGENTS.md`) |
| `dune-project`, `bybit-protocol.opam` | Package metadata; the `.opam` file is generated from `dune-project` |

There are no binaries.

## Build, test, docs

Run from this directory. The workspace root `..` holds the sibling checkouts and the shared
`dune-workspace`.

```sh
opam exec --switch 5.2.0+ox -- dune build --root .. @bybit-protocol/all
opam exec --switch 5.2.0+ox -- dune build --root .. @bybit-protocol/runtest
DUNE_BUILD_DIR=_build-bybit-protocol opam exec --switch 5.2.0+ox -- dune build --root .. @bybit-protocol/all
```

The last line is for parallel work: a private build directory avoids the lock shared with
other repositories in the workspace.

Standalone (outside the workspace), the `Build` section of `README.md` lists the opam pins
(`fixed-decimal`, `exchange-core`) and the install commands.

## Conventions

- Formatting: `dune build --root .. @bybit-protocol/fmt --auto-promote`, run after the tests
  pass. Never `dune fmt` at the workspace root; it reformats every sibling repository.
- Every module has an `.mli`. Use `open! Core`, labelled arguments and `ppx_jane`.
- Fields Bybit sends as `""` for "absent", or as either an int or a string, use `Or_empty` and
  `As_string` codecs, so a round trip keeps the shape the venue sent.
- Primitives come from `exchange-core` with type equalities. Do not define a second copy.
- Mark every unverified shape `UNVERIFIED` in the source; the README lists them.
- Document every public value in its `.mli` with odoc comments.

## Dependencies and dependents

- Depends on: `fixed-decimal`, `exchange-core` (and `cryptokit` for HMAC).
- Used by: `bybit-sim`, `bybit-client`, `market-maker`.
- CI pin order: `fixed-decimal`, `exchange-core`.

## CI

`.github/workflows/ci.yml` runs the `ox-setup` action with the two pins above (its opam switch
is cached between runs), then `dune build` and `dune test`. The `obj-magic` job calls the
shared reusable workflow, which fails on `Obj.magic`, `Obj.repr` or `Obj.obj` in the sources.
To check a run: `gh run list --limit 1`, then at most one `gh run watch <id> --exit-status`.
Do not poll in a loop.

## Pitfalls

- Order and execution ids are UUID strings on Bybit, not integers. A venue adapter keeps its own
  id type and maps to the shared core only where the id is numeric.
- Timestamps arrive as both ints and strings, and `""` stands for an absent value. Use
  `Or_empty` and the string-tolerant codecs.
- Public and private pongs have different shapes. Decode both into one variant.
- The error envelope's `result` may be `{}` or `null`, so errors are not decoded from it.
- Linear examples for tickers, position lists and create-batch were checked against inverse and
  spot examples only. Treat those shapes as `UNVERIFIED`.
- A reduce-only rejection uses retCode 110017 because the docs give no dedicated code.
- Public trades may lack the `RPI` flag; decode it as optional.

## Where to read more

- `README.md` (module table, `UNVERIFIED` list, differences from the Bybit API).
- `docs/bybit-v5-spec.md`.
- `../specs/repos/bybit-protocol.md` for status and dependencies.
- Skills in `../oxcaml-claude-skills/skills/`: `janestreet-ocaml-style`.
- `../oxcaml-claude-skills/AGENTS.md`: the workspace-wide guide.
- `../oxcaml-claude-skills/GOTCHAS.md`: the dated log these pitfalls come from.

## Never do

- Run `opam install`, `opam upgrade` or `opam pin` on the shared `5.2.0+ox` switch without a
  dry run first: `opam install --switch 5.2.0+ox --dry-run <pkg>`. Abort if the plan touches
  `ocaml-variants`, `core`, `base`, `async` or `ppx_jane`.
- Publish, tag or release a version from this repository without the maintainers asking.
- Commit credentials or print secrets.
- Poll CI in a loop.

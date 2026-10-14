# AGENTS.md (test/)

Expect and Quickcheck tests for the codecs, the envelope and signing.

- `test_recorded_minute.ml` decodes a recorded minute of mainnet frames in `test/fixtures/`.
  Fixtures are data; do not edit them by hand.
- `test_signature.ml` pins signing against known inputs. Change it only with a reason.
- Promote expect output with `dune promote` only after reading the diff.
- Run: `dune build --root .. @bybit-protocol/runtest` from the repository root.

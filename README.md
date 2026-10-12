# bybit-protocol

Bybit v5 wire types and JSON codecs (category `linear`, USDT perpetuals).

Built with [OxCaml](https://oxcaml.org) and the Jane Street library stack (Base, Core, Async).

## Build

```sh
opam switch create 5.2.0+ox --repos ox=git+https://github.com/oxcaml/opam-repository.git,default
opam pin add fixed-decimal https://github.com/winterchill-trading/fixed-decimal.git --no-action
opam pin add exchange-core https://github.com/winterchill-trading/exchange-core.git --no-action
opam install . --deps-only --with-test
dune build && dune test
```

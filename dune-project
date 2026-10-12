(lang dune 3.17)

(name bybit-protocol)

(generate_opam_files true)

(license MIT)

(maintainers "winterchill-trading")

(authors "winterchill-trading")

(source
 (github winterchill-trading/bybit-protocol))

(package
 (name bybit-protocol)
 (synopsis "Bybit v5 wire types and JSON codecs")
 (depends
  (ocaml
   (>= 5.2))
  dune
  core
  cryptokit
  fixed-decimal
  exchange-core
  ppx_jane
  ppx_yojson_conv
  yojson))

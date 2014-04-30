# Signaturex [![Build Status](https://travis-ci.org/edgurgel/signaturex.svg?branch=master)](https://travis-ci.org/edgurgel/signaturex)

Simple key/secret based authentication for APIs.

Totally based on https://github.com/mloughran/signature

## Usage

Client side:

```elixir
params = %{ q: "asdaf" }
signed_params = Signaturex.sign("key", "secret", :put, "/some/path", params)
params = Dict.merge(signed_params, params)
query_string = URI.encode_query(params)
HTTPsomething.put("/some/path?" <> query_string)
```

Server side:

```elixir
Signaturex.validate("key", "secret", :put, "/some/path", params) # Will return true or false
```

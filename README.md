# Signaturex

Simple key/secret based authentication for APIs.

Totally based on https://github.com/mloughran/signature

## Usage

Client side:

```elixir
signed_params = Signaturex.sign("key", "secret", :put, "/some/path", [q: "asdaf"])
query_string = URI.encode_query(signed_params)
  HTTPsomething.put("/some/path?" <> query_string)
```

Server side:

```elixir
Signaturex.validate("key", "secret", :put, "/some/path", params) # Will return true or false
```

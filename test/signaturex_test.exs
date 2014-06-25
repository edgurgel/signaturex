defmodule SignaturexTest do
  use ExUnit.Case, async: true
  alias Signaturex.Time
  alias Signaturex.AuthenticationError
  import Signaturex
  import :meck

  defp hash_with_string_keys(hash) do
    Enum.traverse(hash, fn { k, v } -> { to_string(k), v } end)
  end

  setup do
    new Time
    expect(Time, :stamp, 0, 1234)
    on_exit fn -> unload end
    :ok
  end

  test "sign with string method" do
    signed_params = sign("key", "secret", "post",
                         "/some/path", %{ query: "params", go: "here" })

    assert signed_params == %{"auth_version" => "1.0", "auth_key" => "key", "auth_signature" => "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db", "auth_timestamp" => 1234}

    assert validate Time
  end

  test "sign with atom method" do
    signed_params = sign("key", "secret", :post,
                         "/some/path", %{ query: "params", go: "here" })

    assert signed_params == %{"auth_version" => "1.0", "auth_key" => "key", "auth_signature" => "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db", "auth_timestamp" => 1234}

    assert validate Time
  end

  test "sign with query params with capitalised letters" do
    signed_params = sign("key", "secret", "post",
                         "/some/path", %{ "Query" => "params",
                                          "Go" => "here" })

    assert signed_params == %{"auth_version" => "1.0", "auth_key" => "key", "auth_signature" => "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db", "auth_timestamp" => 1234}

    assert validate Time
  end

  test "sign with query params on arbitrary" do
    signed_params = sign("key", "secret", "post",
                         "/some/path", %{ "Go" => "here",
                                          "query" => "params" })

    assert signed_params == %{"auth_version" => "1.0", "auth_key" => "key", "auth_signature" => "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db", "auth_timestamp" => 1234}

    assert validate Time
  end

  test "validate signature" do
    params = %{ auth_signature: "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db",
                auth_key: "key", auth_timestamp: "1234", auth_version: "1.0",
                query: "params", go: "here" } |> hash_with_string_keys

    assert validate!("key", "secret", "post", "/some/path", params) == true
    assert validate("key", "secret", "post", "/some/path", params) == true
  end

  test "validate invalid signature, invalid version" do
    params = %{ auth_signature: "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db",
                auth_key: "key", auth_timestamp: "1234", auth_version: "2.0",
                query: "params", go: "here" } |> hash_with_string_keys

    assert_raise AuthenticationError, "Invalid auth version", fn ->
      validate!("key", "secret", "post", "/some/path", params)
    end
    refute validate("key", "secret", "post", "/some/path", params)
  end

  test "validate invalid signature, timestamp missing" do
    params = %{ auth_signature: "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db",
                auth_key: "key", auth_version: "1.0",
                query: "params", go: "here" } |> hash_with_string_keys

    assert_raise AuthenticationError, "Timestamp missing", fn ->
      validate!("key", "secret", "post", "/some/path", params)
    end
    refute validate("key", "secret", "post", "/some/path", params)
  end

  test "validate invalid signature, expired timestamp in the future" do
    params = %{ auth_signature: "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db",
                auth_key: "key", auth_timestamp: "20000", auth_version: "1.0",
                query: "params", go: "here" } |> hash_with_string_keys

    assert_raise AuthenticationError, "Auth timestamp expired", fn ->
      validate!("key", "secret", "post", "/some/path", params)
    end
    refute validate("key", "secret", "post", "/some/path", params)
  end

  test "validate invalid signature, expired timestamp in the past" do
    params = %{ auth_signature: "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db",
                auth_key: "key", auth_timestamp: "1", auth_version: "1.0",
                query: "params", go: "here" } |> hash_with_string_keys

    assert_raise AuthenticationError, "Auth timestamp expired", fn ->
      validate!("key", "secret", "post", "/some/path", params)
    end
    refute validate("key", "secret", "post", "/some/path", params)
  end

  test "validate invalid signature, invalid auth key" do
    params = %{ auth_signature: "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db",
                auth_key: "invalid", auth_timestamp: "1234", auth_version: "1.0",
                query: "params", go: "here" } |> hash_with_string_keys

    assert_raise AuthenticationError, "Invalid auth key", fn ->
      validate!("key", "secret", "post", "/some/path", params)
    end
    refute validate("key", "secret", "post", "/some/path", params)
  end

  test "validate invalid signature, auth_signature missing" do
    params = %{ auth_key: "key", auth_timestamp: "1234", auth_version: "1.0",
                query: "params", go: "here" } |> hash_with_string_keys

    assert_raise AuthenticationError, "Auth signature missing", fn ->
      validate!("key", "secret", "post", "/some/path", params)
    end
    refute validate("key", "secret", "post", "/some/path", params)
  end

  test "validate invalid signature, invalid auth signature" do
    params = %{ auth_signature: "9227328392",
                auth_key: "key", auth_timestamp: "1234", auth_version: "1.0",
                query: "params", go: "here" } |> hash_with_string_keys

    assert_raise AuthenticationError, "Invalid auth signature", fn ->
      validate!("key", "secret", "post", "/some/path", params)
    end
    refute validate("key", "secret", "post", "/some/path", params)
  end
end

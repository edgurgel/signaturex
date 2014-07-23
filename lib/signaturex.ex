defmodule Signaturex do
  alias Signaturex.CryptoHelper
  alias Signaturex.Time
  defmodule AuthenticationError do
    defexception message: "Error on authentication"
  end

  @doc """
  Validate request

  Raises an AuthenticationError if the request is invalid
  """
  @spec validate!(binary, binary, binary | atom, binary, Dict.t, integer) :: true
  def validate!(key, secret, method, path, params, timestamp_grace \\ 600) do
    validate_version!(params["auth_version"])
    validate_timestamp!(params["auth_timestamp"], timestamp_grace)
    validate_key!(key, params["auth_key"])
    validate_signature!(secret, method, path, params, params["auth_signature"])

    true
  end

  @doc """
  Validate request

  Returns true or false
  """
  @spec validate(binary, binary, binary | atom, binary, Dict.t, integer) :: boolean
  def validate(key, secret, method, path, params, timestamp_grace \\ 600) do
    try do
      validate!(key, secret, method, path, params, timestamp_grace)
    rescue
      _e in AuthenticationError -> false
    end
  end

  defp validate_version!("1.0"), do: true
  defp validate_version!(_) do
    raise AuthenticationError, message: "Invalid auth version"
  end

  defp validate_timestamp!(_, nil), do: true
  defp validate_timestamp!(nil, _timestamp_grace) do
    raise AuthenticationError, message: "Timestamp missing"
  end
  defp validate_timestamp!(timestamp, timestamp_grace) when is_binary(timestamp) do
    timestamp = timestamp |> String.to_char_list |> List.to_integer
    validate_timestamp!(timestamp, timestamp_grace)
  end
  defp validate_timestamp!(timestamp, timestamp_grace) when is_integer(timestamp) do
    if abs(Time.stamp - timestamp) < timestamp_grace do
      true
    else
      raise AuthenticationError, message: "Auth timestamp expired"
    end
  end

  defp validate_key!(_, nil) do
     raise AuthenticationError, message: "Auth key missing"
  end
  defp validate_key!(key, key), do: true
  defp validate_key!(_key, _auth_key) do
    raise AuthenticationError, message: "Invalid auth key"
  end

  defp validate_signature!(_secret, _method, _path, _params, nil) do
    raise AuthenticationError, message: "Auth signature missing"
  end
  defp validate_signature!(secret, method, path, params, auth_signature) do
    params = build_params(params)
    if auth_signature(secret, method, path, params) == auth_signature do
      true
    else
      raise AuthenticationError, message: "Invalid auth signature"
    end
  end

  @doc """
  Sign a request using `key`, `secret`, HTTP `method`,
  query string `params` and an optional body
  """
  @spec sign(binary, binary, binary | atom, binary, Dict.t) :: Dict.t
  def sign(key, secret, method, path, params) do
    auth_data = auth_data(key)
    params = build_params(params)
    params = Dict.merge(params, auth_data)
    signature = auth_signature(secret, method, path, params)
    Dict.put(auth_data, "auth_signature", signature)
  end

  defp auth_signature(secret, method, path, params) do
    method = method |> to_string |> String.upcase
    to_sign = "#{method}\n#{path}\n#{encode_query(params)}"
    CryptoHelper.hmac256_to_string(secret, to_sign)
  end

  defp encode_query(params) do
    params
      |> Enum.into([])
      |> Enum.sort(fn({k1, _}, {k2, _}) -> k1 <= k2 end)
      |> URI.encode_query
  end

  defp build_params(params) do
    params
      |> Enum.traverse(fn { k, v } ->
           k = k |> to_string |> String.downcase
           { k, v }
         end)
      |> Dict.delete("auth_signature")
  end

  defp auth_data(app_key) do
    %{ "auth_key" => app_key,
       "auth_timestamp" => Time.stamp,
       "auth_version" => "1.0" }
  end

  defmodule Time do
    @spec stamp :: non_neg_integer
    def stamp do
      {mega, sec, _micro} = :os.timestamp()
      mega * 1000000 + sec
    end
  end
end

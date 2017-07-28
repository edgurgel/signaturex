defmodule Signaturex.CryptoHelper do
  @doc """
  Compute a SHA-256 MAC message authentication code from app_secret and data to sign.
  """
  @spec hmac256_to_string(binary, binary) :: binary
  def hmac256_to_string(app_secret, to_sign) do
    :crypto.hmac(:sha256, app_secret, to_sign)
    |> hexlify
    |> :string.to_lower
    |> List.to_string
  end

  @doc """
  Compute a MD5, convert to hexadecimal and downcase it.
  """
  @spec md5_to_string(binary) :: binary
  def md5_to_string(data) do
    data
    |> md5
    |> hexlify
    |> :string.to_lower
    |> List.to_string
  end

  @doc """
  Constant time string comparison
  """
  def identical?(<<>>, false),  do: false
  def identical?(<<>>, <<>>),  do: true
  def identical?(string1, string2) when byte_size(string1) != byte_size(string2), do: false
  def identical?(<<_head :: binary-size(1), tail :: binary>>, false), do: identical?(tail, false)
  def identical?(<<head :: binary-size(1), tail1 :: binary>>, <<head :: binary-size(1), tail2 :: binary>>), do:
    identical?(tail1, tail2)
  def identical?(<<_head1 :: binary-size(1), tail1 :: binary>>, <<_head2 :: binary-size(1), _tail2 :: binary>>), do:
    identical?(tail1, false)

  defp md5(data), do: :crypto.hash(:md5, data)
  defp hexlify(binary) do
    :lists.flatten(for b <- :erlang.binary_to_list(binary), do: :io_lib.format("~2.16.0B", [b]))
  end
end

defmodule Signaturex.CryptoHelperTest do
  use ExUnit.Case, async: true
  import Signaturex.CryptoHelper

  test "hmac256_to_string" do
    assert hmac256_to_string("7ad3773142a6692b25b8", "1234.1234:private-foobar") == "58df8b0c36d6982b82c3ecf6b4662e34fe8c25bba48f5369f135bf843651c3a4"
  end

  test "md5_to_string" do
    assert md5_to_string("The quick brown fox jumps over the lazy dog") == "9e107d9d372bb6826bd81d3542a419d6"
  end

  test "constant time string compare" do
    string1 = "1111111111111111111111111111111111111111111111111111111111111111"
    string2 = "2222222222222222222222222222222222222222222222222222222222222222"
    {time1, false} = :timer.tc(Kernel, :==, [string1, string2])
    {time2, false} = :timer.tc(Signaturex.CryptoHelper, :identical?, [string1, string2])
    assert time2 > time1
    assert identical?(string1, string1)
    assert identical?(string2, string2)
  end
end

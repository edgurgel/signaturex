defmodule Signaturex.Mixfile do
  use Mix.Project

  @description """
  Simple key/secret based authentication for APIs
  """

  def project do
    [ app: :signaturex,
      name: "Signaturex",
      description: @description,
      elixir: "~> 0.14.1 or ~> 0.15.0 or ~> 1.0.0",
      version: "0.0.9",
      package: package,
      deps: deps ]
  end

  def application, do: []

  defp deps do
    [ { :meck, "~> 0.8.2", only: :test } ]
  end

  defp package do
    [ contributors: ["Eduardo Gurgel"],
      licenses: ["MIT"],
      links: [ { "Github", "https://github.com/edgurgel/signaturex" } ] ]
  end

end

defmodule Signaturex.Mixfile do
  use Mix.Project

  @description """
  Simple key/secret based authentication for APIs
  """

  def project do
    [ app: :signaturex,
      name: "Signaturex",
      description: @description,
      elixir: "~> 0.14.1 or ~> 0.15.0",
      version: "0.0.8",
      package: package,
      deps: deps ]
  end

  def application, do: []

  defp deps do
    [ { :meck, github: "eproxus/meck", ref: "69f02255a8219185bf55da303981d86886b3c24b", only: :test } ]
  end

  defp package do
    [ contributors: ["Eduardo Gurgel"],
      licenses: ["MIT"],
      links: [ { "Github", "https://github.com/edgurgel/signaturex" } ] ]
  end

end

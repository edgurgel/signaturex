defmodule Signaturex.Mixfile do
  use Mix.Project

  def project do
    [ app: :signaturex,
      version: "0.0.1",
      elixir: "~> 0.12.5",
      deps: deps(Mix.env) ]
  end

  def application, do: []

  defp deps(:test) do
    [ { :meck, github: "eproxus/meck", tag: "0.8" } ]
  end
  defp deps(_), do: []

end

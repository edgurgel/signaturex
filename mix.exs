defmodule Signaturex.Mixfile do
  use Mix.Project

  @description """
  Simple key/secret based authentication for APIs
  """

  def project do
    [ app: :signaturex,
      name: "Signaturex",
      description: @description,
      elixir: "~> 1.10",
      version: "1.4.0",
      package: package(),
      deps: deps(),
      source_url: "https://github.com/edgurgel/signaturex" ]
  end

  def application do
    [ extra_applications: [:crypto] ]
  end

  defp deps do
    [{ :meck, "~> 0.9.2", only: :test },
     { :earmark, "~> 1.0", only: :dev },
     { :ex_doc, "~> 0.16", only: :dev }]
  end

  defp package do
    [ maintainers: ["Eduardo Gurgel"],
      licenses: ["MIT"],
      links: %{ "Github" => "https://github.com/edgurgel/signaturex" } ]
  end
end

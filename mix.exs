defmodule UUUIDv7.MixProject do
  use Mix.Project

  def project do
    [
      app: :uuuidv7,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "UUUIDv7",
      source_url: "https://github.com/dkuku/uuuidv7"
    ]
  end

  defp description() do
    "UUUIDv7 stands for microUUIDv7 - a version 7 UUID with submicrosecond precision"
  end

  defp package() do
    [
      name: "uuuidv7",
      files: ~w(lib test mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/dkuku/uuuidv7"}
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, "~> 0.30", only: :dev, runtime: false}
    ]
  end
end

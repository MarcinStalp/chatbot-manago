defmodule ChatbotManago.MixProject do
  use Mix.Project

  def project do
    [
      app: :chatbot_manago,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      escript: escript_config(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ChatbotManago, []},
      extra_applications: [:logger, :httpoison, :jason]
    ]
  end

  defp escript_config do
    [
      main_module: ChatbotManago
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.4"}
    ]
  end
end


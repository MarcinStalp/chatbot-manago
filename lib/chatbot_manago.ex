# Definicja modułu głównego aplikacji ChatbotManago
defmodule ChatbotManago do
  # Użycie Application do uruchomienia aplikacji jako nadzorowanej
  use Application

  # Ustawienie podstawowego adresu API serwera
  @api_base "http://127.0.0.1:11434/api"

  ### START APLIKACJI ###
  
  # Funkcja uruchamiająca aplikację
  def start(:normal, _args) do
    # Inicjalizacja Agenta przechowującego historię zapytań
    Agent.start_link(fn -> [] end, name: :query_history)

    # Sprawdzenie trybu pracy aplikacji (interaktywny vs skryptowy)
    if System.get_env("ESCRIPT_MODE") do
      # Skryptowy tryb pracy
      IO.puts("ChatbotManago uruchomiony.")
      main(System.argv())  # Przetworzenie argumentów wejściowych
      System.halt(0)       # Zakończenie procesu po wykonaniu zadania
    else
      # Tryb interaktywny
      IO.puts("ChatbotManago uruchomiony w trybie interaktywnym.")
      {:ok, self()}  # Zwrócenie referencji procesu dla systemu nadzorującego
    end
  end

  ### PRZETWARZANIE ARGUMENTÓW WEJŚCIOWYCH ###

  # Funkcja główna przetwarzająca argumenty podane w skrypcie
  def main(args) do
    # Parsowanie argumentów wejściowych z użyciem OptionParser
    {opts, _, _} = OptionParser.parse(args, switches: [
      model: :string,   # Określenie modelu do użycia
      prompt: :string,  # Przekazanie zapytania do modelu
      list: :boolean,   # Wyświetlenie listy dostępnych modeli
      show: :string,    # Wyświetlenie informacji o modelu
      pull: :string,    # Pobranie modelu z serwera
      history: :boolean # Wyświetlenie historii zapytań
    ])

    # Obsługa opcji na podstawie przetworzonych argumentów
    cond do
      opts[:list] -> list()                              # Lista dostępnych modeli
      opts[:model] && opts[:prompt] -> ask_model(opts[:model], opts[:prompt])
      opts[:show] -> show(opts[:show])                  # Szczegóły modelu
      opts[:pull] -> pull(opts[:pull])                  # Pobranie modelu
      opts[:history] -> history()                       # Historia zapytań
      true -> IO.puts("Niepoprawne argumenty. Użyj --help dla więcej informacji.")
    end
  end

  ### LISTOWANIE MODELI ###

  # Funkcja pobierająca listę dostępnych modeli z API
  def list do
    url = "#{@api_base}/tags"  # Adres API dla listy modeli

    # Wysłanie zapytania HTTP GET
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # Dekodowanie odpowiedzi JSON i wyświetlenie modeli
        models = Jason.decode!(body)["models"]
        IO.puts("Dostępne modele:")
        Enum.each(models, &IO.puts(&1["name"]))

      # Obsługa błędów połączenia
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Błąd: #{inspect(reason)}")
    end
  end

  ### OBSŁUGA MODELU ###

  # Konwersja danych wejściowych na ciąg znaków (binary)
  defp to_binary(input) when is_list(input), do: List.to_string(input)
  defp to_binary(input), do: input

  # Ustawienie modelu jako bieżącego
  def model(name), do: set_current_model(to_binary(name))

  defp set_current_model(name) do
    # Przechowywanie nazwy modelu w procesie
    Process.put(:current_model, name)
    IO.puts("[Connected to model #{name}]")
  end

  ### WYSYŁANIE ZAPYTAŃ ###

  # Wysłanie zapytania do modelu
  def ask(prompt), do: execute_ask(to_binary(prompt))

  # Wykonanie zapytania przy użyciu aktualnego modelu
  defp execute_ask(prompt) do
    case Process.get(:current_model) do
      nil -> IO.puts("Brak połączenia z modelem. Użyj model/1.")
      model -> ask_model(model, prompt)
    end
  end

  # Wysłanie zapytania POST do API
  defp ask_model(model, prompt) do
    url = "#{@api_base}/generate"
    body = Jason.encode!(%{model: model, prompt: prompt})
    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.post(url, body, headers, [stream_to: self()]) do
      {:ok, %HTTPoison.AsyncResponse{id: id}} -> handle_ask_stream(id, prompt, "")
      {:error, %HTTPoison.Error{reason: reason}} -> IO.puts("Błąd: #{inspect(reason)}")
    end
  end

  ### OBSŁUGA ODPOWIEDZI ###

  defp handle_ask_stream(id, prompt, response) do
    receive do
      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
        response_data = Jason.decode!(chunk)["response"] || ""
        new_response = response <> response_data
        handle_ask_stream(id, prompt, new_response)

      %HTTPoison.AsyncEnd{id: ^id} ->
        IO.puts("#{response}\nZapytanie zakończone.")
        record_history(prompt, response)

    after
      20_000 -> IO.puts("Czas oczekiwania na odpowiedź minął.")
    end
  end

  ### HISTORIA ZAPYTAŃ ###

  # Wyświetlenie historii zapytań
  def history do
    Agent.get(:query_history, & &1)
    |> Enum.each(fn %{"prompt" => prompt, "response" => response} ->
      IO.puts("""
      {
        "prompt": "#{prompt}",
        "response": "#{response}"
      }
      """)
    end)
  end

  # Zapisanie zapytania do historii
  defp record_history(prompt, response) do
    Agent.update(:query_history, fn history ->
      [%{"prompt" => prompt, "response" => response} | history]
    end)
  end

  ### INFORMACJE O MODELU ###

  def show(model), do: fetch_model_info(to_binary(model))

  defp fetch_model_info(model) do
    url = "#{@api_base}/show"
    body = Jason.encode!(%{model: model})
    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        response = Jason.decode!(response_body)
        IO.inspect(response, label: "Informacje o modelu #{model}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Błąd: #{inspect(reason)}")
    end
  end

  ### POBIERANIE MODELU ###

  def pull(model), do: fetch_model(to_binary(model))

  defp fetch_model(model) do
    url = "#{@api_base}/pull"
    body = Jason.encode!(%{model: model})
    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.post(url, body, headers, [stream_to: self()]) do
      {:ok, %HTTPoison.AsyncResponse{id: id}} -> handle_pull_stream(id)
      {:error, %HTTPoison.Error{reason: reason}} -> IO.puts("Błąd pobierania: #{inspect(reason)}")
    end
  end

  # Obsługa pobierania strumieniowego
  defp handle_pull_stream(id) do
    receive do
      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
        response = Jason.decode!(chunk)
        status = response["status"] || "Nieznany"
        IO.puts("Status pobierania: #{status}")
        handle_pull_stream(id)

      %HTTPoison.AsyncEnd{id: ^id} ->
        IO.puts("Pobieranie zakończone.")
    after
      20_000 -> IO.puts("Czas oczekiwania na odpowiedź minął.")
    end
  end
end

# chatbot-manago

ChatbotManago to aplikacja napisana w Elixirze, służąca do zarządzania modelami sztucznej inteligencji oraz interakcji z nimi poprzez API. Aplikacja może działać zarówno w trybie interaktywnym, jak i skryptowym, co czyni ją elastycznym narzędziem do integracji z innymi systemami lub samodzielnego użytkowania.

Funkcje
- Interaktywna obsługa zapytań do modeli AI.
- Tryb skryptowy do automatycznego przetwarzania zapytań z linii komend.
- Zarządzanie modelami AI, w tym:
  - Listowanie dostępnych modeli.
  - Pobieranie szczegółowych informacji o modelach.
  - Pobieranie modeli z serwera.
  - Wysyłanie zapytań do wybranego modelu.
- Zapisywanie historii zapytań i odpowiedzi w pamięci aplikacji.
- Strumieniowa obsługa odpowiedzi API, co pozwala na płynne odbieranie wyników.

Architektura
Aplikacja korzysta z wbudowanego modułu Application, dzięki czemu działa jako nadzorowany proces Elixira. Działa w dwóch trybach:

1. Tryb interaktywny: umożliwia komunikację z użytkownikiem w czasie rzeczywistym.
2. Tryb skryptowy: pozwala na wywoływanie funkcji aplikacji za pomocą argumentów z linii komend.

Moduły i funkcjonalności
1. Start aplikacji
  - Inicjalizacja Agenta (:query_history) do przechowywania historii zapytań.
  - Obsługa dwóch trybów pracy: interaktywnego i skryptowego.
2. Parsowanie argumentów
  - OptionParser analizuje argumenty wejściowe i przekazuje je do odpowiednich funkcji.
3. Zarządzanie modelami
 - list/0: Pobiera listę dostępnych modeli z API.
 - show/1: Wyświetla szczegóły wybranego modelu.
 - pull/1: Pobiera model z serwera.
4. Interakcja z modelami
- ask/1: Wysyła zapytanie do bieżącego modelu.
- Strumieniowe odbieranie odpowiedzi (handle_ask_stream/3).
5. Historia zapytań
- Przechowuje zapytania i odpowiedzi w pamięci aplikacji.
- history/0: Wyświetla całą historię zapytań.
6. Obsługa błędów
- Wszystkie operacje API są opakowane w obsługę błędów i timeoutów.

Wymagania
- Elixir
- Zewnętrzne biblioteki:
  - HTTPoison: do wysyłania zapytań HTTP.
  - Jason: do obsługi JSON.

Przykłady użycia
1. Uruchomienie w trybie interaktywnym:

iex -S mix

Użycie funkcji w sesji interaktywnej:

ChatbotManago.list()
ChatbotManago.ask("Czym jest AI?")

2. Tryb skryptowy:
   
elixir chatbot_manago.exs --list
elixir chatbot_manago.exs --model gpt-3 --prompt "Czym jest AI?"

3. Historia zapytań

ChatbotManago.history()

Struktura API
Aplikacja korzysta z API o poniższych punktach końcowych:
  - GET /api/tags: Pobiera listę modeli.
  - POST /api/generate: Wysyła zapytanie do modelu i generuje odpowiedź.
  - POST /api/show: Pobiera szczegóły dotyczące wybranego modelu.
  - POST /api/pull: Pobiera model z serwera.

Instalacja
1. Sklonuj repozytorium:

git clone https://github.com/twoje-repozytorium/chatbot-manago.git

2. Zainstaluj zależności

mix deps.get

3. Uruchom aplikację:

iex -S mix

Dalsze plany
- Dodanie możliwości konfiguracji poprzez pliki YAML lub JSON.
- Integracja z dodatkowymi systemami API.
- Rozbudowa historii o możliwość zapisu do pliku.

Licencja
Projekt jest dostępny na licencji MIT.

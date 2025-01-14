# ChatbotManago

ChatbotManago to aplikacja Elixir umożliwiająca interakcję z modelami AI poprzez API. Aplikacja obsługuje dwa tryby działania: **interaktywny** i **skryptowy**.

---

## Tryby działania

### Tryb interaktywny
Tryb interaktywny jest używany do długotrwałego działania aplikacji, np. w sesji `iex`. Umożliwia dynamiczne wywoływanie funkcji i interakcję z aplikacją w czasie rzeczywistym.

**Uruchomienie:**
```bash
iex -S mix
```

**Przykład użycia w trybie interaktywnym:**
```elixir
list  # Wyświetla listę dostępnych modeli
model "llama3.2:latest" # Wybiera wskazany model
show "llama3.2:latest" # Wyswietla szczegółowe informacje o wybranym modelu
ask "Jaka jest stolica Francji?"  # Wysyła zapytanie
history  # Wyświetla historię zapytań
pull "llama3.2:latest" # Pobiera wskazany model z serwera
```

---

### Tryb skryptowy
Tryb skryptowy umożliwia jednorazowe wykonanie poleceń. Jest idealny do automatyzacji zadań w skryptach lub terminalu.

**Uruchomienie:**
```bash
elixir ./chatbot_manago [opcje]
```

**Przykład użycia w trybie skryptowym:**
```bash
./chatbot_manago --model=llama3.2 --prompt="2+2"
```

---

## Opcje dostępne w trybie skryptowym

| Opcja          | Opis                                                       | Przykład                                              |
|-----------------|-----------------------------------------------------------|------------------------------------------------------|
| `--list`       | Wyświetla listę dostępnych modeli.                         | `./chatbot_manago --list`                           |
| `--model`      | Wybiera model do wysłania zapytania.                       | `./chatbot_manago --model=llama3.2`                 |
| `--prompt`     | Wysyła zapytanie do modelu.                                | `./chatbot_manago --model=llama3.2 --prompt="2+2"`  |
| `--show`       | Wyświetla szczegółowe informacje o wskazanym modelu.       | `./chatbot_manago --show=llama3.2`                  |
| `--pull`       | Pobiera model z serwera.                                   | `./chatbot_manago --pull=llama3.2`                  |
| `--history`    | Wyświetla historię zapytań.                                | `./chatbot_manago --history`                        |

---

## Przykłady pełnego użycia

### Wyświetlenie listy dostępnych modeli
```bash
./chatbot_manago --list
```
**Przykładowy wynik:**
```
Dostępne modele:
1. llama3.2
2. bert-base
3. gpt-neo
```

---

### Zadanie pytania do modelu
```bash
./chatbot_manago --model=llama3.2 --prompt="Jaka jest stolica Polski?"
```
**Przykładowy wynik:**
```
Warszawa
Zapytanie zakończone.
```

---

### Wyświetlenie szczegółowych informacji o modelu
```bash
./chatbot_manago --show=llama3.2
```
**Przykładowy wynik:**
```json
{
  "name": "llama3.2",
  "description": "Model językowy trenujący na dużych zestawach danych",
  "version": "3.2",
  "parameters": {
    "max_tokens": 1000,
    "temperature": 0.7
  }
}
```

---

### Pobranie modelu z serwera
```bash
./chatbot_manago --pull=llama3.2:latest
```
**Przykładowy wynik:**
```
ChatbotManago uruchomiony w trybie interaktywnym.
Status pobierania: pulling manifest
Status pobierania: pulling dde5aa3fc5ff
Status pobierania: pulling 966de95ca8a6
Status pobierania: pulling fcc5a6bec9da
Status pobierania: pulling a70ff7e570d9
Status pobierania: pulling 56bb8bd477a5
Status pobierania: pulling 34bb5ab01051
Status pobierania: verifying sha256 digest
Status pobierania: writing manifest
Status pobierania: success
Pobieranie zakończone.
```

---

### Wyświetlenie historii zapytań
```bash
./chatbot_manago --history
```
**Przykładowy wynik:**
```
{
  "prompt": "Jaka jest stolica Polski?",
  "response": "Warszawa"
}
{
  "prompt": "2+2",
  "response": "4"
}
```

---

# Assistente Alimentare Monorepo

![CI](https://img.shields.io/badge/CI-placeholder-lightgrey)

Questo repository ospita la piattaforma **Assistente Alimentare**, organizzata come monorepo Flutter/Dart.

## Requisiti

- iOS 17+
- Android API level 28+
- Dart 3 e Flutter 3

## Struttura

- `app/`: applicazione Flutter principale.
- `packages/`: pacchetti Dart modularizzati (core, data, domini e funzionalità).
- `test/`: cartelle per i test unitari, widget e di integrazione.
- `.github/workflows/`: configurazioni CI.
- `assets/`: segnaposto grafici forniti in formato Base64 (`*.png.base64`).

## Setup

1. Posizionarsi nella cartella `app/`.
2. Installare le dipendenze: `flutter pub get`.
3. Generare il codice: `dart run build_runner build -d`.
4. Analizzare il progetto: `flutter analyze`.
5. Eseguire la suite di test: `flutter test`.
6. Avviare l'app: `flutter run`.

## Packaging (zip & base64)

Eseguire i comandi dalla root del repository:

```bash
zip -r assistente_alimentare.zip .
base64 assistente_alimentare.zip > assistente_alimentare.zip.b64
base64 -d assistente_alimentare.zip.b64 > assistente_alimentare.zip
unzip assistente_alimentare.zip
```

## Variabili d'ambiente

- Copiare il file `.env.sample` nella root del progetto e rinominarlo in `.env` per configurare gli strumenti da riga di comando.
- Copiare `app/.env.sample` in `app/.env` per l'esecuzione dell'app Flutter.
- Impostare le chiavi API richieste (`OFF_API_KEY`, `FDC_API_KEY`, `EDAMAM_API_KEY`). I pacchetti che utilizzano `HttpClient` leggeranno automaticamente i valori disponibili tramite `flutter_dotenv`.

## Asset segnaposto

- `assets/placeholder.png.base64` contiene una PNG 1×1 bianca da generare con `base64 --decode assets/placeholder.png.base64 > assets/placeholder.png`.
- `assets/icons/app_icon.png.base64` e `assets/icons/app_icon_dark.png.base64` sono icone minime 1×1 da generare con `base64 --decode` nei rispettivi percorsi.
- I file binari risultanti (`*.png`) sono ignorati da Git per evitare la condivisione di asset binari direttamente nel repository.

## Prossimi passi

- Collegare gradualmente l'app ai pacchetti modulari.
- Aggiungere dipendenze e codice sorgente nei rispettivi pacchetti quando disponibile.
- Configurare strumenti di gestione monorepo (es. Melos) se necessario.

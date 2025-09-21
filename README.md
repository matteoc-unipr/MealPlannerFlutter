# Assistente Alimentare Monorepo

Questo repository ospita la piattaforma **Assistente Alimentare**, organizzata come monorepo Flutter/Dart.

## Struttura

- `app/`: applicazione Flutter principale.
- `packages/`: pacchetti Dart modularizzati (core, data, domini e funzionalità).
- `test/`: cartelle per i test unitari, widget e di integrazione.
- `.github/workflows/`: configurazioni CI.

## Sviluppo

1. Posizionarsi nella cartella `app/` per eseguire i comandi Flutter standard (`flutter run`, `flutter test`, ecc.).
2. Ogni pacchetto in `packages/` possiede un `pubspec.yaml` per consentirne l'evoluzione indipendente.
3. I flussi CI eseguono `flutter pub get`, `dart run build_runner build -d`, `flutter analyze` e `flutter test` sull'app principale.

## Variabili d'ambiente

- Copiare il file `.env.sample` nella root del progetto e rinominarlo in `.env` per configurare gli strumenti da riga di comando.
- Copiare `app/.env.sample` in `app/.env` per l'esecuzione dell'app Flutter.
- Impostare le chiavi API richieste (`OFF_API_KEY`, `FDC_API_KEY`, `EDAMAM_API_KEY`). I pacchetti che utilizzano `HttpClient` leggeranno automaticamente i valori disponibili tramite `flutter_dotenv`.

## Prossimi passi

- Collegare gradualmente l'app ai pacchetti modulari.
- Aggiungere dipendenze e codice sorgente nei rispettivi pacchetti quando disponibile.
- Configurare strumenti di gestione monorepo (es. Melos) se necessario.

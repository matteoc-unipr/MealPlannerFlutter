# app_intents

Gestione unificata degli intent dell'app Assistente Alimentare.

## Intents disponibili

| Classe Dart           | ID            | Deep link                       | Descrizione breve                         |
| --------------------- | ------------- | ------------------------------- | ----------------------------------------- |
| `AddMealIntent`       | `add_meal`    | `assistente://meals/add`        | Apre la schermata di aggiunta di un pasto |
| `SuggestLunchIntent`  | `suggest_lunch` | `assistente://suggestions/lunch` | Mostra un suggerimento rapido per il pranzo |

Gli intent possono essere attivati dal Dart tramite `AppIntentController`:

```dart
final controller = AppIntentController();
await controller.trigger(const AddMealIntent());
```

Il controller invia il messaggio sul canale `app_intents/intents` con il metodo
`triggerIntent`. Il payload è una `Map<String, dynamic>` compatibile con
`AppIntent.toMap()`.

## Shortcut Android

Per generare la configurazione da passare a `ShortcutManager` è sufficiente
invocare `toAndroidShortcut()` sull'intent desiderato:

```dart
const intent = AddMealIntent();
final shortcut = intent.toAndroidShortcut(iconName: 'ic_shortcut_add_meal');
```

Il risultato è una mappa con i campi principali attesi da
`ShortcutInfo.Builder` (`id`, `shortLabel`, `longLabel`, `intentAction`, `uri`,
`categories`, `keywords`). I valori sono pronti per essere convertiti in un
`Intent` che punta al deep link `assistente://...` gestito dal router Flutter.

## Stub iOS

L'integrazione iOS utilizza lo stesso canale `app_intents/intents`. Il target
WidgetKit/Intents Extension deve registrare un handler per il metodo
`triggerIntent` che costruisce un `INShortcut` (o un'`NSUserActivity`) a partire
dal deep link presente nel payload. Finché l'implementazione nativa non è
presente, il fallback Dart logga l'azione tramite `debugPrint`, permettendo di
eseguire i test senza compilare codice Swift/Objective-C.

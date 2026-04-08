# 🏎️ F1 Show Mobile

Aplicação Flutter que espelha a aplicação web F1 Show, consumindo a [Ergast Mirror API](https://api.jolpi.ca/ergast/f1) e integrada com **Firebase Analytics**.

---

## 📱 Telas

| Tela | Rota | Descrição |
|---|---|---|
| Início | `/` | Banner de boas-vindas, última corrida e pódio |
| Resultados | `/results` | Tabela completa da última corrida |
| Temporadas | `/season` | Seletor de ano + lista de corridas + resultados |
| Classificação | `/standings` | Campeonato de pilotos e construtores por ano |
| Piloto | `/driver/:id` | Estatísticas e histórico do piloto |

---

## 🛠️ Tecnologias

| Tecnologia | Versão | Uso |
|---|---|---|
| [Flutter](https://flutter.dev/) | 3.41+ | Framework mobile |
| [Dart](https://dart.dev/) | 3.11+ | Linguagem |
| [go_router](https://pub.dev/packages/go_router) | 17+ | Roteamento declarativo |
| [http](https://pub.dev/packages/http) | 1.6+ | Chamadas à API |
| [firebase_core](https://pub.dev/packages/firebase_core) | 4.6+ | Inicialização Firebase |
| [firebase_analytics](https://pub.dev/packages/firebase_analytics) | 12+ | Analytics de navegação |
| [Ergast Mirror API](https://api.jolpi.ca) | — | Dados da Fórmula 1 |

---

## 🏗️ Arquitetura

```
f1show_mobile/
├── lib/
│   ├── models/
│   │   └── models.dart          # Driver, Race, RaceResult, Standings...
│   ├── services/
│   │   ├── f1_api.dart          # Todas as chamadas à API Ergast
│   │   └── analytics_service.dart # Firebase Analytics
│   ├── screens/
│   │   ├── home_screen.dart     # Rota: /
│   │   ├── results_screen.dart  # Rota: /results
│   │   ├── season_screen.dart   # Rota: /season
│   │   ├── standings_screen.dart# Rota: /standings
│   │   └── driver_detail_screen.dart # Rota: /driver/:id
│   ├── widgets/
│   │   └── widgets.dart         # Componentes reutilizáveis
│   ├── theme/
│   │   └── app_theme.dart       # Tema escuro F1
│   ├── router.dart              # GoRouter + ShellRoute + BottomNav
│   └── main.dart                # Entry point + Firebase.initializeApp()
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

### Fluxo de dados

```
Ergast Mirror API (HTTPS)
        │
        ▼
  F1ApiService (http)
        │
        ├──► HomeScreen       → última corrida + pódio
        ├──► ResultsScreen    → tabela completa
        ├──► SeasonScreen     → corridas por ano
        ├──► StandingsScreen  → pilotos + construtores
        └──► DriverDetailScreen → histórico do piloto
```

### Integração Firebase

```
Firebase.initializeApp()
        │
        └──► AnalyticsService
                ├── logScreenView()   → toda troca de tela
                ├── logDriverView()   → ao abrir perfil de piloto
                ├── logSeasonSelect() → ao trocar ano
                └── logRaceSelect()   → ao selecionar corrida
```

---

## ⚙️ Como rodar

### Pré-requisitos

- [Flutter](https://flutter.dev/docs/get-started/install) >= 3.10
- Android Studio ou VS Code com extensão Flutter
- Conta Firebase com projeto criado

### Configurar Firebase

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Dentro de f1show_mobile/, configurar o projeto Firebase
flutterfire configure
```

Isso gera o arquivo `lib/firebase_options.dart` automaticamente.

Depois atualize o `main.dart`:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Instalar dependências e rodar

```bash
cd f1show_mobile

flutter pub get

# Android
flutter run

# iOS
cd ios && pod install && cd ..
flutter run
```

### Build para produção

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 🌐 API utilizada

**Ergast Mirror API** — `https://api.jolpi.ca/ergast/f1`

| Endpoint | Uso |
|---|---|
| `/current/last/results.json` | Última corrida |
| `/{year}/races.json` | Corridas de uma temporada |
| `/{year}/{round}/results.json` | Resultado de uma corrida |
| `/current/driverStandings.json` | Classificação de pilotos |
| `/current/constructorStandings.json` | Classificação de construtores |
| `/current/drivers/{id}/results.json` | Histórico do piloto |

---

## 📄 Licença

MIT © F1 Show

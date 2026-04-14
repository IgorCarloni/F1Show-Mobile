# 🏎️ F1 Show Mobile

Aplicativo Flutter que exibe resultados, classificações e estatísticas da Fórmula 1, consumindo a [Ergast Mirror API](https://api.jolpi.ca/ergast/f1) com integração ao **Firebase Analytics**.

---

## 📲 Download

> **[⬇️ Baixar APK (Android)](https://github.com/IgorCarloni/F1Show-Mobile/releases/latest/download/app-release.apk)**

---

## 📱 Telas

| Tela | Rota | Descrição |
|---|---|---|
| Início | `/` | Banner de boas-vindas, última corrida e pódio |
| Resultados | `/results` | Tabela completa da última corrida |
| Temporadas | `/season` | Seletor de ano + lista de corridas + resultados |
| Classificação | `/standings` | Campeonato de pilotos e construtores por ano |
| Piloto | `/driver/:id` | Estatísticas e histórico do piloto na temporada atual |

---

## 🛠️ Tecnologias

| Tecnologia | Versão | Uso |
|---|---|---|
| [Flutter](https://flutter.dev/) | 3.41+ | Framework mobile |
| [Dart](https://dart.dev/) | 3.11+ | Linguagem |
| [go_router](https://pub.dev/packages/go_router) | ^17.2.0 | Roteamento declarativo |
| [http](https://pub.dev/packages/http) | ^1.6.0 | Chamadas HTTP à API |
| [firebase_core](https://pub.dev/packages/firebase_core) | ^4.6.0 | Inicialização Firebase |
| [firebase_analytics](https://pub.dev/packages/firebase_analytics) | ^12.2.0 | Analytics de navegação |
| [Ergast Mirror API](https://api.jolpi.ca) | — | Dados da Fórmula 1 |

---

## 🏗️ Arquitetura

```
f1show_mobile/
├── lib/
│   ├── models/
│   │   └── models.dart               # Driver, Race, RaceResult, Standings...
│   ├── services/
│   │   ├── f1_api.dart               # Chamadas à API Ergast (HTTP)
│   │   └── analytics_service.dart    # Firebase Analytics
│   ├── screens/
│   │   ├── home_screen.dart          # Rota: /
│   │   ├── results_screen.dart       # Rota: /results
│   │   ├── season_screen.dart        # Rota: /season
│   │   ├── standings_screen.dart     # Rota: /standings
│   │   └── driver_detail_screen.dart # Rota: /driver/:id
│   ├── widgets/
│   │   └── widgets.dart              # Componentes reutilizáveis
│   ├── theme/
│   │   └── app_theme.dart            # Tema escuro F1
│   ├── router.dart                   # GoRouter + ShellRoute + BottomNav
│   ├── firebase_options.dart         # Gerado pelo FlutterFire CLI
│   └── main.dart                     # Entry point + Firebase.initializeApp()
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
         ├──► HomeScreen            → última corrida + pódio
         ├──► ResultsScreen         → tabela completa da corrida
         ├──► SeasonScreen          → corridas por ano + resultados
         ├──► StandingsScreen       → pilotos + construtores
         └──► DriverDetailScreen    → histórico do piloto
```

### Integração Firebase

```
Firebase.initializeApp()
         │
         └──► AnalyticsService
                  ├── logScreenView()    → toda troca de tela
                  ├── logDriverView()    → ao abrir perfil de piloto
                  ├── logSeasonSelect()  → ao trocar ano na tela Temporadas
                  └── logRaceSelect()    → ao selecionar uma corrida
```

### Roteamento (GoRouter)

```
ShellRoute  ──── BottomNavigationBar
  ├── /                  HomeScreen
  ├── /results           ResultsScreen
  ├── /season            SeasonScreen
  └── /standings         StandingsScreen

Root
  └── /driver/:id        DriverDetailScreen  (sem BottomNav)
```

---

## ⚙️ Como rodar

### Pré-requisitos

- [Flutter](https://flutter.dev/docs/get-started/install) >= 3.10
- Android Studio ou VS Code com extensão Flutter
- Conta Firebase com projeto criado

### 1. Clonar o repositório

```bash
git clone https://github.com/IgorCarloni/F1Show-Mobile.git
cd F1Show-Mobile
```

### 2. Configurar Firebase

```bash
# Instalar FlutterFire CLI (apenas uma vez)
dart pub global activate flutterfire_cli

# Dentro da pasta do projeto, vincular ao seu projeto Firebase
flutterfire configure
```

Isso gera automaticamente o arquivo `lib/firebase_options.dart`.

### 3. Instalar dependências

```bash
flutter pub get
```

### 4. Rodar o app

```bash
# Android
flutter run

# iOS
cd ios && pod install && cd ..
flutter run
```

---

## 📦 Build para produção

```bash
# APK Android
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release

# iOS
flutter build ios --release
```

O APK gerado fica em:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🌐 API utilizada

**Ergast Mirror API** — `https://api.jolpi.ca/ergast/f1`

| Endpoint | Uso |
|---|---|
| `/current/last/results.json` | Última corrida |
| `/{year}/races.json` | Corridas de uma temporada |
| `/{year}/{round}/results.json` | Resultado de uma corrida |
| `/{year}/driverStandings.json` | Classificação de pilotos |
| `/{year}/constructorStandings.json` | Classificação de construtores |
| `/current/drivers/{id}/results.json` | Histórico do piloto |

---

## 📄 Licença

MIT © F1 Show

# project structure overview

here's how we organized the code to keep things clean and easy to find.

```
auto_manager/
├── backend_original/               # python flask server and firebase logic
│   ├── app/                        # main backend application code
│   │   ├── routes/                 # api endpoints (auth, rentals, etc)
│   │   ├── services/               # business logic and helpers
│   │   └── models/                 # data models
│   └── run.py                      # entry point to start the server
│
├── frontend/                       # flutter mobile application
│   ├── assets/                     # images and fonts
│   ├── lib/
│   │   ├── core/                   # global config, services, and utils
│   │   ├── databases/              # local sqlite setup and repo implementations
│   │   │   ├── repo/               # hybrid repositories (sync logic)
│   │   │   └── dbhelper.dart       # database creation and migration
│   │   ├── features/               # app screens and feature-specific code
│   │   │   ├── analytics/
│   │   │   ├── auth/
│   │   │   ├── clients/
│   │   │   ├── dashboard/
│   │   │   ├── rentals/
│   │   │   ├── subscription/
│   │   │   └── vehicles/
│   │   ├── l10n/                   # translation files (en, fr, ar)
│   │   ├── logic/                  # business logic (cubits/blocs)
│   │   └── main.dart               # app entry point and setup
│   ├── test/                       # unit and widget tests
│   └── pubspec.yaml                # dependencies
```

## directory details

- **backend_original/**: holds all the server-side python code. this talks to firebase and handles the master data.
- **frontend/lib/core/**: stuff used everywhere, like api config, network checks, and theme settings.
- **frontend/lib/databases/**: the heart of the offline-first system. `repo/` contains "hybrid" repositories that decide whether to fetch from the server or local db.
- **frontend/lib/features/**: broken down by what the user sees. each folder usually has `presentation/` for screens and `data/` for models.
- **frontend/lib/logic/**: connects the ui to the data. we use cubits here to manage state (like loading, success, error).

## best practices

- **offline first:** always try to save/load from local db if the network is down. the sync service pushes changes later.
- **feature separation:** keep things related to "cars" in the `vehicles` folder, "payments" in the `subscription` folder, etc.
- **clean state:** logic goes in cubits, not inside the ui widgets.
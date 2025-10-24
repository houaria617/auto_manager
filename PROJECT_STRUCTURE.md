
# Project Structure Overview

This project follows a modular, feature-first structure suited for growing Flutter apps. Below is a guide to each directory and its intended use.

```
auto_manager/
├── assets/img/                     # App icons, images and media
├── lib/
│   ├── core/
│   │   ├── common_widgets/         # Shared UI components across features
│   │   ├── config.dart             # App-wide configuration variables
│   │   ├── constants.dart          # Constants shared by the app
│   │   ├── router.dart             # Central navigation and routing
│   │   ├── theme.dart              # App color scheme, themes, and styles
│   │   └── utils.dart              # Utilities and helpers (expand to folder if many utils)
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/               # Data layer (models, repositories, data sources for auth)
│   │   │   ├── domain/             # Auth business logic, entities, use cases
│   │   │   └── presentation/       # Auth UI, screens, widgets
│   │   └── dashboard/              # Placeholder for future dashboard feature
│   └── main.dart                   # App entry point
├── .gitignore                      # Git ignore rules
├── analysis_options.yaml            # Linting and static analysis config
├── pubspec.yaml                    # Dependencies and project config
...
```

## Directory Details

- **assets/img/**: Contains your image files and assets referenced from the app.
- **lib/core/**: Shared resources, config, constants, common widgets, core utilities, central theme, and routing logic.
    - Use files for theme and router for simplicity.
    - Expand utils into a folder if you anticipate many utility functions/files.
- **lib/features/**: Each feature has its own subfolder. Use `data/`, `domain/`, and `presentation/` for Clean Architecture separation within each feature.
    - Currently, only `auth` is populated; others (like `dashboard`) can be added as needed.
- **main.dart**: The main entry file for your Flutter app.

## Best Practices
- Each feature should have subfolders for `data`, `domain`, and `presentation` even if initially sparse—this supports future growth.
- Shared widgets belong in `core/common_widgets` to maximize reuse.
- Keep configuration, theming, and routing logic in single files for clarity—split if complexity increases.
- Utilities remain in a single file unless they grow; then use `core/utils/` as a directory with separate files by concern (date, string, etc).

## Benefits
- **Scalability**: New features and shared resources can be added cleanly.
- **Isolation**: Clear separation of feature and shared app infrastructure.
- **Team Collaboration**: Developers can safely work in parallel by feature.

For detailed onboarding or more advanced patterns, see the main `README.md`.

# auto manager

a smart vehicle rental management system built with flutter and flask. designed to work offline-first, so you can manage your business anywhere, anytime.

## about

this app helps rental agencies manage their fleet, clients, and bookings. it syncs data when you're online but works perfectly when you have no internet.

## tech stack

**frontend (mobile app):**
- flutter (cross-platform ui)
- sqflite (local database for offline mode)
- flutter_bloc (state management)
- workmanager (background data syncing)

**backend (server):**
- flask (python web framework)
- firebase firestore (cloud database)
- jwt (secure authentication)

## features

- **dashboard:** quick look at available cars, active rentals, and recent activity.
- **offline mode:** create rentals and manage clients without internet. changes sync automatically when you reconnect.
- **fleet management:** track vehicle status, maintenance schedules, and pricing.
- **client profiles:** keep track of customer history and contact info.
- **analytics:** visual charts for revenue and rental trends.
- **multi-language:** supports english, french, and arabic.

## setup guide

### 1. backend setup
navigate to the backend folder and install dependencies:
```bash
cd backend_original
pip install -r requirements.txt
python run.py
```
make sure you have your `serviceAccountKey.json` for firebase in the root backend folder.

### 2. frontend setup
navigate to the frontend folder and run the app:
```bash
cd frontend
flutter pub get
flutter run
```

## architecture

we use a "hybrid repository" pattern. this means the app always checks if it can reach the server first. if it can't, it seamlessly falls back to the local database on your phone. background tasks run periodically to push any changes you made while offline up to the cloud.
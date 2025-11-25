# Implementation Plan

## Phase 1: Foundation & Dependencies
- [ ] Add `sqflite` and `path` for local database.
- [ ] Add `http` for API communication.
- [ ] Add `shared_preferences` for simple persistence.
- [ ] Verify `flutter_bloc` usage (already present).

## Phase 2: Local Database (SQLite)
- [ ] Create `DBHelper` class (Singleton pattern).
- [ ] Implement `initDB` with table creation scripts based on `DATABASE_SCHEMA.md`.
    - [ ] Client Table
    - [ ] Agencies Table
    - [ ] Car Table
    - [ ] Rental Table
    - [ ] Payment Table
- [ ] Implement CRUD operations for each entity.

## Phase 3: Repository Pattern
- [ ] Define Abstract Repositories (Interfaces) in `domain` layer.
- [ ] Implement Concrete Repositories in `data` layer.
    - [ ] `AuthRepository`
    - [ ] `CarRepository`
    - [ ] `RentalRepository`
    - [ ] `AgencyRepository`
- [ ] Ensure repositories handle data source switching (Local vs API).

## Phase 4: Backend API (Python/Flask)
- [ ] Setup Python environment.
- [ ] Create Flask app.
- [ ] Define API endpoints matching the entities.
- [ ] Deploy to Serverless (LeapCell/Render).

## Phase 5: Integration
- [ ] Connect Flutter Repositories to Backend APIs.
- [ ] Implement Sync logic (if needed).
- [ ] Integrate Cloud Services (Firebase, Maps, etc.).

# Personal Expense Tracker

A Flutter take-home assignment for a small personal expense tracker. The app focuses on clean structure, local persistence, simple state management, and a polished but lightweight user experience.

## Features

- Add income and expense transactions with title, amount, date, and category.
- Create custom income and expense categories.
- View recent transactions and transactions filtered by selected date.
- View overview totals for income and expenses.
- Filter overview transactions by income or expense.
- Switch the overview chart between weekly, monthly, and yearly summaries.
- Persist transactions and categories locally with Hive.
- Handle empty states, loading states, validation errors, and user feedback.
- Include simple splash and chart animations.

## Tech Stack

- Flutter
- Provider / ChangeNotifier for state management
- Hive / hive_flutter for local persistence
- Repository and DAO layers for data access separation

## Project Structure

```text
lib/
  core/                 Shared colors, strings, formatters, styles, widgets
  data_layer/           Models, mock seed data, repository contract/implementation
  persistence_layer/    Hive constants and DAO classes
  presentation_layer/   Screens, widgets, and feature providers
```

## Architecture Notes

The UI is kept mostly presentational. Screen-specific providers own validation, loading state, save results, and user messages. Shared app state such as tab selection, dashboard totals, overview filters, and chart summaries lives in `AppProvider`.

Hive is initialized before the app starts, and boxes are opened for categories and transactions. The repository delegates persistence to DAO classes, so UI code does not interact with Hive boxes directly.

The app seeds a small set of starter categories and transactions when local storage is empty. After that, user-created data is read from Hive and survives app restarts.

## Offline-First Direction

The current implementation is local-first: Hive is the source used by the app today, and cached data is shown immediately when the app starts. This keeps the app usable after restarts and without network access.

No network API is implemented in this take-home scope, but the repository boundary is designed so a remote data source can be added later. A future sync flow could:

1. Load and display local Hive data first for instant UI.
2. Request fresh data from the network when connectivity is available.
3. Compare local and remote data using timestamps, version fields, or sync metadata.
4. Merge or replace the local cache based on freshness and conflict rules.
5. Notify providers through repository streams so the UI refreshes after local data changes.
6. Continue showing cached data when the network is unavailable or when remote data is not newer.

## Getting Started

Install dependencies:

```sh
flutter pub get
```

Generate Hive adapters if needed:

```sh
dart run build_runner build
```

Run the app:

```sh
flutter run
```

## Verification

Useful checks before submission:

```sh
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

## Trade-offs

- The app intentionally uses Provider and Hive to keep the implementation simple and readable for a 4-6 hour assignment.
- Authentication, cloud sync, and production-grade analytics are out of scope.
- Network sync is intentionally not implemented, but the repository and DAO separation keeps the app ready for a remote data source later.
- The test suite is intentionally lightweight; it focuses on a small amount of meaningful behavior rather than broad coverage.
- The UI includes optional enhancements such as categories, overview filters, summary charts, and animations.

## Future Improvements

- Add edit/delete flows for transactions and categories.
- Add search and richer filtering.
- Add more provider and persistence tests.
- Add screenshot assets or a short demo GIF to this README.

## Demo video link
- https://youtube.com/shorts/ACi_VCghonY?feature=share

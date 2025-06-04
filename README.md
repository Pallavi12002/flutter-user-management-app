# flutter_assignment_task
A new Flutter project.
# Flutter User Management App

A feature-rich Flutter application for managing users, their posts, and todos. Built with Clean Architecture and BLoC pattern.

## Features

- **User Management**
    - List users with pagination
    - Search users by name/email
    - View user details
    - Pull-to-refresh functionality

- **Posts & Todos**
    - View user posts
    - Create new posts (local storage)
    - View and manage todos
    - Mark todos as complete

- **UI/UX**
    - Light/Dark theme support
    - Responsive design
    - Loading indicators
    - Error handling with retry
    - Shimmer effects

- **Technical**
    - Clean Architecture
    - BLoC state management
    - Dio for networking
    - SharedPreferences for caching
    - Pagination and infinite scroll
    - Debounced search

## Project Structure

lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── error/
│   │   └── failures.dart
│   ├── network/
│   │   └── api_client.dart
│   └── utils/
│       └── debouncer.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── post_model.dart
│   │   └── todo_model.dart
│   ├── repositories/
│   │   └── user_repository.dart
│   └── services/
│       └── api_service.dart
├── presentation/
│   ├── bloc/
│   │   ├── user_list/
│   │   │   ├── user_list_bloc.dart
│   │   │   ├── user_list_event.dart
│   │   │   └── user_list_state.dart
│   │   ├── user_detail/
│   │   │   ├── user_detail_bloc.dart
│   │   │   ├── user_detail_event.dart
│   │   │   └── user_detail_state.dart
│   │   └── theme/
│   │       ├── theme_bloc.dart
│   │       ├── theme_event.dart
│   │       └── theme_state.dart
│   ├── pages/
│   │   ├── user_list_page.dart
│   │   ├── user_detail_page.dart
│   │   └── create_post_page.dart
│   └── widgets/
│       ├── user_card.dart
│       ├── search_bar.dart
│       ├── loading_indicator.dart
│       └── error_widget.dart
└── di/
└── injection_container.dart

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio/VSCode with Flutter plugin

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/flutter-user-management-app.git
   Navigate to project directory

bash
cd flutter-user-management-app
Install dependencies

bash
flutter pub get
Generate files (if needed)

bash
flutter pub run build_runner build
Run the app

bash
flutter run

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

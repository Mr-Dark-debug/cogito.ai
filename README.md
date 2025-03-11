# cogito.ai

A modern Flutter application for exploring arXiv research papers with a beautiful glassmorphic UI.

[![Version](https://img.shields.io/badge/version-0.0.1-blue.svg)](https://github.com/pschoudhary-dot/cogito/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

[Download Latest Release](https://github.com/pschoudhary-dot/cogito/releases/latest)

This is an open-source project available on GitHub Packages. You can use this app to explore and manage arXiv research papers with a modern, user-friendly interface.

## Features

- **Modern Glassmorphic UI**: Clean, professional design with glassmorphic effects
- **Powerful Search**: Search arXiv papers with advanced query formatting
- **Category Filtering**: Filter papers by research categories
- **Year & Sort Options**: Filter by year and sort results by relevance or date
- **Paper Collections**: Save papers to custom collections for later reference
- **PDF & Web Viewing**: View papers in PDF format or on the web
- **Infinite Scrolling**: Smooth scrolling through search results
- **Abstract Toggle**: Show or hide paper abstracts in the list view

## Screenshots

*Screenshots will be added soon*

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/pschoudhary-dot/cogito.git
   ```

2. Navigate to the project directory:
   ```
   cd cogito
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Architecture

The app follows a simple but effective architecture:

- **Models**: Data structures for papers, collections, etc.
- **Services**: API communication and data management
- **Screens**: UI implementation
- **Widgets**: Reusable UI components

## Dependencies

```yaml
dependencies:
  flutter_animate: ^1.0.0
  url_launcher: ^6.0.0
  infinite_scroll_pagination: ^3.0.0
  http: ^0.13.0
  xml: ^6.0.0
  provider: ^6.0.0
```

For the complete list of dependencies, see the `pubspec.yaml` file.

## GitHub Packages

This package is available on GitHub Packages. To use it in your project, add the following to your `pubspec.yaml`:

```yaml
dependencies:
  cogito:
    git:
      url: https://github.com/pschoudhary-dot/cogito.git
      ref: v0.0.1  # Specify the version tag
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [arXiv API](https://arxiv.org/help/api/index) for providing access to research papers
- Flutter team for the amazing framework

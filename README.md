# cogito.ai

A modern Flutter application for exploring arXiv research papers with a beautiful glassmorphic UI.

[![Version](https://img.shields.io/badge/version-0.0.1-blue.svg)](https://github.com/pschoudhary-dot/cogito/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/flutter-stable-blue.svg)](https://flutter.dev)

<div align="center">
  <a href="https://github.com/pschoudhary-dot/cogito/releases/latest">
    <img src="https://img.shields.io/badge/-Download%20Latest%20Release-2ea44f?style=for-the-badge" alt="Download Latest Release">
  </a>
</div>

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
   ```bash
   git clone https://github.com/pschoudhary-dot/cogito.git
   ```

2. Navigate to the project directory:
   ```bash
   cd cogito
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Architecture

The app follows a clean architecture pattern:

- **Models**: Data structures for papers and collections
  - `paper.dart`: Paper model with arXiv metadata
  - `collection.dart`: User-created paper collections
  - `saved_paper.dart`: Saved paper references

- **Services**: API communication and data management
  - `arxiv_service.dart`: arXiv API integration
  - `collection_service.dart`: Local collection management

- **Screens**: Main UI implementations
  - `home_screen.dart`: Main search and browse interface
  - `collections_screen.dart`: Manage saved collections
  - `pdf_viewer_screen.dart`: PDF paper viewer
  - `web_viewer_screen.dart`: Web paper viewer
  - `splash_screen.dart`: App launch screen

- **Widgets**: Reusable UI components
  - `loading_indicator.dart`: Custom loading animations

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
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

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your PR description clearly describes the changes and their benefits.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [arXiv API](https://arxiv.org/help/api/index) for providing access to research papers
- Flutter team for the amazing framework
- All contributors who help improve this project

# 🎬 FindMyMovie — Discover Movies Like Never Before

[![Build](https://img.shields.io/github/actions/workflow/status/vansh-121/FindMyMovie/flutter.yml?label=build&logo=githubactions&style=for-the-badge)](https://github.com/vansh-121/FindMyMovie/actions)
[![License](https://img.shields.io/github/license/vansh-121/FindMyMovie?style=for-the-badge)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/vansh-121/FindMyMovie?style=for-the-badge)](https://github.com/vansh-121/FindMyMovie/commits)
[![Platform](https://img.shields.io/badge/platform-Flutter-blue?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Pub Version](https://img.shields.io/pub/v/flutter_bloc?style=for-the-badge)](https://pub.dev/packages/flutter_bloc)

> A sleek and responsive Flutter app to search and explore movies using the TMDb API. Built with BLoC/Cubit for efficient state management.

---

## 📱 Preview

| Home | Search | Movie Detail |
|------|--------|--------------|
| ![Home Screen](screenshots/home.png) | ![Search](screenshots/search.png) | ![Movie Detail](screenshots/detail.png) |

---

## ✨ Features

- 🔍 **Search** movies by title using [TMDb API](https://www.themoviedb.org/documentation/api)
- ⚙️ **BLoC/Cubit** architecture for clean and scalable code
- 📱 Fully **responsive UI** across devices
- 🧩 **Error handling** for a smooth user experience
- 🌙 Light & Dark mode support (customizable)
- 📡 Optimized network handling

---

## 🚀 Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/vansh-121/FindMyMovie.git
cd FindMyMovie
```

### 2.Install dependencies

```bash
flutter pub get
```

### 3. Add your TMDb API key

```bash
const String apiKey = 'your_api_key';
```
👉 Get your API key from TMDb Developer Portal


### 4. Run the app

```bash
flutter run
```


---


## Project Structure :-

```bash
lib/
├── bloc/            # BLoC & Cubit files
├── models/          # Data models
├── repository/      # API services and logic
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── main.dart        # Entry point
```
---

#### Made with ❤️ by Vansh

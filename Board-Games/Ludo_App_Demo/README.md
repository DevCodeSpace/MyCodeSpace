# 🎲 Ludo Kingdom

A modern Flutter implementation of the classic **Ludo** board game, built on the **Flame** game engine with GetX state management. Roll the dice, race your tokens home, and battle friends or AI opponents in a polished, animated arena.

<p align="center">
  <img src="assets/images/image_1.png" alt="Ludo Kingdom Logo" height="220" />
</p>

---

## 📌 Overview

Ludo Kingdom brings the timeless dice-and-board classic to mobile with a dark, neon-accented UI and a rendered game board powered by Flame. Choose from four game modes and play through dice rolling, token movement, captures, and home-run finishes with smooth animated feedback.

---

## 🚀 Features

- 🤖 **VS Computer** — take on 3 AI-controlled opponents
- 👥 **2 / 3 / 4 Player** modes for local pass-and-play matches
- 🎲 **Animated dice rolling** with turn-based flow
- 🧠 **Automatic CPU turns** — AI rolls and moves without manual input
- ♟️ **Flame-powered board** — token and board rendering via the Flame game engine
- 🏆 **Win detection & results screen** once a player brings all tokens home
- 🔊 **Sound effects** via `audioplayers`
- 🎨 **Modern gradient UI** with mode-select cards showing live player/CPU slot indicators

---

## 🛠️ Built With

- **Flutter** & **Dart**
- **GetX** — routing & state management
- **Flame** — 2D game engine for the board/token rendering
- **Google Fonts** — Outfit typeface
- **audioplayers** — in-game sound effects

---

## 📦 Dependencies

- get
- flame
- google_fonts
- audioplayers
- cupertino_icons

---

## 📂 Project Structure

```
lib/app/
├── data/                 # Board constants & game models (GameMode, TokenModel, PlayerModel...)
├── modules/
│   ├── splash/           # Splash screen
│   ├── home/             # Game mode selection
│   ├── game/              # Board, tokens, dice & LudoController (core game logic)
│   └── result/            # Post-match results screen
└── routes/                # GetX app routes
```

---

## ▶️ Getting Started

```bash
flutter pub get
flutter run
```

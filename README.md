# Memory Match Flutter Game

This is a Flutter/Dart solution for Exercise 2: Memory Matching Flutter Game.

## Features

- 4 x 4 memory card grid with 8 matching animal pairs
- Tap cards to flip them
- Matching pairs stay visible
- Non-matching pairs flip back after a short delay
- Move counter, timer, pair counter, restart button
- Win dialog when all pairs are matched
- Responsive layout that works on emulator or Android phone
- Image assets included in `assets/images/`

## How to run

1. Install Flutter SDK and Android Studio.
2. Open this folder in Android Studio.
3. Run `flutter pub get` in the terminal.
4. Start an Android emulator or connect an Android phone.
5. Run `flutter run`.

## Project structure

```text
MemoryMatchFlutter/
  pubspec.yaml
  analysis_options.yaml
  README.md
  README.pdf
  lib/
    main.dart
  assets/
    images/
      animal_cat.png
      animal_dog.png
      animal_fox.png
      animal_koala.png
      animal_lion.png
      animal_panda.png
      animal_rabbit.png
      animal_zebra.png
      card_back.png
  screenshots/
    game_start.png
    game_play.png
    game_win.png
  android/
    app/
      src/main/
        AndroidManifest.xml
        kotlin/com/example/memory_match_flutter/MainActivity.kt
```

## Main code file

The main implementation is in `lib/main.dart`. It defines the app, card model, game state, card matching logic, timer, restart logic, and the user interface.

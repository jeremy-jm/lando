# Lando Dictionary

Cross-platform translation dictionary app built with Flutter/Dart targeting iOS, Android, macOS, Windows, and Linux.

## Cursor Cloud specific instructions

### Prerequisites (already installed in VM snapshot)

- Flutter SDK 3.41.6 at `/opt/flutter/bin` (Dart 3.11.4 included)
- PATH configured in `~/.bashrc`: `export PATH="/opt/flutter/bin:$PATH"`
- Linux desktop build dependencies: `ninja-build`, `libgtk-3-dev`, `libgstreamer1.0-dev`, `libgstreamer-plugins-base1.0-dev`, `libkeybinder-3.0-dev`, `libunwind-dev`, `libstdc++-14-dev`, `lld-18`, `llvm-18`
- Symlink: `/usr/lib/x86_64-linux-gnu/libstdc++.so` → GCC 13's `libstdc++.so` (required by clang linker)
- Symlink: `/usr/lib/llvm-18/bin/ld` → `/usr/bin/ld`

### Key commands

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Lint | `flutter analyze` |
| Tests | `flutter test` |
| Build (debug) | `flutter build linux --debug` |
| Run (dev) | `flutter run -d linux` |
| Build (release) | Requires `sudo` or custom `CMAKE_INSTALL_PREFIX`; use debug build for dev |

### Gotchas

- **Release build permission error**: `flutter build linux` (release) fails at the CMake install step with "Permission denied" trying to copy to `/usr/local/`. Use `flutter build linux --debug` for development.
- **Test suite**: 294+ tests pass, but ~28 tests in `api_client_test.dart` fail because `PreferencesStorage.init()` is not called in test setup. This is a pre-existing issue, not an environment problem.
- **Untranslated messages**: `flutter pub get` will emit warnings about 15 untranslated messages for `hi`, `id`, `ja`, `pt`, `ru` locales. This is expected.
- **No backend service**: This is a client-only app. No databases or backend servers to start.
- **Display required**: `flutter run -d linux` needs a display (the VM has `DISPLAY=:1` configured).
- **Hot reload**: While running with `flutter run -d linux`, press `r` for hot reload, `R` for hot restart.

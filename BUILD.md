# Building Quest 30

This project uses `--dart-define` to inject secrets at build time so they never appear in the repository.

## Required Keys

| Key | Source | Example |
|-----|--------|---------|
| `RC_API_KEY` | RevenueCat Dashboard > Project > API Keys > Apple | `appl_aBcDeFgHiJkLmN` |

## Running Locally (Simulator / Device)

```bash
cd challenge_tracker

flutter run --dart-define=RC_API_KEY=appl_yourkey
```

## Building for Release

```bash
cd challenge_tracker

# iOS release build
flutter build ios --dart-define=RC_API_KEY=appl_yourkey

# Then open in Xcode for signing and archiving
open ios/Runner.xcworkspace
```

## Running Tests

Tests that don't touch RevenueCat work without the key:

```bash
flutter test
```

## Xcode (Running from IDE)

If you run/debug from Xcode instead of the CLI:

1. Open `ios/Runner.xcworkspace`
2. Select the **Runner** scheme > **Edit Scheme...**
3. Under **Run > Arguments > Environment Variables**, add:
   - Name: `RC_API_KEY`  Value: `appl_yourkey`

Note: Xcode environment variables are stored in your local scheme (`.xcscheme`) which is already gitignored.

## VS Code

Add to `.vscode/launch.json`:

```json
{
  "configurations": [
    {
      "name": "Quest 30",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=RC_API_KEY=appl_yourkey"
      ]
    }
  ]
}
```

> `.vscode/` is gitignored by default, so your key stays local.

## What Happens Without the Key

If you forget `--dart-define=RC_API_KEY=...`, the app will throw a `StateError` at startup with a message telling you what to do. The free tier (1 challenge) still works for UI development — the error only fires when `RevenueCatService.init()` is called.

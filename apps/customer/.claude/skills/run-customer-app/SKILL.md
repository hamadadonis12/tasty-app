---
name: run-customer-app
description: Use when an agent needs to build, run, test, take a screenshot of, or otherwise drive the TastyLife customer Flutter app under apps/customer. Covers production onboarding flow, the screen gallery, and the headless screenshot harness used by QA and demos.
---

The TastyLife customer app is a Flutter mobile/web app under [apps/customer](../../..). Two entry points: production (`lib/main.dart` — onboarding → home shell) and gallery (`lib/gallery_app.dart` — browse every Stitch-designed screen). The agent path runs through **`drive.sh`** in this directory, which wraps `flutter build web` + a local static server + headless Chrome so a future agent can analyze, test, build, and **screenshot the running UI without a human in the loop**.

All paths in this document are relative to `apps/customer/`. The driver `cd`s there itself, so you can invoke it from anywhere.

## Prerequisites

Verified on Windows 11 + git-bash. Falls back to `google-chrome` / `chromium` on Linux; macOS untested.

- Flutter 3.41+ (`C:/flutter/bin/flutter.bat` on the verified host, or `flutter` on PATH)
- Google Chrome (the driver auto-detects `C:/Program Files/Google/Chrome/Application/chrome.exe` or `google-chrome`/`chromium` on Linux)
- Python 3 (only used for the static server during screenshots)
- Windows users: **enable Developer Mode** so Flutter can create plugin symlinks during `pub get`. Without it, `pub get` succeeds but you'll see `Building with plugins requires symlink support — enable Developer Mode` warnings. Run: `start ms-settings:developers`

No other system packages required.

## Build

```bash
cd apps/customer
bash .claude/skills/run-customer-app/drive.sh setup     # flutter pub get
bash .claude/skills/run-customer-app/drive.sh analyze   # 0 errors expected; 65 info-level lints are pre-existing
bash .claude/skills/run-customer-app/drive.sh test      # 2/2 passing as of this skill being written
bash .claude/skills/run-customer-app/drive.sh build     # ~2 min cold; produces build/web/
```

## Run — agent path (use this first)

The driver builds the app, serves `build/web/` on `localhost:8765` in the background, takes a headless-Chrome screenshot at iPhone-13 viewport (390×844), and tears the server down on exit. The screenshot path is printed on stdout.

```bash
cd apps/customer
bash .claude/skills/run-customer-app/drive.sh screenshot home
# → /c/Users/User1/Documents/GitHub/tasty-app/apps/customer/.tmp-screens/home.png
```

What the screenshot actually shows: the **production onboarding flow** with the splash auto-advancing after ~1.4s to Splash 2 (the "Get Started / I already have an account" value-prop screen). Because the harness uses Chrome's `--virtual-time-budget=5000`, you reliably catch Splash 2, not the initial flash.

To take multiple shots back-to-back, prefer driving `serve` and `stop` yourself instead of one-shot `screenshot`:

```bash
bash .claude/skills/run-customer-app/drive.sh build           # only the first time
bash .claude/skills/run-customer-app/drive.sh serve           # writes .tmp-server.pid
# ...your loop of chrome --screenshot calls against http://localhost:8765/ ...
bash .claude/skills/run-customer-app/drive.sh stop
```

To override the viewport or port:

```bash
PORT=9090 bash .claude/skills/run-customer-app/drive.sh serve
SCREEN_DIR=docs/qa bash .claude/skills/run-customer-app/drive.sh screenshot baseline
```

`drive.sh doctor` is a one-shot probe: Flutter version, Chrome version, Python version, plus the tail of `flutter doctor`. Use it when something's off.

## Run — human path

For interactive clicking through the app:

```bash
cd apps/customer
bash .claude/skills/run-customer-app/drive.sh dev
# → opens http://localhost:8765 in Chrome with Flutter hot reload
```

Or the screen-by-screen gallery (useful for QA and demos — every Stitch screen is tappable from a single index):

```bash
bash .claude/skills/run-customer-app/drive.sh gallery
```

Both shell out to `flutter run -d chrome --web-port 8765 [-t lib/gallery_app.dart]` and stay attached until you hit `q`. They aren't useful headless — the screenshot path above is for that.

## Direct invocation

There is **no separate CLI entry point**; everything starts at `lib/main.dart` or `lib/gallery_app.dart`. To test internal logic without the full app, the codebase has unit + widget tests in `test/` runnable via `drive.sh test`.

The shared cart logic in [lib/state/cart_controller.dart](../../../lib/state/cart_controller.dart) is a `ChangeNotifier` singleton (`CartController.instance`) — agents adding tests for ordering flows should drive it directly rather than spinning up the full widget tree.

## Gotchas

These cost real time this session — keep them in mind:

- **`chrome.exe --version` returns "Opening in existing browser session"** when an interactive Chrome is already running. It still works for `--screenshot` (each call spawns its own headless instance), but `drive.sh doctor` will show that line instead of a clean version string. Not a bug; just visual noise.
- **`flutter analyze` reports ~65 info-level lints** (`unnecessary_underscores`, deprecated `Radio.groupValue`). They've existed since before this skill — don't waste time chasing them. `drive.sh analyze` only fails on `^  error` lines.
- **Plugin symlink warning** during `pub get` on Windows looks scary (`Building with plugins requires symlink support`) but is non-fatal — the resolve succeeds. Enable Developer Mode in Windows Settings to silence it.
- **The headless screenshot reliably catches Splash 2, not Splash 1.** The driver uses `--virtual-time-budget=5000` and Splash 1's auto-advance timer fires at 1400ms. To snap Splash 1, drop the budget to ~800ms: `chrome ... --virtual-time-budget=800 ...`
- **`flutter build web` is ~2 minutes cold** (118s observed on this box). Subsequent builds are incremental and faster. The `.tmp-screens/` and `.tmp-server.pid` files are produced under `apps/customer/` — they're not gitignored yet, so don't commit them.
- **Restaurant and driver apps each have their own scaffold** at `apps/restaurant` and `apps/driver` but are *not* covered by this skill. They each have one passing widget test. The customer app is what's actually shipped through onboarding → home.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `drive.sh: command not found` | The driver is at `apps/customer/.claude/skills/run-customer-app/drive.sh`. Invoke via `bash .claude/skills/run-customer-app/drive.sh ...` from `apps/customer/`. |
| `chrome-not-found` from `drive.sh doctor` | Chrome isn't at the default Windows path. Edit `chrome_bin()` in `drive.sh` or symlink `chrome.exe` onto PATH. |
| `python-not-found` | Install Python 3 or set `python` on PATH (used only for `python -m http.server`). |
| `flutter analyze` shows errors after a refactor | Check `lib/state/cart_controller.dart` and the screens that import it — the cart is a singleton and any rewire that changes the public `add`/`inc`/`dec`/`remove` API ripples through Restaurant Detail, Customize, Cart, and Checkout. |
| Screenshot is a blank gray rectangle | The Flutter app hasn't hydrated within the virtual-time budget. Increase: `chrome ... --virtual-time-budget=10000 ...` or check that the dev console (run `drive.sh dev` and open Chrome devtools) doesn't show a network error fetching `flutter_bootstrap.js`. |
| `Address already in use` when serving | A previous `serve` orphaned its server. `taskkill //F //PID "$(cat .tmp-server.pid)"` on Windows (or `kill` on Linux), then `rm .tmp-server.pid`. |
| Tests pass locally but fail in CI with `Found 0 widgets with text "TastyLife"` | The widget test in `test/widget_test.dart` asserts on the splash text. If the brand wordmark in `packages/design-tokens/lib/tasty_life_logo.dart` changes, update the test's `find.text(...)` expectations. |

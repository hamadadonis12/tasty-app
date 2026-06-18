#!/usr/bin/env bash
# TastyLife customer app — agent driver.
#
# Subcommands:
#   setup       flutter pub get (idempotent)
#   analyze     flutter analyze lib (errors only — info lints are pre-existing)
#   test        flutter test
#   build       flutter build web (release web bundle into build/web)
#   serve       start a static HTTP server in the background on $PORT
#   stop        stop the background server
#   screenshot  build (if needed) → serve → headless Chrome PNG → stop
#   dev         flutter run -d chrome (PRODUCTION onboarding flow → home)
#   gallery     flutter run -d chrome -t lib/gallery_app.dart (browse all screens)
#   doctor      flutter doctor + tool probes (Chrome, Python)
#
# The script CDs up to apps/customer/ regardless of caller cwd. Output paths
# in messages are absolute so an agent can read them back without computing
# paths.
#
# Verified host: Windows + git-bash, Flutter 3.x, Chrome stable, Python 3.x.
# Falls back to google-chrome / chromium on Linux. macOS is untested.

set -eu

# Walk up to the apps/customer directory regardless of caller cwd.
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT"

# --- Tool probes ------------------------------------------------------------
flutter_bin() {
  if command -v flutter >/dev/null 2>&1; then
    echo "flutter"
  elif [ -x "/c/flutter/bin/flutter.bat" ]; then
    echo "/c/flutter/bin/flutter.bat"
  else
    echo "flutter-not-found" >&2
    return 1
  fi
}

chrome_bin() {
  for p in \
    "/c/Program Files/Google/Chrome/Application/chrome.exe" \
    "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" \
    "$(command -v google-chrome 2>/dev/null || true)" \
    "$(command -v chromium 2>/dev/null || true)" \
    "$(command -v chromium-browser 2>/dev/null || true)"; do
    [ -n "$p" ] && [ -x "$p" ] && { echo "$p"; return 0; }
  done
  echo "chrome-not-found" >&2
  return 1
}

python_bin() {
  for c in python3 python py; do
    command -v "$c" >/dev/null 2>&1 && { echo "$c"; return 0; }
  done
  echo "python-not-found" >&2
  return 1
}

# --- Config -----------------------------------------------------------------
PORT="${PORT:-8765}"
SCREEN_DIR="${SCREEN_DIR:-.tmp-screens}"   # gitignored output dir
SERVER_PID_FILE=".tmp-server.pid"

# --- Subcommands ------------------------------------------------------------
cmd_setup() {
  "$(flutter_bin)" pub get
}

cmd_analyze() {
  # Surface only errors; the project has known info-level lints that pre-date this skill.
  set +e
  output="$("$(flutter_bin)" analyze lib 2>&1)"
  code=$?
  set -e
  echo "$output" | tail -3
  if echo "$output" | grep -E "^  error" >/dev/null 2>&1; then
    echo "::ERROR:: analyze found errors above" >&2
    return 1
  fi
  return 0
}

cmd_test() {
  "$(flutter_bin)" test "$@"
}

cmd_build() {
  "$(flutter_bin)" build web --no-tree-shake-icons
}

cmd_serve() {
  if [ -f "$SERVER_PID_FILE" ] && kill -0 "$(cat "$SERVER_PID_FILE")" 2>/dev/null; then
    echo "server already running pid=$(cat "$SERVER_PID_FILE") port=$PORT"
    return 0
  fi
  if [ ! -d build/web ]; then
    echo "build/web missing — run 'drive.sh build' first" >&2
    return 1
  fi
  ( cd build/web && "$(python_bin)" -m http.server "$PORT" >/dev/null 2>&1 ) &
  pid=$!
  echo "$pid" > "$SERVER_PID_FILE"
  # Wait until the server actually accepts connections (max ~5s).
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    if curl -s -o /dev/null -w "" "http://localhost:$PORT/" 2>/dev/null; then
      echo "server up pid=$pid port=$PORT"
      return 0
    fi
    sleep 0.5
  done
  echo "server failed to bind on port $PORT" >&2
  return 1
}

cmd_stop() {
  if [ -f "$SERVER_PID_FILE" ]; then
    pid=$(cat "$SERVER_PID_FILE")
    if [ -n "$pid" ]; then
      if command -v taskkill >/dev/null 2>&1; then
        taskkill //F //PID "$pid" >/dev/null 2>&1 || true
      else
        kill "$pid" 2>/dev/null || true
      fi
    fi
    rm -f "$SERVER_PID_FILE"
  fi
}

cmd_screenshot() {
  name="${1:-snap}"
  out="${2:-$SCREEN_DIR/$name.png}"
  mkdir -p "$(dirname "$out")"
  if [ ! -d build/web ]; then cmd_build; fi
  cmd_serve
  trap cmd_stop EXIT
  # Convert the bash-style path to a Windows-style path for chrome.exe's
  # --screenshot flag when we're on Windows.
  out_abs="$(cd "$(dirname "$out")" && pwd)/$(basename "$out")"
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      out_for_chrome="$(cygpath -w "$out_abs")" ;;
    *)
      out_for_chrome="$out_abs" ;;
  esac
  "$(chrome_bin)" \
    --headless=new \
    --disable-gpu \
    --no-sandbox \
    --hide-scrollbars \
    --window-size=390,844 \
    --virtual-time-budget=5000 \
    --screenshot="$out_for_chrome" \
    "http://localhost:$PORT/" >/dev/null 2>&1
  echo "$out_abs"
}

cmd_dev() {
  "$(flutter_bin)" run -d chrome --web-port "$PORT"
}

cmd_gallery() {
  "$(flutter_bin)" run -d chrome --web-port "$PORT" -t lib/gallery_app.dart
}

cmd_doctor() {
  echo "--- flutter ---"
  "$(flutter_bin)" --version | head -2
  echo "--- chrome ---"
  "$(chrome_bin)" --version 2>&1 | head -1 || true
  echo "--- python ---"
  "$(python_bin)" --version
  echo "--- flutter doctor ---"
  "$(flutter_bin)" doctor 2>&1 | tail -15
}

# --- Dispatch ---------------------------------------------------------------
cmd="${1:-help}"
shift || true
case "$cmd" in
  setup|analyze|test|build|serve|stop|screenshot|dev|gallery|doctor)
    "cmd_$cmd" "$@"
    ;;
  help|*)
    grep -E "^#( |$)" "$0" | sed 's/^# \{0,1\}//' | head -25
    ;;
esac

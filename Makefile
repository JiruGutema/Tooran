# Tooran — build, test and release.
#
#   make help            list targets
#   make release         build every release artifact into dist/
#   make publish         tag the release and upload dist/ to GitHub
#
# Paths default to the user-local SDKs from the setup; override on the
# command line, e.g. `make apk FLUTTER=/opt/flutter/bin/flutter`.

SHELL := /bin/bash
.DEFAULT_GOAL := help

FLUTTER      ?= $(HOME)/development/flutter/bin/flutter
DART         ?= $(HOME)/development/flutter/bin/dart
export JAVA_HOME ?= $(HOME)/development/jdk-17
export ANDROID_HOME ?= $(HOME)/Android/Sdk
KEYTOOL      ?= $(JAVA_HOME)/bin/keytool

# Version: "x.y.z" from pubspec.yaml. The Android build number (versionCode)
# is date-based so every release is higher than the last one.
VERSION      := $(shell awk '/^version:/ {print $$2}' pubspec.yaml | cut -d'+' -f1)
BUILD        ?= $(shell date +%Y%m%d%H | cut -c3-)
TAG          := v$(VERSION)
DIST         := dist
REPO         ?= JiruGutema/Tooran

BUILD_FLAGS  := --build-name=$(VERSION) --build-number=$(BUILD) \
                --dart-define=APP_VERSION=$(VERSION)

APK_DIR      := build/app/outputs/flutter-apk
AAB          := build/app/outputs/bundle/release/app-release.aab

.PHONY: help setup doctor l10n analyze test check run run-linux \
        apk-debug apk aab linux deb release checksums version keystore \
        check-signing tag publish clean

help: ## Show this help
	@echo "Tooran $(VERSION) (build $(BUILD))"
	@echo
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

# ── Everyday ─────────────────────────────────────────────────────────

setup: ## Fetch packages and generate translations
	$(FLUTTER) pub get
	$(FLUTTER) gen-l10n

doctor: ## Check the Flutter/Android toolchain
	$(FLUTTER) doctor

l10n: ## Regenerate translations from lib/l10n/*.arb
	$(FLUTTER) gen-l10n

analyze: ## Static analysis
	$(FLUTTER) analyze --no-fatal-infos

test: ## Run all tests
	$(FLUTTER) test

check: analyze test ## Analyze + test (run before every release)

run: ## Run on the connected phone (debug)
	$(FLUTTER) run

run-linux: ## Run the desktop app (debug)
	$(FLUTTER) run -d linux

apk-debug: ## Debug APK (installs as "Tooran Dev" next to the real app)
	$(FLUTTER) build apk --debug

# ── Release builds ───────────────────────────────────────────────────

apk: check-signing ## Release APKs: one universal + one per CPU (smaller)
	$(FLUTTER) build apk --release $(BUILD_FLAGS)
	$(FLUTTER) build apk --release --split-per-abi $(BUILD_FLAGS)
	@mkdir -p $(DIST)
	cp $(APK_DIR)/app-release.apk             $(DIST)/tooran-$(VERSION).apk
	cp $(APK_DIR)/app-arm64-v8a-release.apk   $(DIST)/tooran-$(VERSION)-arm64-v8a.apk
	cp $(APK_DIR)/app-armeabi-v7a-release.apk $(DIST)/tooran-$(VERSION)-armeabi-v7a.apk
	cp $(APK_DIR)/app-x86_64-release.apk      $(DIST)/tooran-$(VERSION)-x86_64.apk

aab: check-signing ## Release App Bundle for Google Play
	$(FLUTTER) build appbundle --release $(BUILD_FLAGS)
	@mkdir -p $(DIST)
	cp $(AAB) $(DIST)/tooran-$(VERSION).aab

linux: ## Release desktop bundle (build/linux/x64/release/bundle)
	$(FLUTTER) build linux --release $(BUILD_FLAGS)

deb: linux ## Debian package → dist/tooran_<version>_amd64.deb
	./packaging/deb/build-deb.sh --no-flutter-build

release: check apk aab deb checksums ## Everything above, tested, into dist/
	@echo
	@echo "Release $(VERSION) (build $(BUILD)) is in $(DIST)/:"
	@ls -lh $(DIST)

checksums: ## SHA-256 sums for everything in dist/
	cd $(DIST) && rm -f SHA256SUMS && sha256sum * > SHA256SUMS

# ── Versioning & signing ─────────────────────────────────────────────

version: ## Set the version: make version V=2.1.0
	@test -n "$(V)" || (echo "usage: make version V=x.y.z" && exit 1)
	sed -i -E 's/^version: .*/version: $(V)+1/' pubspec.yaml
	@echo "pubspec.yaml → $(V)"

keystore: ## Create an upload key + android/key.properties (once, keep it safe!)
	@test ! -f android/key.properties || (echo "android/key.properties already exists — not overwriting." && exit 1)
	@mkdir -p $(HOME)/.android-keys
	@read -s -p "Keystore password (min 6 chars): " PW; echo; \
	 $(KEYTOOL) -genkeypair -v -keystore $(HOME)/.android-keys/tooran-upload.jks \
	   -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload \
	   -storepass "$$PW" -keypass "$$PW" \
	   -dname "CN=Jiru Gutema, OU=Tooran, O=Tooran, L=Addis Ababa, C=ET" && \
	 printf 'storePassword=%s\nkeyPassword=%s\nkeyAlias=upload\nstoreFile=%s\n' \
	   "$$PW" "$$PW" "$(HOME)/.android-keys/tooran-upload.jks" > android/key.properties && \
	 chmod 600 android/key.properties && \
	 echo "Created $(HOME)/.android-keys/tooran-upload.jks and android/key.properties." && \
	 echo "Back up the .jks file and the password: without them you can never update the app."

check-signing:
	@if [ ! -f android/key.properties ]; then \
	  echo "!! android/key.properties is missing — release builds will be signed with the DEBUG key."; \
	  echo "!! Fine for testing, NOT for publishing. Run 'make keystore' (or add your existing key)."; \
	  if [ "$(ALLOW_DEBUG_SIGNING)" != "1" ]; then \
	    echo "!! Re-run with ALLOW_DEBUG_SIGNING=1 to build anyway."; exit 1; fi; \
	fi

# ── Publishing ───────────────────────────────────────────────────────

tag: ## Create the git tag v<version> (requires a clean, committed tree)
	@git diff --quiet && git diff --cached --quiet || (echo "Commit your changes first." && exit 1)
	git tag -a $(TAG) -m "Tooran $(VERSION)"
	@echo "Tagged $(TAG). Push with: git push origin $(TAG)"

publish: ## Push the tag and create a GitHub release with dist/ attached
	@test -f android/key.properties || (echo "Refusing to publish debug-signed builds (no android/key.properties)." && exit 1)
	@command -v gh >/dev/null || (echo "Install the GitHub CLI (gh) and run 'gh auth login' first." && exit 1)
	@test -n "$$(ls $(DIST)/*.apk 2>/dev/null)" || (echo "Nothing in $(DIST)/ — run 'make release' first." && exit 1)
	git push origin $(TAG)
	gh release create $(TAG) $(DIST)/* --repo $(REPO) --title "Tooran $(VERSION)" \
	  --notes-file docs/RELEASE_NOTES.md

clean: ## Remove build outputs and dist/
	$(FLUTTER) clean
	rm -rf $(DIST) build/deb

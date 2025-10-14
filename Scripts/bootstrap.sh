#!/bin/bash
set -e

echo "🚀 LMStudioChat Bootstrap Script"
echo "================================="

# Check Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew nicht gefunden. Installiere von https://brew.sh"
    exit 1
fi

echo "✅ Homebrew gefunden"

# Check/Install XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "📦 Installiere XcodeGen..."
    brew install xcodegen
else
    echo "✅ XcodeGen bereits installiert"
fi

# Generate Xcode project
echo "🔨 Generiere Xcode-Projekt..."
xcodegen generate

echo "✅ Projekt generiert: LMStudioChat.xcodeproj"

# Open in Xcode
echo "🚀 Öffne in Xcode..."
open LMStudioChat.xcodeproj

echo ""
echo "✅ Fertig! Nächste Schritte:"
echo "   1. In Xcode: Signing & Capabilities → Team auswählen"
echo "   2. iPhone anschließen und als Run-Ziel wählen"
echo "   3. Build & Run (⌘R)"
echo "   4. In der App: Einstellungen → Server-URL (DynDNS/öffentliche IP + Port), Modell, API-Key eintragen"

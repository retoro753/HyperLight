# Changelog

## Check [1.0] – 2026-11-26
### Erste Version von `hyperlight-check.sh`
- Nur-Lese-Audit: Xiaomi-Reste, Google-Apps, Google-Kern, unbekannte Pakete
- Angemeldete Konten (nur Anzahl), Standard-Apps, laufende Prozesse
- Sicherheit: Patch-Alter, Bootloader-Status, Privates DNS, USB-Debugging
- Highscore (0–100) mit Rang S–D und Fortschrittsbalken
- Liest die Paketlisten direkt aus `hyperlight.sh` und `hyperlight-degoogle.sh`
- Zweisprachig, Bericht als Markdown

---

## Degoogle [1.1] – 2026-11-26
### Neu
- Google News (`com.google.android.apps.magazines`) und Google Home (`com.google.android.apps.chromecast.app`) in Stufe 1

## Degoogle [1.0] – 2026-11-26
### Erste Version von `hyperlight-degoogle.sh`
- Stufe 1: Google-Apps entfernen
- Stufe 2 (`--core`): Play-Dienste, Play Store, Google Services Framework, Google-Backup
- Ersatz-Prüfung für Telefon, Kontakte, Messages, Tastatur und Browser (über Android-Rollen bzw. Standard-Tastatur)
- Sperre für Stufe 2, solange ein Google-Konto angemeldet ist (Diebstahlschutz/FRP)
- Extra-Bestätigung mit `DEGOOGLE` für Stufe 2
- Schutzliste für Google-Systemkomponenten (WebView, Berechtigungen, Netzwerk, Mainline-Module …)
- Eigene Wiederherstellungs-Logs, Play-Dienste werden zuerst zurückgeholt
- Zweisprachig, Endbericht mit ⚠️ für fehlenden Ersatz

---

# hyperlight.sh

## [2.1] – 2026-11-26
### Neu
- Projekt heißt jetzt **HyperLight** (`hyperlight.sh`)
- Zweisprachig: Deutsch / English – Auswahl beim Start oder per `--lang de|en`
- Retro-Startbanner
- Optionen in beliebiger Reihenfolge kombinierbar (z. B. `--dry-run --lang en`)
- Bestätigung akzeptiert `ja`, `j`, `yes`, `y`
### Geändert
- Logs liegen jetzt in `~/hyperlight-logs/`; `--restore` findet auch alte Logs aus `~/xiaomi-debloat-logs/`

## [2.0] – 2026-11-26
### Neu
- Deutlich erweiterte Paketliste (54 Pakete): Mi Store, ShareMe, Cloud-Dienste, Wetter, Notizen, UKW-Radio, Mi Fernbedienung, vorinstallierte Drittanbieter-Apps u. v. m.
- 🛡️ Schutzliste für systemkritische Pakete (exakte Namen + Präfixe)
- `--scan`: findet Xiaomi-Pakete, die auf keiner Liste stehen
- `--restore-all`: stellt Pakete aus allen bisherigen Läufen wieder her
- `--help`
- Prüfung auf Bash ≥ 4
- Versionsanzeige beim Start

## [1.1] – 2026-11-26
### Neu
- Endbericht im Terminal und als Markdown-Datei (✅ / ❌ / ➖)

## [1.0] – 2026-11-26
### Erste Version
- Entfernen von Xiaomi-Werbe- und Tracking-Diensten per `pm uninstall --user 0`
- Gerätecheck (Codename `sapphire`/`sapphiren`)
- Probelauf (`--dry-run`), Sicherheitsabfrage, Wiederherstellung (`--restore`)

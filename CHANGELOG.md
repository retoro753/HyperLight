# Changelog

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

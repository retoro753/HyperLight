#!/usr/bin/env bash
# =============================================================================
#  HyperLight Degoogle – hyperlight-degoogle.sh  –  Version 1.1
#  https://github.com/retoro753/HyperLight
#
#  Entfernt Google-Apps und (optional) die Google-Dienste vom
#  Redmi Note 13 4G (NFC) per ADB – ohne Root.
#  Removes Google apps and (optionally) Google services from the
#  Redmi Note 13 4G (NFC) via ADB – no root.
#
#  Zwei Stufen / Two stages:
#    Stufe 1 (Standard): Google-Apps (YouTube, Gmail, Maps, Chrome, ...)
#    Stufe 2 (--core):   zusätzlich Play-Dienste, Play Store, Services Framework
#
#  Getestet auf / Tested on:
#    Redmi Note 13 4G NFC (23124RA7EO, sapphiren), HyperOS 2.0.215.0, Android 15
#
#  Benötigt / Requires: adb (android-tools), Bash >= 4
#  Nutzung auf eigene Gefahr. / Use at your own risk.  Lizenz / License: MIT
#
#  Hilfe / Help:  ./hyperlight-degoogle.sh --help
# =============================================================================

VERSION="1.1"
set -u

# ---------------------------------------------------------------------------
# 1) STUFE 1 – GOOGLE-APPS / STAGE 1 – GOOGLE APPS
#    Eine Zeile = ein Paket. Zum BEHALTEN mit # auskommentieren.
# ---------------------------------------------------------------------------
APPS=(
  # --- Medien & Alltag / Media & everyday apps ---
  com.google.android.youtube                # YouTube        -> NewPipe (F-Droid)
  com.google.android.apps.youtube.music     # YouTube Music
  com.google.android.apps.photos            # Google Fotos   -> Fossify Gallery
  com.google.android.gm                     # Gmail          -> Tuta
  com.google.android.apps.maps              # Google Maps    -> Organic Maps
  com.google.android.apps.docs              # Google Drive
  com.google.android.apps.tachyon           # Google Meet
  com.google.android.videos                 # Google TV
  com.google.android.keep                   # Google Notizen / Keep
  com.google.android.calendar               # Google Kalender -> Fossify Calendar
  com.google.android.apps.nbu.files         # Files by Google -> Material Files
  com.google.android.apps.walletnfcrel      # Google Wallet
  com.google.android.apps.subscriptions.red # Google One
  com.google.android.apps.magazines         # Google News
  com.google.android.apps.chromecast.app    # Google Home

  # --- Assistent, Suche, KI / Assistant, search, AI ---
  com.google.android.googlequicksearchbox   # Google-App / Suche
  com.google.android.apps.googleassistant   # Google Assistant
  com.google.android.apps.bard              # Gemini
  com.google.ar.lens                        # Google Lens

  # --- Hintergrund & Telemetrie / Background & telemetry ---
  com.google.android.feedback               # Feedback an Google
  com.google.android.apps.wellbeing         # Digital Wellbeing
  com.google.android.apps.safetyhub         # Safety Hub
  com.google.android.partnersetup           # Google Partner Setup
  com.google.android.apps.turbo             # Device Health Services
  com.google.android.apps.restore           # Google-Wiederherstellung
  com.google.android.onetimeinitializer     # Google One Time Init
  com.google.android.syncadapters.contacts  # Kontakte-Sync mit Google
  com.google.android.syncadapters.calendar  # Kalender-Sync mit Google
  com.google.android.projection.gearhead    # Android Auto
  com.google.android.tts                    # Google Sprachausgabe (TTS)
  com.google.android.marvin.talkback        # TalkBack (Bedienungshilfe)

  # --- MIT ERSATZ-PRÜFUNG / WITH REPLACEMENT CHECK ---
  # Werden nur entfernt, wenn bereits eine andere App als Standard gesetzt ist.
  # Only removed if another app is already set as default.
  com.android.chrome                        # Chrome         -> Firefox
  com.google.android.dialer                 # Google Telefon -> Fossify Phone
  com.google.android.contacts               # Google Kontakte -> Fossify Contacts
  com.google.android.apps.messaging         # Google Messages -> Fossify Messages
  com.google.android.inputmethod.latin      # Gboard         -> HeliBoard / FlorisBoard
)

# Ersatz-Prüfungen / Replacement checks
#   role:ROLLE -> Standard-App für diese Rolle darf NICHT das Paket selbst sein
#   ime        -> Standard-Tastatur darf NICHT das Paket selbst sein
declare -A BEDINGUNG=(
  [com.android.chrome]="role:android.app.role.BROWSER"
  [com.google.android.dialer]="role:android.app.role.DIALER"
  [com.google.android.contacts]="role:android.app.role.DIALER:com.google.android.dialer"
  [com.google.android.apps.messaging]="role:android.app.role.SMS"
  [com.google.android.inputmethod.latin]="ime"
)

# ---------------------------------------------------------------------------
# 2) STUFE 2 – GOOGLE-KERN (nur mit --core) / STAGE 2 – GOOGLE CORE
#    Reihenfolge wichtig: Play-Dienste (gms) zuletzt.
# ---------------------------------------------------------------------------
KERN=(
  com.google.android.backuptransport        # Google-Backup
  com.android.vending                       # Play Store     -> F-Droid / Aurora
  com.google.android.gsf                    # Google Services Framework
  com.google.android.gms                    # Google Play-Dienste
)

# ---------------------------------------------------------------------------
# 3) SCHUTZLISTE / PROTECTED LIST
#    Google-Pakete, die Android selbst braucht. NIE entfernen.
# ---------------------------------------------------------------------------
GESCHUETZT=(
  com.google.android.webview                # WebView: viele Apps zeigen damit Inhalte an
  com.google.android.packageinstaller       # App-Installer
  com.google.android.permissioncontroller   # Berechtigungen!
  com.google.android.documentsui            # Dateiauswahl
  com.google.android.ext.services           # Android-Systemdienste
  com.google.android.ext.shared             # Android-Systembibliothek
  com.google.android.modulemetadata         # Android-Modulinfos
  com.google.android.captiveportallogin     # WLAN-Login (Hotels, Bahn)
  com.google.android.setupwizard            # Einrichtung (sonst evtl. Home-Taste kaputt)
  com.google.android.healthconnect.controller
  com.google.android.adservices.api
  com.google.android.ondevicepersonalization.services
  com.google.android.rkpdapp                # Schlüssel-Bereitstellung
  com.google.android.configupdater
)
GESCHUETZT_PRAEFIX=(
  com.google.android.overlay.               # Design-Overlays
  com.google.mainline.                      # Android-Systemmodule (Updates)
  com.google.android.networkstack           # Netzwerk!
  com.google.android.cellbroadcast          # Notfallwarnungen (Cell Broadcast)
  com.google.android.providers.             # Datenspeicher
)

# ---------------------------------------------------------------------------
# 4) Grundeinstellungen
# ---------------------------------------------------------------------------
ERWARTETER_CODENAME="sapphire"
LOG_ORDNER="$HOME/hyperlight-logs"
ROT=$'\e[31m'; GRUEN=$'\e[32m'; GELB=$'\e[33m'; BLAU=$'\e[34m'
CYAN=$'\e[36m'; RESET=$'\e[0m'

# ---------------------------------------------------------------------------
# 5) TEXTE / TEXTS
# ---------------------------------------------------------------------------
declare -A DE EN
DE[bash_alt]="Bash %s ist zu alt – mindestens Version 4 nötig."
EN[bash_alt]="Bash %s is too old – version 4 or newer required."
DE[kein_adb]="adb nicht gefunden. Arch/Omarchy: sudo pacman -S android-tools"
EN[kein_adb]="adb not found. Arch/Omarchy: sudo pacman -S android-tools"
DE[kein_geraet]="Kein Gerät bereit. USB-Debugging an? Abfrage bestätigt? Test: adb devices"
EN[kein_geraet]="No device ready. USB debugging on? Prompt accepted? Test: adb devices"
DE[geraet]="Verbundenes Gerät: %s (Codename: %s)"
EN[geraet]="Connected device: %s (codename: %s)"
DE[falsches_geraet]="Kein Redmi Note 13 4G (sapphire/sapphiren) – Abbruch zur Sicherheit."
EN[falsches_geraet]="Not a Redmi Note 13 4G (sapphire/sapphiren) – aborting for safety."
DE[modus_apps]="Modus: Stufe 1 – nur Google-Apps"
EN[modus_apps]="Mode: stage 1 – Google apps only"
DE[modus_kern]="Modus: Stufe 1 + 2 – Google-Apps UND Google-Dienste (--core)"
EN[modus_kern]="Mode: stage 1 + 2 – Google apps AND Google services (--core)"
DE[konto_da]="Auf dem Handy ist noch ein Google-Konto angemeldet!"
EN[konto_da]="A Google account is still signed in on the phone!"
DE[konto_warn_1]="Nach einem Werksreset fragt das Handy nach genau diesem Konto (Diebstahlschutz)."
EN[konto_warn_1]="After a factory reset the phone will ask for exactly this account (anti-theft)."
DE[konto_warn_2]="Kommst du nicht mehr ins Konto, ist das Handy dann gesperrt."
EN[konto_warn_2]="If you can't access the account, the phone will be locked."
DE[konto_warn_3]="Zuerst entfernen: Einstellungen -> Konten & Synchronisierung -> Google -> Konto entfernen."
EN[konto_warn_3]="Remove it first: Settings -> Accounts & sync -> Google -> Remove account."
DE[konto_stop]="Stufe 2 (--core) wird deshalb NICHT ausgeführt."
EN[konto_stop]="Stage 2 (--core) will therefore NOT run."
DE[liste_titel]="Diese Pakete würden entfernt:"
EN[liste_titel]="These packages would be removed:"
DE[ist_geschuetzt]="ist GESCHÜTZT – wird übersprungen"
EN[ist_geschuetzt]="is PROTECTED – skipped"
DE[kein_ersatz]="kein Ersatz als Standard gesetzt – wird übersprungen"
EN[kein_ersatz]="no replacement set as default – skipped"
DE[nicht_vorhanden]="nicht vorhanden"
EN[nicht_vorhanden]="not installed"
DE[nichts_zu_tun]="Nichts zu tun."
EN[nichts_zu_tun]="Nothing to do."
DE[dry_run]="Probelauf (--dry-run): Es wurde NICHTS verändert."
EN[dry_run]="Dry run (--dry-run): NOTHING was changed."
DE[kern_info_1]="Nach Stufe 2 funktioniert NICHT mehr:"
EN[kern_info_1]="After stage 2 these will NOT work anymore:"
DE[kern_info_2]="  - Play Store (stattdessen F-Droid / Aurora Store)"
EN[kern_info_2]="  - Play Store (use F-Droid / Aurora Store instead)"
DE[kern_info_3]="  - Push-Benachrichtigungen vieler Apps, Google-Konto-Sync"
EN[kern_info_3]="  - Push notifications of many apps, Google account sync"
DE[kern_info_4]="  - Apps, die Google-Dienste brauchen (Banking, manche Spiele, WhatsApp eingeschränkt)"
EN[kern_info_4]="  - Apps that need Google services (banking, some games, WhatsApp limited)"
DE[kern_info_5]="  - Schnelle Standortbestimmung (GPS selbst funktioniert weiter)"
EN[kern_info_5]="  - Fast network location (GPS itself keeps working)"
DE[kern_frage]="Zum Bestätigen DEGOOGLE eintippen (alles andere bricht ab): "
EN[kern_frage]="Type DEGOOGLE to confirm (anything else aborts): "
DE[frage]="Diese %s Pakete jetzt entfernen? (ja/nein): "
EN[frage]="Remove these %s packages now? (yes/no): "
DE[abbruch]="Abgebrochen. Nichts verändert."
EN[abbruch]="Aborted. Nothing changed."
DE[kein_log]="Kein Degoogle-Log gefunden – nichts wiederherzustellen."
EN[kein_log]="No degoogle log found – nothing to restore."
DE[restore_fertig]="Fertig. Starte das Handy einmal neu."
EN[restore_fertig]="Done. Please reboot the phone."
DE[scan_titel]="Google-Pakete auf dem Handy, die auf KEINER Liste stehen:"
EN[scan_titel]="Google packages on the phone that are on NO list:"
DE[scan_nichts]="Nichts Unbekanntes gefunden."
EN[scan_nichts]="Nothing unknown found."
DE[scan_tipp]="Nicht blind hinzufügen – erst recherchieren, was sie tun!"
EN[scan_tipp]="Do not add them blindly – research what they do first!"
DE[bericht_titel]="ENDBERICHT"
EN[bericht_titel]="FINAL REPORT"
DE[b_kopf]="Degoogle-Bericht"
EN[b_kopf]="Degoogle report"
DE[b_spalten]="| Status | Paket | Hinweis |"
EN[b_spalten]="| Status | Package | Note |"
DE[b_entfernt]="entfernt"
EN[b_entfernt]="removed"
DE[b_nicht_da]="war nicht installiert"
EN[b_nicht_da]="was not installed"
DE[b_geschuetzt]="geschützt, übersprungen"
EN[b_geschuetzt]="protected, skipped"
DE[b_ersatz]="kein Ersatz gesetzt, übersprungen"
EN[b_ersatz]="no replacement set, skipped"
DE[b_gescannt]="Gescannt"
EN[b_gescannt]="Scanned"
DE[b_legende]="Legende: ✅ entfernt · ❌ Fehler · ➖ nicht auf dem Gerät · 🛡️ geschützt · ⚠️ Ersatz fehlt"
EN[b_legende]="Legend: ✅ removed · ❌ error · ➖ not on device · 🛡️ protected · ⚠️ replacement missing"
DE[ersatz_tipp]="⚠️ = erst eine Ersatz-App installieren und als Standard setzen, dann Skript erneut starten."
EN[ersatz_tipp]="⚠️ = install a replacement app and set it as default first, then run the script again."
DE[pfad_bericht]="Bericht (Markdown):     %s"
EN[pfad_bericht]="Report (Markdown):      %s"
DE[pfad_restore]="Rückgängig:             %s --restore"
EN[pfad_restore]="Undo:                   %s --restore"
DE[neustart]="Jetzt neu starten und testen: Anrufe, SMS, Tastatur, WLAN, Kamera."
EN[neustart]="Now reboot and test: calls, SMS, keyboard, Wi-Fi, camera."
DE[unbekannt]="Unbekannte Option: %s (Hilfe: --help)"
EN[unbekannt]="Unknown option: %s (help: --help)"

t()  { if [[ "$SPRACHE" == "en" ]]; then printf '%s' "${EN[$1]}"; else printf '%s' "${DE[$1]}"; fi; }
tf() { local key="$1"; shift; printf "$(t "$key")" "$@"; }

hilfe() {
  if [[ "$SPRACHE" == "en" ]]; then cat <<EOF
HyperLight Degoogle v$VERSION – removes Google from the Redmi Note 13 4G (NFC)

Usage: ./hyperlight-degoogle.sh [option] [--lang de|en]

  (no option)    stage 1: remove Google apps
  --core         stage 1 + 2: also remove Play services, Play Store, GSF
  --dry-run      only show what would happen (combine with --core)
  --scan         find Google packages that are on no list
  --restore      restore packages from the LAST degoogle run
  --restore-all  restore packages from ALL degoogle runs
  --lang de|en   choose language without being asked
  --help         show this help

Phone, SMS, contacts, keyboard and Chrome are only removed if another app
is already set as default. Stage 2 is blocked while a Google account is
signed in on the phone (anti-theft lock after factory reset!).
EOF
  else cat <<EOF
HyperLight Degoogle v$VERSION – entfernt Google vom Redmi Note 13 4G (NFC)

Nutzung: ./hyperlight-degoogle.sh [Option] [--lang de|en]

  (keine Option) Stufe 1: Google-Apps entfernen
  --core         Stufe 1 + 2: auch Play-Dienste, Play Store, GSF entfernen
  --dry-run      nur anzeigen (kombinierbar mit --core)
  --scan         Google-Pakete finden, die auf keiner Liste stehen
  --restore      Pakete aus dem LETZTEN Degoogle-Lauf zurückholen
  --restore-all  Pakete aus ALLEN Degoogle-Läufen zurückholen
  --lang de|en   Sprache wählen, ohne gefragt zu werden
  --help         diese Hilfe

Telefon, SMS, Kontakte, Tastatur und Chrome werden nur entfernt, wenn schon
eine andere App als Standard gesetzt ist. Stufe 2 ist gesperrt, solange ein
Google-Konto auf dem Handy angemeldet ist (Diebstahlsperre nach Werksreset!).
EOF
  fi
}

banner() {
  echo "${CYAN}"
  echo "  ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ "
  echo "  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗"
  echo "  ███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝"
  echo "  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗"
  echo "  ██║  ██║   ██║   ██║     ███████╗██║  ██║"
  echo "  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝"
  echo "      L I G H T  ·  D E G O O G L E   v$VERSION${RESET}"
  echo
}

# ---------------------------------------------------------------------------
# 6) Hilfsfunktionen
# ---------------------------------------------------------------------------
ist_geschuetzt() {
  local paket="$1" g p
  for g in "${GESCHUETZT[@]}"; do [[ "$paket" == "$g" ]] && return 0; done
  for p in "${GESCHUETZT_PRAEFIX[@]}"; do [[ "$paket" == "$p"* ]] && return 0; done
  return 1
}

steht_auf_liste() {
  local paket="$1" x
  for x in "${APPS[@]}" "${KERN[@]}"; do [[ "$paket" == "$x" ]] && return 0; done
  return 1
}

# Prüft, ob für ein Paket ein Ersatz gesetzt ist. 0 = ok (darf weg), 1 = Ersatz fehlt
ersatz_ok() {
  local paket="$1" bed="${BEDINGUNG[$1]:-}" rolle pruef_paket inhaber
  [[ -z "$bed" ]] && return 0
  if [[ "$bed" == "ime" ]]; then
    inhaber=$(adb shell settings get secure default_input_method | tr -d '\r')
    [[ "$inhaber" == "$paket"/* ]] && return 1
    return 0
  fi
  # Format: role:ROLLE  oder  role:ROLLE:ANDERES_PAKET
  rolle=$(cut -d: -f2 <<< "$bed")
  pruef_paket=$(cut -d: -f3 <<< "$bed")
  [[ -z "$pruef_paket" ]] && pruef_paket="$paket"
  inhaber=$(adb shell cmd role get-role-holders --user 0 "$rolle" | tr -d '\r')
  # Leere Antwort = kein Standard gesetzt -> vorsichtshalber nicht entfernen
  [[ -z "$inhaber" ]] && return 1
  grep -qw "$pruef_paket" <<< "$inhaber" && return 1
  return 0
}

google_konto_da() {
  adb shell dumpsys account 2>/dev/null | tr -d '\r' | grep -q "type=com.google"
}

# ---------------------------------------------------------------------------
# 7) Argumente
# ---------------------------------------------------------------------------
MODUS="normal"; KERN_AN=0; SPRACHE=""
while (( $# > 0 )); do
  case "$1" in
    --core)        KERN_AN=1 ;;
    --dry-run)     MODUS="dry-run" ;;
    --scan)        MODUS="scan" ;;
    --restore)     MODUS="restore" ;;
    --restore-all) MODUS="restore-all" ;;
    --help|-h)     MODUS="help" ;;
    --lang)        shift; SPRACHE="${1:-}" ;;
    *) SPRACHE="${SPRACHE:-de}"; tf unbekannt "$1"; echo; exit 1 ;;
  esac
  shift
done

if [[ "$SPRACHE" != "de" && "$SPRACHE" != "en" ]]; then
  banner
  echo "  [1] Deutsch"
  echo "  [2] English"
  read -r -p "  Sprache / Language (1/2): " WAHL
  [[ "$WAHL" == "2" ]] && SPRACHE="en" || SPRACHE="de"
  echo
else
  banner
fi

if [[ "$MODUS" == "help" ]]; then hilfe; exit 0; fi

# ---------------------------------------------------------------------------
# 8) Prüfungen
# ---------------------------------------------------------------------------
if (( BASH_VERSINFO[0] < 4 )); then echo "${ROT}$(tf bash_alt "$BASH_VERSION")${RESET}"; exit 1; fi
if ! command -v adb >/dev/null 2>&1; then echo "${ROT}$(t kein_adb)${RESET}"; exit 1; fi
if [[ "$(adb get-state 2>/dev/null)" != "device" ]]; then echo "${ROT}$(t kein_geraet)${RESET}"; exit 1; fi

CODENAME=$(adb shell getprop ro.product.device | tr -d '\r')
MODELL=$(adb shell getprop ro.product.model | tr -d '\r')
tf geraet "$MODELL" "$CODENAME"; echo
if [[ "$CODENAME" != ${ERWARTETER_CODENAME}* ]]; then echo "${GELB}$(t falsches_geraet)${RESET}"; exit 1; fi

# ---------------------------------------------------------------------------
# 9) Wiederherstellen (eigene Logs: degoogle-entfernt-*.txt)
# ---------------------------------------------------------------------------
if [[ "$MODUS" == restore* ]]; then
  if [[ "$MODUS" == "restore" ]]; then
    DATEIEN=$(ls -1t "$LOG_ORDNER"/degoogle-entfernt-*.txt 2>/dev/null | head -n 1)
  else
    DATEIEN=$(ls -1 "$LOG_ORDNER"/degoogle-entfernt-*.txt 2>/dev/null)
  fi
  if [[ -z "$DATEIEN" ]]; then t kein_log; echo; exit 1; fi
  # Kern zuerst zurück (gms vor allem anderen), dann die Apps
  # shellcheck disable=SC2086
  ALLE=$(sort -u $DATEIEN)
  for PAKET in com.google.android.gms com.google.android.gsf com.android.vending; do
    if grep -qx "$PAKET" <<< "$ALLE"; then
      echo "  $PAKET -> $(adb shell cmd package install-existing "$PAKET" 2>&1 | tr -d '\r')"
    fi
  done
  while read -r PAKET; do
    [[ -z "$PAKET" ]] && continue
    [[ "$PAKET" =~ ^(com\.google\.android\.gms|com\.google\.android\.gsf|com\.android\.vending)$ ]] && continue
    echo "  $PAKET -> $(adb shell cmd package install-existing "$PAKET" 2>&1 | tr -d '\r')"
  done <<< "$ALLE"
  echo "${GRUEN}$(t restore_fertig)${RESET}"
  exit 0
fi

INSTALLIERT=$(adb shell pm list packages | tr -d '\r' | sed 's/^package://')

# ---------------------------------------------------------------------------
# 10) Scan
# ---------------------------------------------------------------------------
if [[ "$MODUS" == "scan" ]]; then
  echo; t scan_titel; echo
  GEFUNDEN=0
  while read -r PAKET; do
    [[ -z "$PAKET" ]] && continue
    steht_auf_liste "$PAKET" && continue
    ist_geschuetzt "$PAKET" && continue
    echo "  🔍 $PAKET"; ((GEFUNDEN++))
  done < <(grep -E '^com\.google\.|^com\.android\.chrome$|^com\.android\.vending$' <<< "$INSTALLIERT" | sort)
  echo
  if (( GEFUNDEN == 0 )); then echo "${GRUEN}$(t scan_nichts)${RESET}"; else echo "${GELB}$(t scan_tipp)${RESET}"; fi
  exit 0
fi

# ---------------------------------------------------------------------------
# 11) Liste zusammenstellen + Google-Konto prüfen
# ---------------------------------------------------------------------------
PAKETE=("${APPS[@]}")
echo
if (( KERN_AN == 1 )); then
  if google_konto_da; then
    echo "${ROT}$(t konto_da)${RESET}"
    t konto_warn_1; echo; t konto_warn_2; echo; t konto_warn_3; echo
    echo "${GELB}$(t konto_stop)${RESET}"
    KERN_AN=0
    echo
  else
    PAKETE+=("${KERN[@]}")
  fi
fi
if (( KERN_AN == 1 )); then t modus_kern; else t modus_apps; fi; echo

# ---------------------------------------------------------------------------
# 12) Status bestimmen
# ---------------------------------------------------------------------------
declare -A STATUS MELDUNG
ZU_ENTFERNEN=()
echo; t liste_titel; echo
for PAKET in "${PAKETE[@]}"; do
  if ist_geschuetzt "$PAKET"; then
    echo "  ${BLAU}🛡️  $PAKET $(t ist_geschuetzt)${RESET}"; STATUS[$PAKET]="geschuetzt"
  elif ! grep -qx "$PAKET" <<< "$INSTALLIERT"; then
    echo "    ($(t nicht_vorhanden): $PAKET)"; STATUS[$PAKET]="nicht_vorhanden"
  elif ! ersatz_ok "$PAKET"; then
    echo "  ${GELB}⚠️  $PAKET – $(t kein_ersatz)${RESET}"; STATUS[$PAKET]="kein_ersatz"
  else
    echo "  ${GELB}- $PAKET${RESET}"; ZU_ENTFERNEN+=("$PAKET"); STATUS[$PAKET]="offen"
  fi
done

if (( ${#ZU_ENTFERNEN[@]} == 0 )); then echo; echo "${GRUEN}$(t nichts_zu_tun)${RESET}"; exit 0; fi
if [[ "$MODUS" == "dry-run" ]]; then echo; t dry_run; echo; exit 0; fi

# ---------------------------------------------------------------------------
# 13) Bestätigung (Stufe 2 mit extra Sicherheitswort)
# ---------------------------------------------------------------------------
echo
if (( KERN_AN == 1 )); then
  echo "${ROT}$(t kern_info_1)${RESET}"
  t kern_info_2; echo; t kern_info_3; echo; t kern_info_4; echo; t kern_info_5; echo
  echo
  read -r -p "$(t kern_frage)" ANTWORT
  [[ "$ANTWORT" != "DEGOOGLE" ]] && { t abbruch; echo; exit 0; }
else
  read -r -p "$(tf frage "${#ZU_ENTFERNEN[@]}")" ANTWORT
  case "${ANTWORT,,}" in ja|j|yes|y) ;; *) t abbruch; echo; exit 0 ;; esac
fi

# ---------------------------------------------------------------------------
# 14) Entfernen
# ---------------------------------------------------------------------------
mkdir -p "$LOG_ORDNER"
ZEITSTEMPEL=$(date +%Y-%m-%d_%H-%M-%S)
LOG="$LOG_ORDNER/degoogle-entfernt-$ZEITSTEMPEL.txt"
ERFOLG=0; FEHLER=0
for PAKET in "${ZU_ENTFERNEN[@]}"; do
  ERGEBNIS=$(adb shell pm uninstall --user 0 "$PAKET" 2>&1 | tr -d '\r')
  if [[ "$ERGEBNIS" == *Success* ]]; then
    echo "  ${GRUEN}✔ $PAKET${RESET}"; echo "$PAKET" >> "$LOG"
    STATUS[$PAKET]="entfernt"; ((ERFOLG++))
  else
    echo "  ${ROT}✘ $PAKET -> $ERGEBNIS${RESET}"
    STATUS[$PAKET]="fehler"; MELDUNG[$PAKET]="$ERGEBNIS"; ((FEHLER++))
  fi
done

# ---------------------------------------------------------------------------
# 15) Endbericht
# ---------------------------------------------------------------------------
NICHT_DA=0; GESCH=0; ERSATZ=0
for PAKET in "${PAKETE[@]}"; do
  case "${STATUS[$PAKET]}" in
    nicht_vorhanden) ((NICHT_DA++)) ;;
    geschuetzt)      ((GESCH++)) ;;
    kein_ersatz)     ((ERSATZ++)) ;;
  esac
done

symbol() {
  case "${STATUS[$1]}" in
    entfernt) echo "✅" ;; fehler) echo "❌" ;; nicht_vorhanden) echo "➖" ;;
    geschuetzt) echo "🛡️" ;; kein_ersatz) echo "⚠️" ;;
  esac
}

BERICHT="$LOG_ORDNER/degoogle-bericht-$ZEITSTEMPEL.md"
{
  echo "# HyperLight Degoogle – $(t b_kopf) – $MODELL ($CODENAME)"
  echo
  echo "$(date '+%Y-%m-%d %H:%M') · HyperLight Degoogle v$VERSION · $( (( KERN_AN == 1 )) && echo "--core" || echo "apps")"
  echo
  t b_spalten; echo
  echo "|---|---|---|"
  for PAKET in "${PAKETE[@]}"; do
    case "${STATUS[$PAKET]}" in
      entfernt)        H="$(t b_entfernt)" ;;
      fehler)          H="${MELDUNG[$PAKET]}" ;;
      nicht_vorhanden) H="$(t b_nicht_da)" ;;
      geschuetzt)      H="$(t b_geschuetzt)" ;;
      kein_ersatz)     H="$(t b_ersatz)" ;;
    esac
    echo "| $(symbol "$PAKET") | \`$PAKET\` | $H |"
  done
  echo
  echo "**$(t b_gescannt):** ${#PAKETE[@]} · ✅ $ERFOLG · ❌ $FEHLER · ➖ $NICHT_DA · 🛡️ $GESCH · ⚠️ $ERSATZ"
  echo
  t b_legende; echo
} > "$BERICHT"

echo
echo "==================== $(t bericht_titel) ===================="
for PAKET in "${PAKETE[@]}"; do
  if [[ "${STATUS[$PAKET]}" == "fehler" ]]; then
    printf "  %-40s ❌  (%s)\n" "$PAKET" "${MELDUNG[$PAKET]}"
  else
    printf "  %-40s %s\n" "$PAKET" "$(symbol "$PAKET")"
  fi
done
echo "----------------------------------------------------------"
echo "  $(t b_gescannt): ${#PAKETE[@]}  ✅ $ERFOLG  ❌ $FEHLER  ➖ $NICHT_DA  🛡️ $GESCH  ⚠️ $ERSATZ"
echo "=========================================================="
(( ERSATZ > 0 )) && { echo; echo "${GELB}$(t ersatz_tipp)${RESET}"; }
echo
tf pfad_bericht "$BERICHT"; echo
tf pfad_restore "$0"; echo
echo
echo "${GELB}$(t neustart)${RESET}"

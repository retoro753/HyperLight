#!/usr/bin/env bash
# =============================================================================
#  HyperLight – hyperlight.sh  –  Version 2.1
#  https://github.com/retoro753/HyperLight
#
#  Entfernt Xiaomi-Bloatware vom Redmi Note 13 4G (NFC) per ADB – ohne Root.
#  Removes Xiaomi bloatware from the Redmi Note 13 4G (NFC) via ADB – no root.
#
#  Getestet auf / Tested on:
#    Redmi Note 13 4G NFC (23124RA7EO, Codename sapphiren), HyperOS 2.0.215.0
#
#  Benötigt / Requires: adb (android-tools), Bash >= 4
#  Nutzung auf eigene Gefahr. / Use at your own risk.
#  Lizenz / License: MIT
#
#  Hilfe / Help:  ./hyperlight.sh --help
# =============================================================================

VERSION="2.1"

set -u   # Abbruch bei nicht definierten Variablen (Schutz vor Tippfehlern)

# ---------------------------------------------------------------------------
# 1) ENTFERNEN-LISTE / REMOVAL LIST
#    Eine Zeile = ein Paket. Alles hinter # ist ein Kommentar.
#    Paket BEHALTEN: Zeile mit # auskommentieren.
#    One line = one package. To KEEP a package, comment it out with #.
# ---------------------------------------------------------------------------
PAKETE=(
  # --- Werbung, Tracking, Telemetrie / Ads, tracking, telemetry ---
  com.miui.msa.global               # MSA: Xiaomi-Werbedienst / ad service
  com.miui.analytics                # Analytics / Tracking
  com.miui.daemon                   # Nutzungsdaten / usage data
  com.miui.bugreport                # Fehlerberichte an Xiaomi / bug reports
  com.miui.miservice                # Dienste & Feedback / Services & feedback

  # --- Stores, Empfehlungen / Stores, recommendations ---
  com.xiaomi.mipicks                # GetApps
  com.xiaomi.discover               # System-App-Updater
  com.mi.global.shop                # Mi Store
  com.miui.hybrid                   # Quick Apps
  com.miui.hybrid.accessory         # Quick Apps (Zubehör / accessory)
  com.miui.android.fashiongallery   # Glance / Sperrbildschirm-Karussell
  com.mi.android.globalminusscreen  # App Vault (alt / old)
  com.miui.personalassistant        # App Vault (neu / new)

  # --- Xiaomi-Apps ---
  com.mi.globalbrowser              # Mi Browser
  com.miui.videoplayer              # Mi Video
  com.miui.player                   # Mi Music
  com.xiaomi.glgm                   # Xiaomi Games
  com.xiaomi.migameservice          # Game Turbo
  com.miui.yellowpage               # Yellow Pages / Caller ID
  com.xiaomi.midrop                 # ShareMe
  com.miui.weather2                 # Wetter / Weather
  com.miui.notes                    # Notizen / Notes
  com.miui.fm                       # UKW-Radio / FM radio
  com.miui.fmservice                # UKW-Radio-Dienst / FM radio service
  com.duokan.phone.remotecontroller # Mi Fernbedienung / Mi Remote (IR)
  com.xiaomi.scanner                # Scanner / QR codes -> Binary Eye (F-Droid)
  com.miui.compass                  # Kompass / Compass
  com.miui.calculator               # Taschenrechner / Calculator -> F-Droid!
  com.miui.cleaner                  # Cleaner
  com.miui.huanji                   # Mi Mover
  com.miui.touchassistant           # Quick Ball
  com.miui.backup                   # Xiaomi-Backup

  # --- Cloud & Verbindungsdienste / Cloud & connectivity ---
  com.miui.cloudservice             # Xiaomi Cloud
  com.miui.cloudbackup              # Xiaomi Cloud Backup
  com.miui.micloudsync              # Xiaomi Cloud Sync
  com.miui.mishare.connectivity     # Mi Share
  com.xiaomi.mi_connect_service     # Xiaomi device connection
  com.milink.service                # Interconnectivity / Cast
  com.xiaomi.payment                # Mi Pay
  com.mipay.wallet                  # Mi Wallet

  # --- OPTIONAL: Dateimanager / file manager (install a replacement first!) ---
  # com.mi.android.globalFileexplorer

  # --- Vorinstallierte Drittanbieter-Apps / Preinstalled third-party apps ---
  com.amazon.mShop.android.shopping # Amazon Shopping
  com.amazon.appmanager             # Amazon installer
  com.linkedin.android              # LinkedIn
  com.microsoft.bing                # Bing
  com.facebook.katana               # Facebook
  com.facebook.appmanager           # Facebook App Manager
  com.facebook.services             # Facebook Services
  com.facebook.system               # Facebook App Installer
  com.netflix.mediaclient           # Netflix
  com.netflix.partner.activation    # Netflix activation
  com.booking                       # Booking.com
  com.spotify.music                 # Spotify
  com.tiktok.lite.go                # TikTok Lite
  com.einnovation.temu              # Temu
)

# ---------------------------------------------------------------------------
# 2) SCHUTZLISTE / PROTECTED LIST
#    Diese Pakete fasst HyperLight NIE an – auch nicht, wenn sie oben stehen.
#    HyperLight NEVER touches these – even if they are added above.
# ---------------------------------------------------------------------------
GESCHUETZT=(
  com.miui.home                     # Launcher
  com.android.systemui              # Status bar, navigation
  com.android.settings              # Settings
  com.miui.securitycenter           # Security (deeply integrated)
  com.miui.securitycore             # Security core
  com.miui.securityadd              # Security add-on
  com.lbe.security.miui             # Permission manager!
  com.miui.powerkeeper              # Battery & performance
  com.miui.system                   # System resources
  com.miui.rom                      # System resources
  com.miui.core                     # Xiaomi core library
  com.miui.packageinstaller         # App installer
  com.miui.gallery                  # Gallery (camera preview needs it)
  com.android.camera                # Camera
  com.android.thememanager          # Themes / wallpapers
  com.miui.miwallpaper              # Wallpaper service
  com.xiaomi.account                # Xiaomi account (anti-theft)
  com.xiaomi.finddevice             # Find device (anti-theft)
  com.xiaomi.xmsf                   # Xiaomi Service Framework
  com.android.phone                 # Telephony
  com.google.android.gms            # Google Play services
  com.android.vending               # Play Store
)
GESCHUETZT_PRAEFIX=(
  com.android.providers.            # Contacts, SMS, media storage ...
  com.qualcomm.                     # Chipset drivers/services
  com.qti.                          # Chipset drivers/services
  vendor.                           # Vendor hardware services
)

XIAOMI_MUSTER='miui|xiaomi|duokan|mi\.global|mi\.android|milink|mipay|xmsf'

# ---------------------------------------------------------------------------
# 3) Grundeinstellungen / Basic settings
# ---------------------------------------------------------------------------
ERWARTETER_CODENAME="sapphire"      # matches "sapphire" AND "sapphiren"
LOG_ORDNER="$HOME/hyperlight-logs"
ALTER_LOG_ORDNER="$HOME/xiaomi-debloat-logs"   # Logs von Version 1.x / 2.0
ROT=$'\e[31m'; GRUEN=$'\e[32m'; GELB=$'\e[33m'; BLAU=$'\e[34m'
CYAN=$'\e[36m'; RESET=$'\e[0m'

# ---------------------------------------------------------------------------
# 4) TEXTE / TEXTS  (Deutsch + English)
#    t SCHLUESSEL      -> gibt den Text in der gewählten Sprache aus
#    tf SCHLUESSEL ARG -> wie t, aber mit Platzhaltern (%s)
# ---------------------------------------------------------------------------
declare -A DE EN

DE[bash_alt]="Bash %s ist zu alt – mindestens Version 4 nötig. (macOS: 'brew install bash')"
EN[bash_alt]="Bash %s is too old – version 4 or newer required. (macOS: 'brew install bash')"
DE[kein_adb]="adb nicht gefunden. Arch/Omarchy: sudo pacman -S android-tools"
EN[kein_adb]="adb not found. Arch/Omarchy: sudo pacman -S android-tools"
DE[kein_geraet]="Kein Gerät bereit."
EN[kein_geraet]="No device ready."
DE[kein_geraet_1]="  - USB-Kabel dran? USB-Debugging an? Abfrage am Handy bestätigt?"
EN[kein_geraet_1]="  - USB cable connected? USB debugging on? Prompt on phone accepted?"
DE[kein_geraet_2]="  - Mehr als ein Gerät angeschlossen? Dann nur eins dranlassen."
EN[kein_geraet_2]="  - More than one device connected? Keep only one."
DE[kein_geraet_3]="  - Selbst testen mit: adb devices"
EN[kein_geraet_3]="  - Test it yourself with: adb devices"
DE[geraet]="Verbundenes Gerät: %s (Codename: %s)"
EN[geraet]="Connected device: %s (codename: %s)"
DE[falsches_geraet]="Achtung: Das ist kein Redmi Note 13 4G (sapphire/sapphiren)."
EN[falsches_geraet]="Warning: This is not a Redmi Note 13 4G (sapphire/sapphiren)."
DE[falsches_geraet_2]="Die Listen sind für dieses Gerät gedacht. Abbruch zur Sicherheit."
EN[falsches_geraet_2]="The lists are made for that device. Aborting for safety."
DE[kein_log]="Kein Log gefunden – nichts wiederherzustellen."
EN[kein_log]="No log found – nothing to restore."
DE[restore_fertig]="Fertig. Starte das Handy einmal neu."
EN[restore_fertig]="Done. Please reboot the phone."
DE[scan_titel]="Xiaomi-Pakete auf dem Handy, die auf KEINER Liste stehen:"
EN[scan_titel]="Xiaomi packages on the phone that are on NO list:"
DE[scan_nichts]="Nichts Unbekanntes gefunden."
EN[scan_nichts]="Nothing unknown found."
DE[scan_anzahl]="%s unbekannte Pakete. Nicht blind hinzufügen!"
EN[scan_anzahl]="%s unknown packages. Do not add them blindly!"
DE[scan_tipp]="Erst recherchieren, was sie tun – dann ggf. in die Entfernen-Liste eintragen."
EN[scan_tipp]="Research what they do first – then add them to the removal list if safe."
DE[liste_titel]="Diese Pakete würden entfernt:"
EN[liste_titel]="These packages would be removed:"
DE[ist_geschuetzt]="ist GESCHÜTZT – wird übersprungen"
EN[ist_geschuetzt]="is PROTECTED – skipped"
DE[nicht_vorhanden]="nicht vorhanden"
EN[nicht_vorhanden]="not installed"
DE[nichts_zu_tun]="Nichts zu tun – alles schon weg."
EN[nichts_zu_tun]="Nothing to do – everything is already gone."
DE[dry_run]="Probelauf (--dry-run): Es wurde NICHTS verändert."
EN[dry_run]="Dry run (--dry-run): NOTHING was changed."
DE[frage]="Diese %s Pakete jetzt entfernen? (ja/nein): "
EN[frage]="Remove these %s packages now? (yes/no): "
DE[abbruch]="Abgebrochen. Nichts verändert."
EN[abbruch]="Aborted. Nothing changed."
DE[bericht_titel]="ENDBERICHT"
EN[bericht_titel]="FINAL REPORT"
DE[b_kopf]="Debloat-Bericht"
EN[b_kopf]="Debloat report"
DE[b_datum]="Datum"
EN[b_datum]="Date"
DE[b_spalten]="| Status | Paket | Hinweis |"
EN[b_spalten]="| Status | Package | Note |"
DE[b_entfernt]="entfernt"
EN[b_entfernt]="removed"
DE[b_nicht_da]="war nicht installiert"
EN[b_nicht_da]="was not installed"
DE[b_geschuetzt]="geschützt, übersprungen"
EN[b_geschuetzt]="protected, skipped"
DE[b_gescannt]="Gescannt"
EN[b_gescannt]="Scanned"
DE[b_legende]="Legende: ✅ entfernt · ❌ Fehler · ➖ nicht auf dem Gerät · 🛡️ geschützt"
EN[b_legende]="Legend: ✅ removed · ❌ error · ➖ not on device · 🛡️ protected"
DE[pfad_bericht]="Bericht (Markdown):     %s"
EN[pfad_bericht]="Report (Markdown):      %s"
DE[pfad_log]="Wiederherstellungs-Log: %s"
EN[pfad_log]="Restore log:            %s"
DE[pfad_restore]="Rückgängig:             %s --restore"
EN[pfad_restore]="Undo:                   %s --restore"
DE[pfad_scan]="Noch Xiaomi-Reste?      %s --scan"
EN[pfad_scan]="Xiaomi leftovers?       %s --scan"
DE[neustart]="Jetzt neu starten und testen: Anrufe, WLAN, Kamera, Benachrichtigungen."
EN[neustart]="Now reboot and test: calls, Wi-Fi, camera, notifications."
DE[unbekannt]="Unbekannte Option: %s (Hilfe: --help)"
EN[unbekannt]="Unknown option: %s (help: --help)"

t()  { if [[ "$SPRACHE" == "en" ]]; then printf '%s' "${EN[$1]}"; else printf '%s' "${DE[$1]}"; fi; }
tf() { local key="$1"; shift; printf "$(t "$key")" "$@"; }

hilfe() {
  if [[ "$SPRACHE" == "en" ]]; then
    cat <<EOF
HyperLight v$VERSION – Xiaomi debloater for the Redmi Note 13 4G (NFC)

Usage: ./hyperlight.sh [option] [--lang de|en]

  (no option)      show the list, ask for confirmation, remove
  --dry-run        only show what would happen, change nothing
  --scan           find Xiaomi packages that are on no list
  --restore        restore packages from the LAST run
  --restore-all    restore packages from ALL runs
  --lang de|en     choose language without being asked
  --help           show this help

Packages are removed with "pm uninstall --user 0": nothing is deleted
permanently, everything can be restored and comes back after a factory reset.
EOF
  else
    cat <<EOF
HyperLight v$VERSION – Xiaomi-Debloater für das Redmi Note 13 4G (NFC)

Nutzung: ./hyperlight.sh [Option] [--lang de|en]

  (keine Option)   Liste zeigen, nachfragen, entfernen
  --dry-run        nur anzeigen, nichts ändern
  --scan           Xiaomi-Pakete finden, die auf keiner Liste stehen
  --restore        Pakete aus dem LETZTEN Lauf zurückholen
  --restore-all    Pakete aus ALLEN Läufen zurückholen
  --lang de|en     Sprache wählen, ohne gefragt zu werden
  --help           diese Hilfe

Pakete werden mit "pm uninstall --user 0" entfernt: Nichts wird endgültig
gelöscht, alles lässt sich zurückholen und ist nach einem Werksreset wieder da.
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
  echo "           L  I  G  H  T    v$VERSION${RESET}"
  echo
}

# ---------------------------------------------------------------------------
# 5) Hilfsfunktionen / Helper functions
# ---------------------------------------------------------------------------
ist_geschuetzt() {
  local paket="$1" g p
  for g in "${GESCHUETZT[@]}"; do [[ "$paket" == "$g" ]] && return 0; done
  for p in "${GESCHUETZT_PRAEFIX[@]}"; do [[ "$paket" == "$p"* ]] && return 0; done
  return 1
}

steht_auf_liste() {
  local paket="$1" x
  for x in "${PAKETE[@]}"; do [[ "$paket" == "$x" ]] && return 0; done
  return 1
}

# ---------------------------------------------------------------------------
# 6) Argumente / Arguments   (Reihenfolge egal / any order)
# ---------------------------------------------------------------------------
MODUS="normal"
SPRACHE=""
while (( $# > 0 )); do
  case "$1" in
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

# ---------------------------------------------------------------------------
# 7) Sprache wählen / Choose language
# ---------------------------------------------------------------------------
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
# 8) Prüfungen / Checks
# ---------------------------------------------------------------------------
if (( BASH_VERSINFO[0] < 4 )); then
  echo "${ROT}$(tf bash_alt "$BASH_VERSION")${RESET}"; exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "${ROT}$(t kein_adb)${RESET}"; exit 1
fi

if [[ "$(adb get-state 2>/dev/null)" != "device" ]]; then
  echo "${ROT}$(t kein_geraet)${RESET}"
  t kein_geraet_1; echo; t kein_geraet_2; echo; t kein_geraet_3; echo
  exit 1
fi

# tr -d '\r' entfernt unsichtbare Zeilenende-Zeichen von adb
CODENAME=$(adb shell getprop ro.product.device | tr -d '\r')
MODELL=$(adb shell getprop ro.product.model | tr -d '\r')
tf geraet "$MODELL" "$CODENAME"; echo

if [[ "$CODENAME" != ${ERWARTETER_CODENAME}* ]]; then
  echo "${GELB}$(t falsches_geraet)${RESET}"
  t falsches_geraet_2; echo
  exit 1
fi

# ---------------------------------------------------------------------------
# 9) Wiederherstellen / Restore
# ---------------------------------------------------------------------------
if [[ "$MODUS" == restore* ]]; then
  # Sucht in neuem UND altem Log-Ordner (Kompatibilität mit v1.x/2.0)
  if [[ "$MODUS" == "restore" ]]; then
    DATEIEN=$(ls -1t "$LOG_ORDNER"/entfernt-*.txt "$ALTER_LOG_ORDNER"/entfernt-*.txt 2>/dev/null | head -n 1)
  else
    DATEIEN=$(ls -1 "$LOG_ORDNER"/entfernt-*.txt "$ALTER_LOG_ORDNER"/entfernt-*.txt 2>/dev/null)
  fi
  if [[ -z "$DATEIEN" ]]; then t kein_log; echo; exit 1; fi
  # sort -u = jedes Paket nur einmal / each package only once
  # shellcheck disable=SC2086
  sort -u $DATEIEN | while read -r PAKET; do
    [[ -z "$PAKET" ]] && continue
    ERGEBNIS=$(adb shell cmd package install-existing "$PAKET" 2>&1 | tr -d '\r')
    echo "  $PAKET -> $ERGEBNIS"
  done
  echo "${GRUEN}$(t restore_fertig)${RESET}"
  exit 0
fi

# ---------------------------------------------------------------------------
# 10) Installierte Pakete holen / Get installed packages
# ---------------------------------------------------------------------------
INSTALLIERT=$(adb shell pm list packages | tr -d '\r' | sed 's/^package://')

# ---------------------------------------------------------------------------
# 11) Scan
# ---------------------------------------------------------------------------
if [[ "$MODUS" == "scan" ]]; then
  echo; t scan_titel; echo
  GEFUNDEN=0
  while read -r PAKET; do
    [[ -z "$PAKET" ]] && continue
    steht_auf_liste "$PAKET" && continue
    ist_geschuetzt "$PAKET" && continue
    echo "  🔍 $PAKET"
    ((GEFUNDEN++))
  done < <(grep -iE "$XIAOMI_MUSTER" <<< "$INSTALLIERT" | sort)
  echo
  if (( GEFUNDEN == 0 )); then
    echo "${GRUEN}$(t scan_nichts)${RESET}"
  else
    echo "${GELB}$(tf scan_anzahl "$GEFUNDEN")${RESET}"
    t scan_tipp; echo
  fi
  exit 0
fi

# ---------------------------------------------------------------------------
# 12) Status bestimmen / Determine status
# ---------------------------------------------------------------------------
declare -A STATUS MELDUNG
ZU_ENTFERNEN=()

echo; t liste_titel; echo
for PAKET in "${PAKETE[@]}"; do
  if ist_geschuetzt "$PAKET"; then
    echo "  ${BLAU}🛡️  $PAKET $(t ist_geschuetzt)${RESET}"
    STATUS[$PAKET]="geschuetzt"
  elif grep -qx "$PAKET" <<< "$INSTALLIERT"; then
    echo "  ${GELB}- $PAKET${RESET}"
    ZU_ENTFERNEN+=("$PAKET")
    STATUS[$PAKET]="offen"
  else
    echo "    ($(t nicht_vorhanden): $PAKET)"
    STATUS[$PAKET]="nicht_vorhanden"
  fi
done

if (( ${#ZU_ENTFERNEN[@]} == 0 )); then
  echo "${GRUEN}$(t nichts_zu_tun)${RESET}"; exit 0
fi

if [[ "$MODUS" == "dry-run" ]]; then
  echo; t dry_run; echo; exit 0
fi

# ---------------------------------------------------------------------------
# 13) Sicherheitsabfrage / Confirmation
# ---------------------------------------------------------------------------
echo
read -r -p "$(tf frage "${#ZU_ENTFERNEN[@]}")" ANTWORT
case "${ANTWORT,,}" in            # ,, = in Kleinbuchstaben / to lowercase
  ja|j|yes|y) ;;
  *) t abbruch; echo; exit 0 ;;
esac

# ---------------------------------------------------------------------------
# 14) Entfernen / Remove
# ---------------------------------------------------------------------------
mkdir -p "$LOG_ORDNER"
ZEITSTEMPEL=$(date +%Y-%m-%d_%H-%M-%S)
LOG="$LOG_ORDNER/entfernt-$ZEITSTEMPEL.txt"
ERFOLG=0; FEHLER=0

for PAKET in "${ZU_ENTFERNEN[@]}"; do
  ERGEBNIS=$(adb shell pm uninstall --user 0 "$PAKET" 2>&1 | tr -d '\r')
  if [[ "$ERGEBNIS" == *Success* ]]; then
    echo "  ${GRUEN}✔ $PAKET${RESET}"
    echo "$PAKET" >> "$LOG"
    STATUS[$PAKET]="entfernt"
    ((ERFOLG++))
  else
    echo "  ${ROT}✘ $PAKET -> $ERGEBNIS${RESET}"
    STATUS[$PAKET]="fehler"
    MELDUNG[$PAKET]="$ERGEBNIS"
    ((FEHLER++))
  fi
done

# ---------------------------------------------------------------------------
# 15) Endbericht / Final report  (Terminal + Markdown)
# ---------------------------------------------------------------------------
NICHT_DA=0; GESCHUETZT_ANZ=0
for PAKET in "${PAKETE[@]}"; do
  [[ "${STATUS[$PAKET]}" == "nicht_vorhanden" ]] && ((NICHT_DA++))
  [[ "${STATUS[$PAKET]}" == "geschuetzt" ]] && ((GESCHUETZT_ANZ++))
done

BERICHT="$LOG_ORDNER/bericht-$ZEITSTEMPEL.md"
{
  echo "# HyperLight – $(t b_kopf) – $MODELL ($CODENAME)"
  echo
  echo "$(t b_datum): $(date '+%Y-%m-%d %H:%M') · HyperLight v$VERSION"
  echo
  t b_spalten; echo
  echo "|---|---|---|"
  for PAKET in "${PAKETE[@]}"; do
    case "${STATUS[$PAKET]}" in
      entfernt)        echo "| ✅ | \`$PAKET\` | $(t b_entfernt) |" ;;
      fehler)          echo "| ❌ | \`$PAKET\` | ${MELDUNG[$PAKET]} |" ;;
      nicht_vorhanden) echo "| ➖ | \`$PAKET\` | $(t b_nicht_da) |" ;;
      geschuetzt)      echo "| 🛡️ | \`$PAKET\` | $(t b_geschuetzt) |" ;;
    esac
  done
  echo
  echo "**$(t b_gescannt):** ${#PAKETE[@]} · ✅ $ERFOLG · ❌ $FEHLER · ➖ $NICHT_DA · 🛡️ $GESCHUETZT_ANZ"
  echo
  t b_legende; echo
} > "$BERICHT"

echo
echo "==================== $(t bericht_titel) ===================="
for PAKET in "${PAKETE[@]}"; do
  case "${STATUS[$PAKET]}" in
    entfernt)        printf "  %-36s ✅\n" "$PAKET" ;;
    fehler)          printf "  %-36s ❌  (%s)\n" "$PAKET" "${MELDUNG[$PAKET]}" ;;
    nicht_vorhanden) printf "  %-36s ➖\n" "$PAKET" ;;
    geschuetzt)      printf "  %-36s 🛡️\n" "$PAKET" ;;
  esac
done
echo "------------------------------------------------------"
echo "  $(t b_gescannt): ${#PAKETE[@]}  ✅ $ERFOLG  ❌ $FEHLER  ➖ $NICHT_DA  🛡️ $GESCHUETZT_ANZ"
echo "======================================================"
echo
tf pfad_bericht "$BERICHT"; echo
tf pfad_log "$LOG"; echo
tf pfad_restore "$0"; echo
tf pfad_scan "$0"; echo
echo
echo "${GELB}$(t neustart)${RESET}"

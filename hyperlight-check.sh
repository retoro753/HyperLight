#!/usr/bin/env bash
# =============================================================================
#  HyperLight Check – hyperlight-check.sh  –  Version 1.1
#  https://github.com/retoro753/HyperLight
#
#  Prüft, wie weit das Handy von Xiaomi und Google befreit ist (Audit).
#  Checks how free the phone is from Xiaomi and Google (audit).
#
#  NUR LESEN – ändert nichts am Handy. / READ-ONLY – changes nothing.
#
#  Liest die Paketlisten direkt aus hyperlight.sh und hyperlight-degoogle.sh
#  (müssen im selben Ordner liegen).
#
#  Getestet auf / Tested on:
#    Redmi Note 13 4G NFC (23124RA7EO, sapphiren), HyperOS 2.0.215.0, Android 15
#
#  Nutzung / Usage:  ./hyperlight-check.sh [--lang de|en] [--help]
#  Lizenz / License: MIT
# =============================================================================

VERSION="1.1"
set -u

ORDNER="$(cd "$(dirname "$0")" && pwd)"
DEBLOAT_SKRIPT="$ORDNER/hyperlight.sh"
DEGOOGLE_SKRIPT="$ORDNER/hyperlight-degoogle.sh"
ERWARTETER_CODENAME="sapphire"
LOG_ORDNER="$HOME/hyperlight-logs"

XIAOMI_MUSTER='miui|xiaomi|duokan|mi\.global|mi\.android|milink|mipay|xmsf'
GOOGLE_MUSTER='^com\.google\.|^com\.android\.chrome$|^com\.android\.vending$'

ROT=$'\e[31m'; GRUEN=$'\e[32m'; GELB=$'\e[33m'; BLAU=$'\e[34m'
CYAN=$'\e[36m'; FETT=$'\e[1m'; RESET=$'\e[0m'

# ---------------------------------------------------------------------------
# TEXTE / TEXTS
# ---------------------------------------------------------------------------
declare -A DE EN
DE[fehlt]="%s nicht gefunden. hyperlight-check.sh muss im selben Ordner liegen wie hyperlight.sh und hyperlight-degoogle.sh."
EN[fehlt]="%s not found. hyperlight-check.sh must be in the same folder as hyperlight.sh and hyperlight-degoogle.sh."
DE[bash_alt]="Bash %s ist zu alt – mindestens Version 4 nötig."
EN[bash_alt]="Bash %s is too old – version 4 or newer required."
DE[kein_adb]="adb nicht gefunden. Arch/Omarchy: sudo pacman -S android-tools"
EN[kein_adb]="adb not found. Arch/Omarchy: sudo pacman -S android-tools"
DE[kein_geraet]="Kein Gerät bereit. USB-Debugging an? Abfrage bestätigt? Test: adb devices"
EN[kein_geraet]="No device ready. USB debugging on? Prompt accepted? Test: adb devices"
DE[falsches_geraet]="Kein Redmi Note 13 4G (sapphire/sapphiren) – Abbruch."
EN[falsches_geraet]="Not a Redmi Note 13 4G (sapphire/sapphiren) – aborting."
DE[nur_lesen]="Nur-Lese-Modus: Am Handy wird NICHTS verändert."
EN[nur_lesen]="Read-only mode: NOTHING on the phone will be changed."
DE[s_geraet]="GERÄT"
EN[s_geraet]="DEVICE"
DE[s_xiaomi]="1) XIAOMI-BLOATWARE"
EN[s_xiaomi]="1) XIAOMI BLOATWARE"
DE[s_gapps]="2) GOOGLE-APPS (Degoogle Stufe 1)"
EN[s_gapps]="2) GOOGLE APPS (Degoogle stage 1)"
DE[s_gkern]="3) GOOGLE-KERN (Degoogle Stufe 2)"
EN[s_gkern]="3) GOOGLE CORE (Degoogle stage 2)"
DE[s_rest]="4) UNBEKANNTE RESTE"
EN[s_rest]="4) UNKNOWN LEFTOVERS"
DE[s_konten]="5) ANGEMELDETE KONTEN"
EN[s_konten]="5) SIGNED-IN ACCOUNTS"
DE[s_standard]="6) STANDARD-APPS"
EN[s_standard]="6) DEFAULT APPS"
DE[s_prozesse]="7) LAUFENDE PROZESSE"
EN[s_prozesse]="7) RUNNING PROCESSES"
DE[s_sicherheit]="8) SICHERHEIT & DATENSCHUTZ"
EN[s_sicherheit]="8) SECURITY & PRIVACY"
DE[entfernt_von]="%s von %s bekannten Paketen sind weg"
EN[entfernt_von]="%s of %s known packages are gone"
DE[davon_deakt]="davon %s deaktiviert (💤), weil Xiaomi das Entfernen blockiert"
EN[davon_deakt]="%s of them disabled (💤) because Xiaomi blocks removal"
DE[noch_da]="noch installiert:"
EN[noch_da]="still installed:"
DE[alles_weg]="Alles entfernt."
EN[alles_weg]="All removed."
DE[geschuetzt_info]="%s geschützte Systempakete bleiben absichtlich (Android braucht sie)."
EN[geschuetzt_info]="%s protected system packages stay on purpose (Android needs them)."
DE[kern_da]="noch aktiv"
EN[kern_da]="still active"
DE[kern_weg]="entfernt"
EN[kern_weg]="removed"
DE[keine_reste]="Keine unbekannten Xiaomi-/Google-Pakete."
EN[keine_reste]="No unknown Xiaomi/Google packages."
DE[reste_tipp]="Mit --scan in hyperlight.sh / hyperlight-degoogle.sh näher ansehen."
EN[reste_tipp]="Inspect with --scan in hyperlight.sh / hyperlight-degoogle.sh."
DE[konto_google]="Google-Konten: %s"
EN[konto_google]="Google accounts: %s"
DE[konto_xiaomi]="Xiaomi-Konten: %s"
EN[konto_xiaomi]="Xiaomi accounts: %s"
DE[r_DIALER]="Telefon"
EN[r_DIALER]="Phone"
DE[r_SMS]="SMS"
EN[r_SMS]="SMS"
DE[r_BROWSER]="Browser"
EN[r_BROWSER]="Browser"
DE[r_ASSISTANT]="Assistent"
EN[r_ASSISTANT]="Assistant"
DE[r_HOME]="Startbildschirm"
EN[r_HOME]="Launcher"
DE[ime]="Tastatur"
EN[ime]="Keyboard"
DE[keiner]="(keiner)"
EN[keiner]="(none)"
DE[home_info]="Xiaomi-Launcher – geschützt, das ist ok"
EN[home_info]="Xiaomi launcher – protected, that's fine"
DE[proz_info]="%s Google-Prozesse · %s Xiaomi-Prozesse laufen gerade"
EN[proz_info]="%s Google processes · %s Xiaomi processes running right now"
DE[proz_hinweis]="Ein Teil davon sind geschützte Systemdienste – das ist normal."
EN[proz_hinweis]="Some of them are protected system services – that's normal."
DE[patch]="Sicherheitspatch: %s (%s Tage alt)"
EN[patch]="Security patch: %s (%s days old)"
DE[patch_alt]="älter als 90 Tage – nach Updates schauen!"
EN[patch_alt]="older than 90 days – check for updates!"
DE[bl_zu]="Bootloader: gesperrt (verified boot: %s)"
EN[bl_zu]="Bootloader: locked (verified boot: %s)"
DE[bl_offen]="Bootloader: ENTSPERRT (verified boot: %s)"
EN[bl_offen]="Bootloader: UNLOCKED (verified boot: %s)"
DE[dns_an]="Privates DNS: %s"
EN[dns_an]="Private DNS: %s"
DE[dns_aus]="Privates DNS: aus (Tipp: dns.quad9.net)"
EN[dns_aus]="Private DNS: off (tip: dns.quad9.net)"
DE[dns_auto]="Privates DNS: automatisch (nicht erzwungen)"
EN[dns_auto]="Private DNS: automatic (not enforced)"
DE[usb_an]="USB-Debugging: AN – nach dem Test wieder ausschalten!"
EN[usb_an]="USB debugging: ON – turn it off after testing!"
DE[score]="HIGHSCORE"
EN[score]="HIGH SCORE"
DE[rang]="Rang"
EN[rang]="Rank"
DE[rang_S]="S – Komplett befreit! 🏆"
EN[rang_S]="S – Completely free! 🏆"
DE[rang_A]="A – Fast frei"
EN[rang_A]="A – Almost free"
DE[rang_B]="B – Gut entschlackt"
EN[rang_B]="B – Well debloated"
DE[rang_C]="C – Halbwegs"
EN[rang_C]="C – Halfway there"
DE[rang_D]="D – Da geht noch was"
EN[rang_D]="D – Room for improvement"
DE[score_hinweis]="Hinweis: Wer Google-Kern oder -Konto bewusst behält, kann kein S erreichen – das ist kein Fehler."
EN[score_hinweis]="Note: If you keep Google core or account on purpose, you can't reach S – that's not a mistake."
DE[bericht]="Bericht (Markdown): %s"
EN[bericht]="Report (Markdown): %s"
DE[unbekannt]="Unbekannte Option: %s (Hilfe: --help)"
EN[unbekannt]="Unknown option: %s (help: --help)"

t()  { if [[ "$SPRACHE" == "en" ]]; then printf '%s' "${EN[$1]}"; else printf '%s' "${DE[$1]}"; fi; }
tf() { local key="$1"; shift; printf "$(t "$key")" "$@"; }

# Ausgabe gleichzeitig ins Terminal UND (ohne Farben) in den Bericht
BERICHT_TEXT=""
zeile() {
  echo "$1"
  # sed entfernt die Farbcodes für die Markdown-Datei
  BERICHT_TEXT+="$(sed 's/\x1b\[[0-9;]*m//g' <<< "$1")"$'\n'
}
abschnitt() { zeile ""; zeile "${FETT}${CYAN}── $1 ──${RESET}"; }

banner() {
  echo "${CYAN}"
  echo "  ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ "
  echo "  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗"
  echo "  ███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝"
  echo "  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗"
  echo "  ██║  ██║   ██║   ██║     ███████╗██║  ██║"
  echo "  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝"
  echo "        L I G H T  ·  C H E C K   v$VERSION${RESET}"
  echo
}

hilfe() {
  if [[ "$SPRACHE" == "en" ]]; then
    echo "HyperLight Check v$VERSION – read-only audit: how free is the phone from Xiaomi & Google?"
    echo
    echo "Usage: ./hyperlight-check.sh [--lang de|en] [--help]"
    echo "Needs hyperlight.sh and hyperlight-degoogle.sh in the same folder (it reads their lists)."
  else
    echo "HyperLight Check v$VERSION – Nur-Lese-Audit: Wie frei ist das Handy von Xiaomi & Google?"
    echo
    echo "Nutzung: ./hyperlight-check.sh [--lang de|en] [--help]"
    echo "Braucht hyperlight.sh und hyperlight-degoogle.sh im selben Ordner (liest deren Listen)."
  fi
}

# ---------------------------------------------------------------------------
# Liest ein Bash-Array (z. B. PAKETE=( ... )) aus einem anderen Skript,
# OHNE das Skript auszuführen: nur die Paketnamen, ohne Kommentare.
# ---------------------------------------------------------------------------
lies_liste() {
  local datei="$1" name="$2"
  awk -v n="$name" '
    $0 ~ "^"n"=\\(" {f=1; next}
    f && /^\)/      {f=0}
    f {
      sub(/#.*/, "")             # Kommentar abschneiden
      gsub(/[[:space:]]/, "")    # Leerzeichen weg
      if (length($0) > 0) print
    }' "$datei"
}

# ---------------------------------------------------------------------------
# Argumente
# ---------------------------------------------------------------------------
SPRACHE=""; MODUS="check"
while (( $# > 0 )); do
  case "$1" in
    --lang)    shift; SPRACHE="${1:-}" ;;
    --help|-h) MODUS="help" ;;
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
[[ "$MODUS" == "help" ]] && { hilfe; exit 0; }

# ---------------------------------------------------------------------------
# Prüfungen
# ---------------------------------------------------------------------------
(( BASH_VERSINFO[0] < 4 )) && { echo "${ROT}$(tf bash_alt "$BASH_VERSION")${RESET}"; exit 1; }
for S in "$DEBLOAT_SKRIPT" "$DEGOOGLE_SKRIPT"; do
  [[ -f "$S" ]] || { echo "${ROT}$(tf fehlt "$(basename "$S")")${RESET}"; exit 1; }
done
command -v adb >/dev/null 2>&1 || { echo "${ROT}$(t kein_adb)${RESET}"; exit 1; }
[[ "$(adb get-state 2>/dev/null)" == "device" ]] || { echo "${ROT}$(t kein_geraet)${RESET}"; exit 1; }

getprop() { adb shell getprop "$1" | tr -d '\r'; }
CODENAME=$(getprop ro.product.device)
[[ "$CODENAME" == ${ERWARTETER_CODENAME}* ]] || { echo "${GELB}$(t falsches_geraet)${RESET}"; exit 1; }

echo "${GRUEN}$(t nur_lesen)${RESET}"

# ---------------------------------------------------------------------------
# Daten einsammeln
# ---------------------------------------------------------------------------
mapfile -t X_LISTE    < <(lies_liste "$DEBLOAT_SKRIPT"  PAKETE)
mapfile -t X_SCHUTZ   < <(lies_liste "$DEBLOAT_SKRIPT"  GESCHUETZT)
mapfile -t G_APPS     < <(lies_liste "$DEGOOGLE_SKRIPT" APPS)
mapfile -t G_KERN     < <(lies_liste "$DEGOOGLE_SKRIPT" KERN)
mapfile -t G_SCHUTZ   < <(lies_liste "$DEGOOGLE_SKRIPT" GESCHUETZT)
mapfile -t G_PRAEFIX  < <(lies_liste "$DEGOOGLE_SKRIPT" GESCHUETZT_PRAEFIX)
mapfile -t X_PRAEFIX  < <(lies_liste "$DEBLOAT_SKRIPT"  GESCHUETZT_PRAEFIX)

# -e = nur AKTIVE Pakete. Deaktivierte (💤) zählen als erledigt.
INSTALLIERT=$(adb shell pm list packages -e | tr -d '\r' | sed 's/^package://')
DEAKTIVIERT=$(adb shell pm list packages -d | tr -d '\r' | sed 's/^package://')
ist_deaktiviert() { grep -qx "$1" <<< "$DEAKTIVIERT"; }
zaehl_deaktiviert() { local p n=0; for p in "$@"; do ist_deaktiviert "$p" && ((n++)); done; echo "$n"; }
ist_installiert() { grep -qx "$1" <<< "$INSTALLIERT"; }

ist_bekannt() {   # steht auf irgendeiner Liste (entfernen oder geschützt)?
  local p="$1" x
  for x in "${X_LISTE[@]}" "${X_SCHUTZ[@]}" "${G_APPS[@]}" "${G_KERN[@]}" "${G_SCHUTZ[@]}"; do
    [[ "$p" == "$x" ]] && return 0
  done
  for x in "${G_PRAEFIX[@]}" "${X_PRAEFIX[@]}"; do [[ "$p" == "$x"* ]] && return 0; done
  return 1
}

# Zählt, wie viele Pakete einer Liste noch installiert sind -> Ausgabe: Liste der Reste
reste_von() { local p; for p in "$@"; do ist_installiert "$p" && echo "$p"; done; }

# ---------------------------------------------------------------------------
# GERÄT
# ---------------------------------------------------------------------------
MODELL=$(getprop ro.product.model)
HYPEROS=$(getprop ro.mi.os.version.incremental)
[[ -z "$HYPEROS" ]] && HYPEROS=$(getprop ro.build.version.incremental)
ANDROID=$(getprop ro.build.version.release)
abschnitt "$(t s_geraet)"
zeile "  $MODELL ($CODENAME) · HyperOS $HYPEROS · Android $ANDROID"
zeile "  $(date '+%Y-%m-%d %H:%M') · HyperLight Check v$VERSION"

# ---------------------------------------------------------------------------
# 1) Xiaomi
# ---------------------------------------------------------------------------
abschnitt "$(t s_xiaomi)"
mapfile -t X_REST < <(reste_von "${X_LISTE[@]}")
X_WEG=$(( ${#X_LISTE[@]} - ${#X_REST[@]} ))
if (( ${#X_REST[@]} == 0 )); then
  zeile "  ${GRUEN}✅ $(tf entfernt_von "$X_WEG" "${#X_LISTE[@]}") – $(t alles_weg)${RESET}"
else
  zeile "  ${GELB}⚠️  $(tf entfernt_von "$X_WEG" "${#X_LISTE[@]}"), $(t noch_da)${RESET}"
  for p in "${X_REST[@]}"; do zeile "     - $p"; done
fi
X_DEAKT=$(zaehl_deaktiviert "${X_LISTE[@]}")
(( X_DEAKT > 0 )) && zeile "  ${BLAU}💤 $(tf davon_deakt "$X_DEAKT")${RESET}"
X_SCHUTZ_DA=$(reste_von "${X_SCHUTZ[@]}" | grep -vE "$GOOGLE_MUSTER" | grep -c . || true)
zeile "  ${BLAU}🛡️  $(tf geschuetzt_info "$X_SCHUTZ_DA")${RESET}"

# ---------------------------------------------------------------------------
# 2) Google-Apps
# ---------------------------------------------------------------------------
abschnitt "$(t s_gapps)"
mapfile -t G_REST < <(reste_von "${G_APPS[@]}")
G_WEG=$(( ${#G_APPS[@]} - ${#G_REST[@]} ))
if (( ${#G_REST[@]} == 0 )); then
  zeile "  ${GRUEN}✅ $(tf entfernt_von "$G_WEG" "${#G_APPS[@]}") – $(t alles_weg)${RESET}"
else
  zeile "  ${GELB}⚠️  $(tf entfernt_von "$G_WEG" "${#G_APPS[@]}"), $(t noch_da)${RESET}"
  for p in "${G_REST[@]}"; do zeile "     - $p"; done
fi

G_DEAKT=$(zaehl_deaktiviert "${G_APPS[@]}")
(( G_DEAKT > 0 )) && zeile "  ${BLAU}💤 $(tf davon_deakt "$G_DEAKT")${RESET}"

# ---------------------------------------------------------------------------
# 3) Google-Kern
# ---------------------------------------------------------------------------
abschnitt "$(t s_gkern)"
K_WEG=0
for p in "${G_KERN[@]}"; do
  if ist_deaktiviert "$p"; then
    zeile "  ${BLAU}💤 $(printf '%-36s' "$p") $(t kern_weg) (💤)${RESET}"; ((K_WEG++))
  elif ist_installiert "$p"; then
    zeile "  ${GELB}⚠️  $(printf '%-36s' "$p") $(t kern_da)${RESET}"
  else
    zeile "  ${GRUEN}✅ $(printf '%-36s' "$p") $(t kern_weg)${RESET}"; ((K_WEG++))
  fi
done
G_SCHUTZ_DA=0
while read -r p; do
  [[ -z "$p" ]] && continue
  for x in "${G_SCHUTZ[@]}"; do [[ "$p" == "$x" ]] && { ((G_SCHUTZ_DA++)); continue 2; }; done
  for x in "${G_PRAEFIX[@]}"; do [[ "$p" == "$x"* ]] && { ((G_SCHUTZ_DA++)); continue 2; }; done
done < <(grep -E "$GOOGLE_MUSTER" <<< "$INSTALLIERT")
zeile "  ${BLAU}🛡️  $(tf geschuetzt_info "$G_SCHUTZ_DA")${RESET}"

# ---------------------------------------------------------------------------
# 4) Unbekannte Reste
# ---------------------------------------------------------------------------
abschnitt "$(t s_rest)"
UNBEKANNT=()
while read -r p; do
  [[ -z "$p" ]] && continue
  ist_bekannt "$p" || UNBEKANNT+=("$p")
done < <(grep -iE "$XIAOMI_MUSTER|$GOOGLE_MUSTER" <<< "$INSTALLIERT" | sort -u)
if (( ${#UNBEKANNT[@]} == 0 )); then
  zeile "  ${GRUEN}✅ $(t keine_reste)${RESET}"
else
  for p in "${UNBEKANNT[@]}"; do zeile "  🔍 $p"; done
  zeile "  ${GELB}$(t reste_tipp)${RESET}"
fi

# ---------------------------------------------------------------------------
# 5) Konten (nur Anzahl, keine Namen – Datenschutz)
# ---------------------------------------------------------------------------
abschnitt "$(t s_konten)"
KONTEN=$(adb shell dumpsys account 2>/dev/null | tr -d '\r' | grep -o "Account {[^}]*}" | sort -u)
N_GOOGLE=$(grep -c "type=com.google}" <<< "$KONTEN" || true)
N_XIAOMI=$(grep -c "type=com.xiaomi" <<< "$KONTEN" || true)
(( N_GOOGLE == 0 )) && S="${GRUEN}✅" || S="${GELB}⚠️ "
zeile "  $S $(tf konto_google "$N_GOOGLE")${RESET}"
(( N_XIAOMI == 0 )) && S="${GRUEN}✅" || S="${GELB}⚠️ "
zeile "  $S $(tf konto_xiaomi "$N_XIAOMI")${RESET}"

# ---------------------------------------------------------------------------
# 6) Standard-Apps
# ---------------------------------------------------------------------------
abschnitt "$(t s_standard)"
ROLLEN_OK=0
for R in DIALER SMS BROWSER ASSISTANT; do
  H=$(adb shell cmd role get-role-holders --user 0 "android.app.role.$R" 2>/dev/null | tr -d '\r')
  if [[ -z "$H" ]]; then
    if [[ "$R" == "ASSISTANT" ]]; then
      zeile "  ${GRUEN}✅ $(printf '%-16s' "$(t r_$R)") $(t keiner)${RESET}"; ((ROLLEN_OK++))
    else
      zeile "  ${GELB}⚠️  $(printf '%-16s' "$(t r_$R)") $(t keiner)${RESET}"
    fi
  elif grep -qiE "$XIAOMI_MUSTER|$GOOGLE_MUSTER" <<< "$H"; then
    zeile "  ${GELB}⚠️  $(printf '%-16s' "$(t r_$R)") $H${RESET}"
  else
    zeile "  ${GRUEN}✅ $(printf '%-16s' "$(t r_$R)") $H${RESET}"; ((ROLLEN_OK++))
  fi
done
HOME_APP=$(adb shell cmd role get-role-holders --user 0 android.app.role.HOME 2>/dev/null | tr -d '\r')
if [[ "$HOME_APP" == "com.miui.home" ]]; then
  zeile "  ${BLAU}🛡️  $(printf '%-16s' "$(t r_HOME)") $HOME_APP – $(t home_info)${RESET}"
else
  zeile "  ${GRUEN}✅ $(printf '%-16s' "$(t r_HOME)") ${HOME_APP:-$(t keiner)}${RESET}"
fi
IME=$(adb shell settings get secure default_input_method | tr -d '\r' | cut -d/ -f1)
if grep -qiE "$XIAOMI_MUSTER|$GOOGLE_MUSTER" <<< "$IME"; then
  zeile "  ${GELB}⚠️  $(printf '%-16s' "$(t ime)") $IME${RESET}"; IME_OK=0
else
  zeile "  ${GRUEN}✅ $(printf '%-16s' "$(t ime)") $IME${RESET}"; IME_OK=1
fi

# ---------------------------------------------------------------------------
# 7) Laufende Prozesse
# ---------------------------------------------------------------------------
abschnitt "$(t s_prozesse)"
PROZ=$(adb shell ps -A -o NAME 2>/dev/null | tr -d '\r')
N_PG=$(grep -cE '^com\.google\.|^com\.android\.vending|^com\.android\.chrome' <<< "$PROZ" || true)
N_PX=$(grep -ciE "$XIAOMI_MUSTER" <<< "$PROZ" || true)
zeile "  ℹ️  $(tf proz_info "$N_PG" "$N_PX")"
zeile "     $(t proz_hinweis)"

# ---------------------------------------------------------------------------
# 8) Sicherheit & Datenschutz
# ---------------------------------------------------------------------------
abschnitt "$(t s_sicherheit)"
PATCH=$(getprop ro.build.version.security_patch)
ALTER=$(( ( $(date +%s) - $(date -d "$PATCH" +%s 2>/dev/null || date +%s) ) / 86400 ))
if (( ALTER > 90 )); then
  zeile "  ${GELB}⚠️  $(tf patch "$PATCH" "$ALTER") – $(t patch_alt)${RESET}"
else
  zeile "  ${GRUEN}✅ $(tf patch "$PATCH" "$ALTER")${RESET}"
fi
VB=$(getprop ro.boot.verifiedbootstate)
if [[ "$(getprop ro.boot.flash.locked)" == "1" ]]; then
  zeile "  ${GRUEN}✅ $(tf bl_zu "${VB:-?}")${RESET}"
else
  zeile "  ${GELB}⚠️  $(tf bl_offen "${VB:-?}")${RESET}"
fi
DNS_MODUS=$(adb shell settings get global private_dns_mode | tr -d '\r')
DNS_HOST=$(adb shell settings get global private_dns_specifier | tr -d '\r')
DNS_OK=0
case "$DNS_MODUS" in
  hostname) zeile "  ${GRUEN}✅ $(tf dns_an "$DNS_HOST")${RESET}"; DNS_OK=1 ;;
  off)      zeile "  ${GELB}⚠️  $(t dns_aus)${RESET}" ;;
  *)        zeile "  ${GELB}⚠️  $(t dns_auto)${RESET}" ;;
esac
[[ "$(adb shell settings get global adb_enabled | tr -d '\r')" == "1" ]] && zeile "  ${GELB}⚠️  $(t usb_an)${RESET}"

# ---------------------------------------------------------------------------
# HIGHSCORE (max. 100 Punkte)
#   Xiaomi-Liste 30 · Google-Apps 25 · Google-Kern 15 · Konten 10
#   Standard-Apps 10 · Privates DNS 5 · keine unbekannten Reste 5
# ---------------------------------------------------------------------------
PKT=0
(( ${#X_LISTE[@]} > 0 )) && PKT=$(( PKT + 30 * X_WEG / ${#X_LISTE[@]} ))
(( ${#G_APPS[@]}  > 0 )) && PKT=$(( PKT + 25 * G_WEG / ${#G_APPS[@]} ))
(( ${#G_KERN[@]}  > 0 )) && PKT=$(( PKT + 15 * K_WEG / ${#G_KERN[@]} ))
(( N_GOOGLE == 0 )) && PKT=$(( PKT + 5 ))
(( N_XIAOMI == 0 )) && PKT=$(( PKT + 5 ))
PKT=$(( PKT + 2 * ROLLEN_OK + 2 * IME_OK ))
(( DNS_OK == 1 )) && PKT=$(( PKT + 5 ))
if   (( ${#UNBEKANNT[@]} == 0 )); then PKT=$(( PKT + 5 ))
elif (( ${#UNBEKANNT[@]} <= 3 )); then PKT=$(( PKT + 3 )); fi

if   (( PKT >= 90 )); then RANG="$(t rang_S)"
elif (( PKT >= 75 )); then RANG="$(t rang_A)"
elif (( PKT >= 60 )); then RANG="$(t rang_B)"
elif (( PKT >= 40 )); then RANG="$(t rang_C)"
else                       RANG="$(t rang_D)"; fi

# Fortschrittsbalken: 20 Kästchen
VOLL=$(( PKT / 5 )); BALKEN=""
for ((i=0; i<20; i++)); do (( i < VOLL )) && BALKEN+="█" || BALKEN+="░"; done

zeile ""
zeile "${FETT}${CYAN}╔══════════════════════════════════════════╗${RESET}"
zeile "${FETT}${CYAN}║            ★  $(printf '%-10s' "$(t score)")  ★              ║${RESET}"
zeile "${FETT}${CYAN}╚══════════════════════════════════════════╝${RESET}"
zeile "   ${FETT}$BALKEN  $PKT / 100${RESET}"
zeile "   $(t rang): ${FETT}$RANG${RESET}"
zeile ""
zeile "   $(t score_hinweis)"

# ---------------------------------------------------------------------------
# Bericht speichern
# ---------------------------------------------------------------------------
mkdir -p "$LOG_ORDNER"
BERICHT="$LOG_ORDNER/check-bericht-$(date +%Y-%m-%d_%H-%M-%S).md"
{
  echo "# HyperLight Check – $MODELL ($CODENAME)"
  echo
  echo '```'
  printf '%s' "$BERICHT_TEXT"
  echo '```'
} > "$BERICHT"
echo
tf bericht "$BERICHT"; echo

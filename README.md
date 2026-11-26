# 💡 HyperLight

**Xiaomi-Bloatware und Google per ADB entfernen – ohne Root, ohne Bootloader-Entsperrung.**
*Remove Xiaomi bloatware and Google via ADB – no root, no bootloader unlock.* ([English below](#english))

**HyperLight** besteht aus drei kleinen, gut kommentierten Bash-Skripten. Das Handy behält seine **offiziellen Sicherheitsupdates**, und jede Änderung lässt sich **rückgängig machen**.

| Skript | Wofür |
|---|---|
| 💡 [`hyperlight.sh`](#-hyperlightsh--xiaomi-bloatware-entfernen) | Entfernt Xiaomi-Werbung, Tracking-Dienste und vorinstallierte Apps |
| 🚫 [`hyperlight-degoogle.sh`](#-hyperlight-degooglesh--google-entfernen) | Entfernt Google-Apps und optional die Google-Dienste (zwei Stufen) |
| 🎮 [`hyperlight-check.sh`](#-hyperlight-checksh--abschlusstest-mit-highscore) | Abschlusstest: Wie frei ist das Handy von Xiaomi und Google? Mit Highscore (nur lesend) |

Empfohlene Reihenfolge: erst `hyperlight.sh`, dann bei Bedarf `hyperlight-degoogle.sh`, zum Schluss `hyperlight-check.sh`.

> [!WARNING]
> **Nutzung auf eigene Gefahr.** Die Skripte wurden nur auf dem unten genannten Gerät getestet. Sie brechen absichtlich ab, wenn ein anderes Gerät angeschlossen ist.

---

## ✅ Getestetes Gerät

| | |
|---|---|
| **Modell** | Redmi Note 13 4G NFC |
| **Modellnummer** | 23124RA7EO |
| **Codename** | `sapphiren` (läuft auch auf `sapphire`, die Variante ohne NFC) |
| **Software** | Xiaomi HyperOS 2.0.215.0 |
| **Android** | 15 |
| **Region** | EU (Global-ROM) |

Deinen Codenamen findest du mit:
```bash
adb shell getprop ro.product.device
```

---

## ✨ Gemeinsame Funktionen

- **🛡️ Schutzliste:** Systemkritische Pakete werden **nie** angefasst, auch nicht, wenn sie versehentlich in eine Liste eingetragen werden
- **Gerätecheck:** Bricht ab, wenn kein Redmi Note 13 4G angeschlossen ist
- **Probelauf** (`--dry-run`): zeigt, was passieren würde, ohne etwas zu ändern
- **Sicherheitsabfrage** vor jeder Änderung
- **Endbericht** im Terminal und als Markdown-Datei
- **🔍 Scan** (`--scan`): findet Pakete, die auf keiner Liste stehen
- **Wiederherstellung** (`--restore`, `--restore-all`)
- **Zweisprachig:** Deutsch oder Englisch, Auswahl beim Start oder per `--lang de|en`

---

## 💡 hyperlight.sh – Xiaomi-Bloatware entfernen

- **Entfernt 54 Pakete:** Xiaomi-Werbedienst (MSA), Analytics, GetApps, Mi Store, Mi Browser, Cloud-Dienste, ShareMe und vorinstallierte Drittanbieter-Apps (Amazon, LinkedIn, Bing, Facebook, Netflix …)
- **Geschützt:** Launcher, Berechtigungen, Akku-Verwaltung, Kamera, Galerie, Google-Play-Dienste …
- **Endbericht:** ✅ entfernt · ❌ Fehler · ➖ nicht vorhanden · 🛡️ geschützt

---

## 🚫 hyperlight-degoogle.sh – Google entfernen

Arbeitet in **zwei Stufen**:

| Stufe | Befehl | Was wird entfernt |
|---|---|---|
| **1 – Google-Apps** | `./hyperlight-degoogle.sh` | 36 Pakete: YouTube, Gmail, Maps, Fotos, Drive, Meet, Kalender, Keep, News, Home, Wallet, Google One, Google-App, Assistant, Gemini, Lens, Feedback- und Telemetrie-Dienste, Chrome, Telefon, Kontakte, Messages, Gboard … |
| **2 – Google-Kern** | `./hyperlight-degoogle.sh --core` | Zusätzlich **Play-Dienste**, **Play Store**, **Google Services Framework**, Google-Backup |

### ⚠️ Ersatz-Prüfung (Stufe 1)
Telefon, Kontakte, Messages, Tastatur und Chrome werden **nur entfernt, wenn bereits eine andere App als Standard eingestellt ist**. Sonst bekommen sie im Endbericht ein ⚠️ und bleiben drauf. So kannst du nie ohne Telefon-App oder Tastatur dastehen.

| Google-App | Ersatz (z. B. aus [F-Droid](https://f-droid.org)) | Als Standard setzen |
|---|---|---|
| Telefon + Kontakte | Fossify Phone + Fossify Contacts | *Einstellungen → Apps → Standard-Apps → Telefon* |
| Messages | Fossify Messages | *… → Standard-Apps → SMS* |
| Gboard | HeliBoard | *Einstellungen → Weitere Einstellungen → Sprachen & Eingabe* |
| Chrome | Firefox | *… → Standard-Apps → Browser* |

Danach das Skript einfach erneut starten.

### 🔒 Stufe 2 (`--core`) – bitte lesen
> [!CAUTION]
> - Stufe 2 ist **gesperrt, solange ein Google-Konto auf dem Handy angemeldet ist.** Grund: Nach einem Werksreset verlangt Android genau dieses Konto (Diebstahlschutz / FRP). Kommst du nicht mehr hinein, ist das Handy gesperrt. Konto vorher entfernen: *Einstellungen → Konten & Synchronisierung → Google → Konto entfernen*.
> - Zur Bestätigung muss **`DEGOOGLE`** eingetippt werden.
> - Danach funktionieren **nicht mehr:** Play Store (→ F-Droid / Aurora Store), Push-Benachrichtigungen vieler Apps, Apps mit Google-Abhängigkeit (Banking, manche Spiele), schnelle Netzwerk-Ortung (GPS funktioniert weiter).

### 🛡️ Geschützte Google-Pakete
Einige Google-Pakete **sind** Android selbst und werden nie angefasst: WebView, Berechtigungs-Controller, Paket-Installer, Dateiauswahl, Netzwerk-Stack, WLAN-Login, Notfallwarnungen (Cell Broadcast), System-Module (Mainline) u. a.

### Wiederherstellung
`--restore` / `--restore-all` nutzen **eigene Logs** (`degoogle-entfernt-*.txt`), getrennt von `hyperlight.sh`. Play-Dienste werden dabei immer zuerst zurückgeholt.

---

## 🎮 hyperlight-check.sh – Abschlusstest mit Highscore

Ein **Audit**, das prüft, wie weit dein Handy von Xiaomi und Google befreit ist. Es **liest nur** und verändert nichts am Handy.

> [!NOTE]
> `hyperlight-check.sh` muss **im selben Ordner** liegen wie `hyperlight.sh` und `hyperlight-degoogle.sh`. Es liest deren Paketlisten direkt aus, ohne sie auszuführen. So passen die Prüfungen immer zu den aktuellen Listen.

**Was geprüft wird:**

| # | Bereich | Prüfung |
|---|---|---|
| 1 | Xiaomi-Bloatware | Welche bekannten Pakete sind noch installiert? |
| 2 | Google-Apps | Stand von Degoogle Stufe 1 |
| 3 | Google-Kern | Play-Dienste, Play Store, GSF, Google-Backup |
| 4 | Unbekannte Reste | Xiaomi-/Google-Pakete, die auf keiner Liste stehen |
| 5 | Konten | Anzahl angemeldeter Google- und Xiaomi-Konten (keine Namen/E-Mails) |
| 6 | Standard-Apps | Telefon, SMS, Browser, Assistent, Tastatur: noch Google/Xiaomi? |
| 7 | Prozesse | Wie viele Google-/Xiaomi-Prozesse laufen gerade? |
| 8 | Sicherheit | Alter des Sicherheitspatches, Bootloader gesperrt?, Privates DNS, USB-Debugging |

**Highscore (max. 100 Punkte):**

```
╔══════════════════════════════════════════╗
║            ★  HIGHSCORE   ★              ║
╚══════════════════════════════════════════╝
   ███████████████░░░░░  77 / 100
   Rang: A – Fast frei
```

| Bereich | Punkte |
|---|---|
| Xiaomi-Liste entfernt | 30 |
| Google-Apps entfernt | 25 |
| Google-Kern entfernt | 15 |
| Kein Google-/Xiaomi-Konto | 10 |
| Standard-Apps ohne Google/Xiaomi | 10 |
| Privates DNS aktiv | 5 |
| Keine unbekannten Reste | 5 |

**Ränge:** S ≥ 90 (komplett befreit 🏆) · A ≥ 75 · B ≥ 60 · C ≥ 40 · D

Wer Google-Kern oder -Konto **bewusst behält**, kann kein S erreichen. Das ist kein Fehler, der Score zeigt nur, wie weit man gegangen ist.

Der Bericht wird zusätzlich als `~/hyperlight-logs/check-bericht-DATUM.md` gespeichert.

---

## 📋 Voraussetzungen

- Ein Rechner mit **Linux** oder **macOS**
- **ADB** (Android Debug Bridge)
- **Bash 4 oder neuer** (macOS bringt nur Bash 3.2 mit → `brew install bash`)
- Ein USB-**Datenkabel** (manche Kabel können nur laden)

### ADB installieren

| System | Befehl |
|---|---|
| Arch / Omarchy | `sudo pacman -S android-tools` |
| Debian / Ubuntu | `sudo apt install adb` |
| Fedora | `sudo dnf install android-tools` |
| macOS | `brew install android-platform-tools bash` |

---

## 🚀 Anleitung

### 1. USB-Debugging am Handy aktivieren
1. *Einstellungen → Über das Telefon* → **7× auf „OS-Version“ tippen**
2. *Einstellungen → Weitere Einstellungen → Entwickleroptionen* → **USB-Debugging** an
3. Handy per USB anschließen und am Handy **„Zulassen“** tippen

### 2. Verbindung prüfen
```bash
adb devices
```
Erwartete Ausgabe: `XXXXXXXX    device`

| Ausgabe | Lösung |
|---|---|
| `unauthorized` | Abfrage am Handy bestätigen |
| `no permissions` | Linux: `sudo pacman -S android-udev` bzw. udev-Regeln installieren, Kabel neu einstecken |
| *(leer)* | Anderes Kabel probieren |

### 3. Skript herunterladen
```bash
git clone https://github.com/retoro753/HyperLight.git
cd HyperLight
chmod +x hyperlight.sh hyperlight-degoogle.sh hyperlight-check.sh
```

> [!TIP]
> **Lies die Skripte, bevor du sie ausführst.** Führ nie Skripte aus dem Internet blind aus, auch diese nicht. Sie sind bewusst ausführlich kommentiert.

### 4. Probelauf
```bash
./hyperlight.sh --dry-run
```

### 5. Ausführen
```bash
./hyperlight.sh
```
Beim Start Sprache wählen (1 = Deutsch, 2 = English), dann mit `ja` bestätigen. Danach das Handy **neu starten** und testen: Anrufe, WLAN, Kamera, Benachrichtigungen.

### 6. Optional: Google entfernen
```bash
./hyperlight-degoogle.sh --dry-run           # Stufe 1 ansehen
./hyperlight-degoogle.sh                     # Stufe 1: Google-Apps
./hyperlight-degoogle.sh --core --dry-run    # Stufe 2 ansehen
./hyperlight-degoogle.sh --core              # Stufe 2: Google komplett
```

### 7. Abschlusstest
```bash
./hyperlight-check.sh
```
Zeigt, was noch übrig ist, und vergibt einen Highscore. Danach **USB-Debugging wieder ausschalten**.

---

## 🧰 Alle Optionen

`hyperlight.sh` und `hyperlight-degoogle.sh` verstehen dieselben Optionen (`hyperlight-degoogle.sh` zusätzlich `--core`). `hyperlight-check.sh` kennt nur `--lang de|en` und `--help`.

| Befehl | Was passiert |
|---|---|
| `./hyperlight.sh` | Zeigt die Liste, fragt nach, entfernt |
| `./hyperlight.sh --dry-run` | Nur anzeigen, nichts ändern |
| `./hyperlight.sh --scan` | Xiaomi-Pakete finden, die auf keiner Liste stehen |
| `./hyperlight.sh --restore` | Pakete aus dem letzten Lauf zurückholen |
| `./hyperlight.sh --restore-all` | Pakete aus allen Läufen zurückholen |
| `./hyperlight.sh --lang de` / `--lang en` | Sprache festlegen, ohne gefragt zu werden (kombinierbar, z. B. `--dry-run --lang en`) |
| `./hyperlight.sh --help` | Hilfe anzeigen |
| `./hyperlight-degoogle.sh --core` | Stufe 2: auch Google-Dienste entfernen (kombinierbar mit `--dry-run`) |

Logs und Berichte werden in `~/hyperlight-logs/` gespeichert.

---

## ✏️ Listen anpassen

Öffne das Skript in einem Texteditor. Ganz oben stehen die Listen: `PAKETE=( … )` in `hyperlight.sh`, `APPS=( … )` und `KERN=( … )` in `hyperlight-degoogle.sh`:

- Ein Paket **behalten**: `#` an den Zeilenanfang setzen
- Ein Paket **hinzufügen**: neue Zeile mit dem Paketnamen

> [!IMPORTANT]
> Folgende Apps entfernt `hyperlight.sh` standardmäßig. Installiere dir **vorher Ersatz**, z. B. aus [F-Droid](https://f-droid.org):
> - **Taschenrechner** (`com.miui.calculator`)
> - **Scanner / QR-Code-Leser** (`com.xiaomi.scanner`) → z. B. *Binary Eye*
> - **Notizen**, **Wetter**, **UKW-Radio**, **Mi Fernbedienung**

---

## ↩️ Rückgängig machen

Beide Skripte nutzen `pm uninstall --user 0`. Damit werden Apps **nur für den aktuellen Benutzer** entfernt, die Dateien bleiben im System. Darum gibt es drei Wege zurück:

1. `./hyperlight.sh --restore` bzw. `./hyperlight-degoogle.sh --restore` (oder `--restore-all`)
2. Einzelnes Paket: `adb shell cmd package install-existing PAKETNAME`
3. **Werksreset**: Danach ist alles wieder da

---

## ❓ FAQ

**Brauche ich Root oder einen entsperrten Bootloader?**
Nein. Das ist der Sinn der Skripte.

**Bekomme ich weiterhin Updates?**
Ja. Große HyperOS-Updates können einzelne Apps aber zurückbringen. Lass die Skripte danach einfach nochmal laufen.

**Funktioniert es auf anderen Xiaomi/Redmi/POCO-Geräten?**
Nicht getestet. Die Skripte brechen bei anderen Codenamen ab. Wer es auf einem anderen Gerät testen will, kann `ERWARTETER_CODENAME` anpassen, aber **nur mit `--dry-run` anfangen** und auf eigene Gefahr.

**Werden Google-Apps entfernt?**
Von `hyperlight.sh` nicht: Dort stehen Google-Play-Dienste und Play Store auf der Schutzliste. Dafür gibt es `hyperlight-degoogle.sh`.

**Ist ein Handy ohne Google noch alltagstauglich?**
Mit Stufe 1 ja, fast ohne Einschränkungen. Stufe 2 ist eher für Test- und Zweitgeräte oder Leute, die bewusst auf Google verzichten wollen. Viele Apps funktionieren dann nur eingeschränkt.

---

## 🙏 Inspiration

- [Universal Android Debloater Next Generation (UAD-ng)](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation): ein umfangreiches grafisches Debloat-Tool für viele Hersteller

---

## 📄 Lizenz

[MIT](LICENSE)

---

<a name="english"></a>
## 🇬🇧 English

Three small, well-commented Bash scripts that work via **ADB**, **without root** and **without unlocking the bootloader**. The phone keeps its official security updates, and every change can be undone.

- 💡 **`hyperlight.sh`** removes Xiaomi ads, tracking services and preinstalled apps.
- 🎮 **`hyperlight-check.sh`** is a read-only audit: it checks leftovers, accounts, default apps, running processes, security patch, bootloader and Private DNS, and gives you a high score (rank S–D). Must be in the same folder as the other two scripts.
- 🚫 **`hyperlight-degoogle.sh`** removes Google apps (stage 1) and optionally Play services, Play Store and GSF (stage 2, `--core`). Phone, SMS, contacts, keyboard and Chrome are only removed if a replacement is already set as default. Stage 2 is blocked while a Google account is signed in (factory reset protection) and requires typing `DEGOOGLE`.

**Tested on:** Redmi Note 13 4G NFC (23124RA7EO, codename `sapphiren`), Xiaomi HyperOS 2.0.215.0, Android 15, EU ROM. The scripts refuse to run on other devices.

**Requirements:** Linux or macOS, `adb`, Bash ≥ 4 (macOS: `brew install bash`), USB debugging enabled.

```bash
git clone https://github.com/retoro753/HyperLight.git
cd HyperLight
chmod +x hyperlight.sh hyperlight-degoogle.sh hyperlight-check.sh
./hyperlight.sh --dry-run                    # preview, changes nothing
./hyperlight.sh --lang en                    # run in English (confirm with "yes")
./hyperlight.sh --restore                    # undo last run
./hyperlight-degoogle.sh --lang en           # stage 1: Google apps
./hyperlight-degoogle.sh --core --lang en    # stage 2: Google services too
./hyperlight-check.sh --lang en              # final audit with high score
```

**Features:** protected-package list (critical system apps are never touched), device check, dry run, confirmation prompt, final report (terminal + Markdown), `--scan` for unknown packages, restore options.

Both scripts ask for your language at startup (German or English), or use `--lang en`. Code comments are mostly German with English hints. Packages are removed with `pm uninstall --user 0` (user-level only, reversible, restored by a factory reset).

> **Use at your own risk.** Read the scripts before running them.

License: [MIT](LICENSE)

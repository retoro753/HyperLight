# 💡 HyperLight

**Xiaomi-Bloatware per ADB entfernen – ohne Root, ohne Bootloader-Entsperrung.**
*Remove Xiaomi bloatware via ADB – no root, no bootloader unlock.* ([English below](#english))

**HyperLight** ist ein kleines, gut kommentiertes Bash-Skript, das Werbung, Tracking-Dienste und vorinstallierte Apps von Xiaomi-Smartphones entfernt. Das Handy behält seine **offiziellen Sicherheitsupdates**, und jede Änderung lässt sich **rückgängig machen**.

> [!WARNING]
> **Nutzung auf eigene Gefahr.** Das Skript wurde nur auf dem unten genannten Gerät getestet. Es bricht absichtlich ab, wenn ein anderes Gerät angeschlossen ist.

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

## ✨ Funktionen

- **Entfernt 54 Pakete:** Xiaomi-Werbedienst (MSA), Analytics, GetApps, Mi Store, Mi Browser, Cloud-Dienste, ShareMe und vorinstallierte Drittanbieter-Apps (Amazon, LinkedIn, Bing, Facebook, Netflix …)
- **🛡️ Schutzliste:** Systemkritische Pakete (Launcher, Berechtigungen, Akku-Verwaltung, Kamera …) werden **nie** angefasst, auch nicht, wenn sie versehentlich in die Liste eingetragen werden
- **Gerätecheck:** Bricht ab, wenn kein Redmi Note 13 4G angeschlossen ist
- **Probelauf** (`--dry-run`): zeigt, was passieren würde, ohne etwas zu ändern
- **Sicherheitsabfrage** vor jeder Änderung
- **Endbericht** im Terminal und als Markdown-Datei (✅ entfernt · ❌ Fehler · ➖ nicht vorhanden · 🛡️ geschützt)
- **🔍 Scan** (`--scan`): findet Xiaomi-Pakete, die auf keiner Liste stehen
- **Wiederherstellung** (`--restore`, `--restore-all`)
- **Zweisprachig:** Deutsch oder Englisch, Auswahl beim Start oder per `--lang de|en`

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
chmod +x hyperlight.sh
```

> [!TIP]
> **Lies das Skript, bevor du es ausführst.** Führ nie Skripte aus dem Internet blind aus, auch dieses nicht. Es ist bewusst ausführlich kommentiert.

### 4. Probelauf
```bash
./hyperlight.sh --dry-run
```

### 5. Ausführen
```bash
./hyperlight.sh
```
Beim Start Sprache wählen (1 = Deutsch, 2 = English), dann mit `ja` bestätigen. Danach das Handy **neu starten** und testen: Anrufe, WLAN, Kamera, Benachrichtigungen.

---

## 🧰 Alle Optionen

| Befehl | Was passiert |
|---|---|
| `./hyperlight.sh` | Zeigt die Liste, fragt nach, entfernt |
| `./hyperlight.sh --dry-run` | Nur anzeigen, nichts ändern |
| `./hyperlight.sh --scan` | Xiaomi-Pakete finden, die auf keiner Liste stehen |
| `./hyperlight.sh --restore` | Pakete aus dem letzten Lauf zurückholen |
| `./hyperlight.sh --restore-all` | Pakete aus allen Läufen zurückholen |
| `./hyperlight.sh --lang de` / `--lang en` | Sprache festlegen, ohne gefragt zu werden (kombinierbar, z. B. `--dry-run --lang en`) |
| `./hyperlight.sh --help` | Hilfe anzeigen |

Logs und Berichte werden in `~/hyperlight-logs/` gespeichert.

---

## ✏️ Liste anpassen

Öffne `hyperlight.sh` in einem Texteditor. Ganz oben steht die Liste `PAKETE=( … )`:

- Ein Paket **behalten**: `#` an den Zeilenanfang setzen
- Ein Paket **hinzufügen**: neue Zeile mit dem Paketnamen

> [!IMPORTANT]
> Folgende Apps entfernt das Skript standardmäßig. Installiere dir **vorher Ersatz**, z. B. aus [F-Droid](https://f-droid.org):
> - **Taschenrechner** (`com.miui.calculator`)
> - **Scanner / QR-Code-Leser** (`com.xiaomi.scanner`) → z. B. *Binary Eye*
> - **Notizen**, **Wetter**, **UKW-Radio**, **Mi Fernbedienung**

---

## ↩️ Rückgängig machen

Das Skript nutzt `pm uninstall --user 0`. Damit werden Apps **nur für den aktuellen Benutzer** entfernt, die Dateien bleiben im System. Darum gibt es drei Wege zurück:

1. `./hyperlight.sh --restore` oder `--restore-all`
2. Einzelnes Paket: `adb shell cmd package install-existing PAKETNAME`
3. **Werksreset**: Danach ist alles wieder da

---

## ❓ FAQ

**Brauche ich Root oder einen entsperrten Bootloader?**
Nein. Das ist der Sinn des Skripts.

**Bekomme ich weiterhin Updates?**
Ja. Große HyperOS-Updates können einzelne Apps aber zurückbringen. Lass das Skript danach einfach nochmal laufen.

**Funktioniert es auf anderen Xiaomi/Redmi/POCO-Geräten?**
Nicht getestet. Das Skript bricht bei anderen Codenamen ab. Wer es auf einem anderen Gerät testen will, kann `ERWARTETER_CODENAME` anpassen, aber **nur mit `--dry-run` anfangen** und auf eigene Gefahr.

**Werden Google-Apps entfernt?**
Nein, nur Xiaomi- und vorinstallierte Drittanbieter-Apps. Google-Play-Dienste und Play Store stehen auf der Schutzliste.

---

## 🙏 Inspiration

- [Universal Android Debloater Next Generation (UAD-ng)](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation): ein umfangreiches grafisches Debloat-Tool für viele Hersteller

---

## 📄 Lizenz

[MIT](LICENSE)

---

<a name="english"></a>
## 🇬🇧 English

A small, well-commented Bash script that removes ads, tracking services and preinstalled apps from Xiaomi phones via **ADB**, **without root** and **without unlocking the bootloader**. The phone keeps its official security updates, and every change can be undone.

**Tested on:** Redmi Note 13 4G NFC (23124RA7EO, codename `sapphiren`), Xiaomi HyperOS 2.0.215.0, Android 15, EU ROM. The script refuses to run on other devices.

**Requirements:** Linux or macOS, `adb`, Bash ≥ 4 (macOS: `brew install bash`), USB debugging enabled.

```bash
git clone https://github.com/retoro753/HyperLight.git
cd HyperLight
chmod +x hyperlight.sh
./hyperlight.sh --dry-run   # preview, changes nothing
./hyperlight.sh --lang en   # run in English (confirm with "yes")
./hyperlight.sh --restore   # undo last run
```

**Features:** protected-package list (critical system apps are never touched), device check, dry run, confirmation prompt, final report (terminal + Markdown), `--scan` for unknown Xiaomi packages, restore options.

The script asks for your language at startup (German or English), or use `--lang en`. Code comments are mostly German with English hints. Packages are removed with `pm uninstall --user 0` (user-level only, reversible, restored by a factory reset).

> **Use at your own risk.** Read the script before running it.

License: [MIT](LICENSE)

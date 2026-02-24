# The Solar App

[🇬🇧 English](README.md) | 🇩🇪 **Deutsch**

Eine Flutter-Anwendung für Windows, Android und Linux zur Verwaltung und Überwachung von Mikrowechselrichtern und Powerstationen.
Lokale Verbindung über Bluetooth oder WiFi ohne Cloud-Dienste oder Benutzerregistrierung erforderlich.
Unterstützte Hersteller sind [Hoymiles](#hoymiles-wifinetwork), [Deye Sun](#deyesun-wifinetwork), [Zendure](#zendure-bluetooth--wifi), [Shelly](#shelly-bluetooth--wifinetwork), [Kostal](#kostal-wifinetwork) und [OpenDTU](#opendtu-wifinetwork).

## ⚠️ Haftungsausschluss

Dieses Projekt wird "wie besehen" zur Verfügung gestellt, ohne jegliche Gewährleistung.
Es gibt keine Garantie dafür, dass die Implementierung der Geräteprotokolle oder APIs korrekt oder vollständig ist.
Die Verwendung dieser Software kann möglicherweise zu Fehlfunktionen, Beschädigungen oder Zerstörung von Gerätehardware oder -software führen.
Nutzung auf eigene Gefahr.

Wenn Sie dieses Projekt verwenden, geschieht dies auf Ihre eigene Verantwortung. Stellen Sie sicher, dass Sie wissen, was Sie tun.

## Übersicht

Die Solar App bietet direkte lokale Steuerung und Überwachung (nur aktuelle Werte) von Solar-Mikrowechselrichtern und Smart-Energy-Geräten.
Es ist möglich die Solarproduktion zu verfolgen, Geräteeinstellungen zu konfigurieren oder Leistungsgrenzen zu verwalten - die App ermöglicht die lokale Kontrolle über die Geräte.
Unterstützt auch OpenDTU für eine einfachere Geräteverwaltung.

## Screenshots

Einige Screenshots, um einen Eindruck von der App zu bekommen:

- **[Mobile-Screenshots](doc/images/mobile/README.md)** - Android-App-Oberfläche und Funktionen
- **[Desktop-Screenshots](doc/images/desktop/README.md)** - Linux/Windows-Desktop-Oberfläche

### Hauptmerkmale

- **Privatsphäre zuerst**: Keine Anmeldung, keine Registrierung, keine Cloud-Abhängigkeit
- **Lokale Verbindung**: Verbindung über Bluetooth Low Energy oder WiFi/LAN
- **Multi-Device-Unterstützung**: Kompatibel mit mehreren Marken und Gerätetypen
- **Echtzeit-Überwachung**: Verfolgen Sie Stromerzeugung, Verbrauch und Batteriestand
- **Gerätekonfiguration**: WiFi-Einrichtung, Leistungsgrenzen, Access-Point-Konfiguration
- **Cross-Platform**: Mit Flutter entwickelt für mobile Geräte (Android) und Desktop-Unterstützung
- **Systemansicht**: Kombinieren Sie mehrere Geräte zu einheitlichen Solarsystemen mit aggregierten Metriken
- **Shelly Script-Automatisierung**: Bereitstellen von JavaScript-Automatisierungsvorlagen für Nulleinspeisung und Überwachung

## Aktuell unterstützt

### Plattformen
- **Android** ✅ (Primäre Plattform)
- **Linux** ✅ (Kein Bluetooth)
- **Windows** ✅ (Kein Bluetooth)

### Unterstützte Geräte

#### Shelly (Bluetooth & WiFi/Network)
- **Unterstützte Module**: EM (3-Phasen-Zähler), Switch (Smart Plug), EM1 (Einphasen-Zähler), EM1Data (Energiesummen), EMData (3-Phasen-Energiesummen), Temperature (Sensor), PM1 (Gen3 Leistungsmesser)
- **Verbindungstypen**: Bluetooth Low Energy, WiFi/Network (HTTP JSON-RPC 2.0)
- **Authentifizierung**: RFC7616 Digest-Authentifizierung mit SHA-256
- **Überwachung** (je Modultyp):
  - **EM**: 3-Phasen-Spannung, Strom, Wirkleistung pro Phase; Gesamtwirkleistung
  - **Switch**: Spannung, Strom, Wirkleistung, Temperatur, Gesamtenergie
  - **EM1**: Einphasen-Spannung, Strom, Wirk-/Scheinleistung, Leistungsfaktor, Frequenz
  - **EM1Data/EMData**: Gesamtenergie Import/Export (pro Instanz/Phase)
  - **Temperature**: Temperatursensor-Messwerte
  - **PM1 (Gen3)**: Einphasen-Überwachung mit bidirektionalem Energie-Tracking
- **Konfiguration**:
  - WiFi/AP-Einrichtung
  - RPC-Port-Konfiguration
  - Authentifizierungseinstellungen
  - Ein/Aus-Schaltung (Switch-Modul)
  - Geräteneustart

#### DeyeSun (WiFi/Network)
- **Mikrowechselrichter**: Solarwechselrichter mit Dual-Protokoll-Unterstützung
- **Verbindungstypen**: WiFi/Network (HTTP/1.0 HTTPD mit Basic Auth, Modbus TCP auf konfigurierbarem Port)
- **Überwachung**: Echtzeit-Solarproduktion mit bis zu 4 PV-String-Eingängen (Spannung, Strom, Leistung pro String, Tages-/Gesamtertrag), AC-Netzüberwachung (Spannung, Strom, Frequenz, Leistung), Kühlertemperatur, Gerätebetriebszeit, Betriebszeiterfassung
- **Konfiguration**:
  - Leistungsgrenze (prozentbasiert)
  - Wechselrichter Ein/Aus-Umschaltung
  - Online-Überwachung (Server A/B-Konfiguration)
  - WiFi-Einrichtung (STA-Modus)
  - Access-Point-Konfiguration mit Sicherheitsoptionen
  - Geräteneustart

#### Zendure (Bluetooth & WiFi)
- **Powerstationen**: Tragbare Powerstationen und Energiespeichersysteme
- **Verbindungstypen**: Bluetooth Low Energy, WiFi/Network (REST API)
- **Überwachung**: Batteriestand (SOC mit Lade-/Entladezustand), Solar-Eingangsleistung, Netz-Eingangsleistung, Haus-Ausgangsleistung, Pack-Leistung (Eingang/Ausgang), Ausgangsgrenze, Pack-Zustand, Batteriepack-Daten (Spannung, Strom pro Pack), WiFi/Cloud-Verbindungsstatus, Firmware-Version
- **Konfiguration**:
  - Leistungsgrenzen (Eingang/Ausgang mit Modusauswahl)
  - Batterie-SOC-Grenzen (min 5-40%, max 80-100%)
  - Erweiterte Leistungseinstellungen (max. Wechselrichterleistung, Netzrückspeisung, Netzstandard)
  - Notstrom-versorgung/steckdose (3 Modi: normal/energiesparend/aus)
  - Lampen-/Licht-Umschaltung
  - WiFi/MQTT-Konfiguration (nur Bluetooth)
  - MQTT-Konfiguration (nur WiFi)

#### OpenDTU (WiFi/Network)
- **Solar-Gateway**: Open-Source-DTU für Hoymiles-Mikrowechselrichter mit Multi-Wechselrichter-Verwaltung
- **Verbindungstypen**: WiFi/Network (WebSocket `ws://{ip}:{port}/livedata` für Echtzeitdaten, HTTP REST API für Konfiguration)
- **Authentifizierung**: Basic Auth (admin)
- **Überwachung**: Echtzeit-Multi-Wechselrichter-aggregierte Daten (Gesamtleistung, Tages-/Gesamtertrag), pro Wechselrichter AC-Leistung (Spannung, Frequenz, Leistung), pro Wechselrichter DC-String-Daten (Spannung, Strom, Leistung), Wechselrichtertemperatur, Systeminformationen (Betriebszeit, CPU-Temperatur, Speichernutzung: Heap/Sketch/LittleFS), persistente Wechselrichterzuordnung mit inkrementellen Updates
- **Konfiguration**:
  - Leistungsgrenze pro Wechselrichter (prozentbasiert)
  - Authentifizierungseinstellungen
  - WiFi-Einrichtung
  - Online-Überwachung Cloud-Relay-Konfiguration ([solar-monitoring](https://github.com/tost11/solar-monitoring))
  - Geräteneustart
  - Wechselrichter Ein/Aus-Umschaltung (pro Gerät)
  - Wechselrichter-Neustart (pro Gerät)

#### Hoymiles (WiFi/Network)
- **Gerätetypen**:
  - **DTU-Gateways** (DTU-WLite, DTU-Pro, DTU-Lite-S): Verwalten mehrerer Wechselrichter mit aggregierter Überwachung und erweiterbarer Wechselrichterlisten-UI
  - **HMS-Wechselrichter** (HMS-800W-2T, HMS-1600W-4T usw.): Eigenständige Mikrowechselrichter mit integriertem WiFi
- **Verbindungstypen**: WiFi/Network (Binäres TCP-Protokoll mit Protobuf-Serialisierung + CRC16-Validierung auf Port 10081)
- **Überwachung**: Echtzeit-Stromerzeugung, bis zu 4 PV-Strings pro Wechselrichter (Spannung, Strom, Leistung pro String, Tages-/Gesamtertrag), AC-Überwachung (Einphasen- oder Dreiphasen-Spannung, Frequenz, Wirkleistung) und Temperaturverfolgung
- **Konfiguration**:
  - Leistungsgrenze (prozentbasiert pro Wechselrichter)
  - WiFi-Einrichtung
  - Access-Point-Konfiguration
  - Geräte- und Netzwerkeinstellungen
- **Hinweis**: DTU-Sticks sind aufgrund der Geräteverschlüsselung nicht implementiert/funktionsfähig

#### Kostal (WiFi/Network)
- **Plenticore-Wechselrichter**: Solarwechselrichter mit umfassender 3-Phasen-Überwachung und Batterieverwaltung
- **Verbindungstypen**: WiFi/Network (Modbus TCP auf konfigurierbarem Port, Standard 1502; HTTP für Geräteerkennung)
- **Geräterollen**: Feste Rollen (Wechselrichter, Batterie, smartMeter) für Systemintegration
- **Überwachung**:
  - **DC**: 3 String-Eingänge (Spannung, Strom, Leistung pro String)
  - **AC**: 3-Phasen-Überwachung (Spannung, Strom, Wirkleistung pro Phase; Blind-/Scheinleistung im Expertenmodus)
  - **Batterie**: SOC, Spannung, Strom, Lade-/Entladeleistung, Temperatur, Zyklen, Brutto-/Nettokapazität
  - **Smart Meter**: Externer Stromzähler mit Spannung, Strom, Leistung, Frequenz, Leistungsfaktor pro Phase
  - **Hausverbrauch**: Gesamtverbrauch mit Aufschlüsselung (von PV, Netz, Batterie)
  - **Erträge**: Tages-, Monats-, Jahres- und Gesamtenergieproduktion
  - **Systeminformationen**: Modell-/Artikelnummer, max. Leistung, Generationsleistung, Betriebszeit, Isolationswiderstand
- **Optimierung**: Batch-Register-Lesevorgänge für schnelles Datenabrufen

### Verbindungstypen

- **Bluetooth Low Energy (BLE)**: Direkte Geräteverbindung mit benutzerdefinierten GATT-Protokollen
- **WiFi/Network**: HTTP-basierte Kommunikation (REST API, JSON-RPC, Legacy-HTTPD)
- **WebSocket**: Echtzeit-bidirektionale Kommunikation (OpenDTU)
- **Modbus TCP**: Erweiterte Protokollunterstützung für DeyeSun- und Kostal-Geräte
- **Protobuf über TCP**: Binärprotokoll für Hoymiles-Geräte (Port 10081)

## Systemansicht

Kombinieren Sie mehrere Geräte zu logischen Solarsystemen für eine einheitliche Überwachung. Weisen Sie Geräten Rollen zu (Wechselrichter, Batterie, Smart Meter, Last) und zeigen Sie aggregierte Metriken an:
- Gesamte Solarproduktion aller Wechselrichter
- Batterie-Lade-/Entladeleistung und durchschnittlicher SOC
- Netzbezug/-einspeisung von Smart Metern
- Gesamtverbrauch von Lastgeräten

Zugriff über das Systemmenü. Jedes System verbindet automatisch alle zugewiesenen Geräte (WiFi + Bluetooth).

## Shelly Script-Automatisierung

Stellen Sie JavaScript-Automatisierungsvorlagen direkt auf Shelly-Geräten für erweiterte Steuerung ohne Cloud-Abhängigkeit bereit. Skripte laufen autonom auf dem Gerät.

**Verfügbare Vorlagen:**
- **Zendure Power Control**: Nulleinspeisungs-Automatisierung, die Zendure-Powerstationen automatisch basierend auf Shelly EM3-Netzmessungen ausgleicht (bidirektional: Entladung ins Haus, Ladung aus Überschuss)
- **OpenDTU Power Control**: Nulleinspeisungs-Automatisierung, die OpenDTU-Wechselrichter Leistungsgrenzen basierend auf Shelly EM3-Netzmessungen anpasst
- **Zendure Online Monitoring**: Automatisierte Datenübertragung an Online-Monitoring-Plattformen für Zendure-Powerstationen
  - Kompatibel mit dem [Solar Monitoring](https://github.com/tost11/solar-monitoring) Projekt (Live: [solar.pihost.org](https://solar.pihost.org) / [solar.tost-soft.de](https://solar.tost-soft.de))

**Verwendung:** Shelly-Gerät öffnen → Menü → "Scripts" → "From Template"

Für eine detaillierte Dokumentation zur Erstellung und Konfiguration von Skripten siehe [SHELLY_SCRIPT_AUTOMATION.md](doc/SHELLY_SCRIPT_AUTOMATION.md).

## Roadmap

### Abgeschlossen ✅

- **Systemansicht**: Kombinieren mehrerer Geräte mit rollenbasierter Aggregation
- **Shelly Script-Automatisierung**: Vorlagenbasierte JavaScript-Automatisierung
- **Nulleinspeisungs-Steuerung**: Automatischer Leistungsausgleich mit Zendure + Shelly EM3

### Demnächst 🚀

- **Zusätzliche Skriptvorlagen**: Weitere Automatisierungsszenarien
- **Lokales Backup & Wiederherstellung**: Systemkonfigurationen lokal speichern/wiederherstellen
- **Zusätzliche Gerätemarken**: Erweiterte Unterstützung für mehr Hersteller

## Erste Schritte

### Voraussetzungen

- Flutter SDK (Version 3.5.4 oder höher)
- Dart SDK (^3.5.4)
- Android SDK (für Android-Builds)
- Physisches Gerät oder Emulator mit Bluetooth- und WiFi-Unterstützung

### Installation

1. **Repository klonen**
   ```bash
   git clone https://github.com/tost11/the-solar-app.git
   cd thesolarapp
   ```

2. **Abhängigkeiten installieren**
   ```bash
   flutter pub get
   ```

3. **Flutter-Setup überprüfen**
   ```bash
   flutter doctor
   ```

4. **Build-Plattformen vorbereiten**
   ```bash
   flutter create --platforms=android .
   #flutter create --platforms=linux .
   #flutter create --platforms=windows .
   ```
   Stellen Sie sicher, dass alle erforderlichen Komponenten installiert sind.

### App ausführen

#### Android-Gerät
```bash
# Verbinden Sie Ihr Android-Gerät über USB mit aktiviertem USB-Debugging
flutter run
```

#### Android-Emulator
```bash
# Starten Sie zuerst einen Android-Emulator, dann:
flutter run
```

#### Linux-Desktop (Entwicklung)
```bash
flutter run -d linux
```

#### Windows-Desktop (Entwicklung)
```bash
flutter run -d windows
```

### Release-APK erstellen

```bash
# Release-APK für Android erstellen
flutter build apk --release

# Die APK befindet sich unter:
# build/app/outputs/flutter-apk/app-release.apk
```

### Build mit Git-Versionsinformationen

Die App zeigt Versionsinformationen einschließlich des Git-Commit-Hashes im Einstellungsdrawer an. Um die Git-Version zur Build-Zeit einzubetten, verwenden Sie die `--dart-define`-Flags:

#### Entwicklungs-Builds

```bash
# Android
flutter run --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)

# Linux
flutter run -d linux --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)

# Windows
flutter run -d windows --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)
```

#### Produktions-Builds

```bash
# Android Release-APK
flutter build apk --release --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)

# Linux-Release
flutter build linux --release --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)

# Windows-Release
flutter build windows --release --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)
```

**Hinweis**: Ohne diese Flags zeigt die App "dev" oder "unknown" als Git-Version an. Die Versionsinformationen werden angezeigt in:
- Einstellungsdrawer: "Version: v1.0.0 (git-hash)"
- App-Info-Bildschirm: Vollständiger Commit-Hash mit Zwischenablage-Funktion

### Berechtigungen

Die App benötigt mehrere Berechtigungen für Geräteerkennung und -verbindung:

- **Bluetooth**: BLE-Scanning und Geräteverbindung
- **Standort**: Von Android für WiFi/BLE-Scanning benötigt
- **WiFi**: Netzwerk-Scanning und Konfiguration
- **Netzwerk**: LAN-Scanning und mDNS-Service-Erkennung

Berechtigungen werden zur Laufzeit bei Bedarf angefordert.

## Verwendung

### Erster Start

1. **Berechtigungen erteilen**: Die App fordert beim ersten Start die erforderlichen Berechtigungen an
2. **Nach Geräten scannen**: Tippen Sie auf die Scan-Schaltfläche, um Geräte in der Nähe zu entdecken
3. **Verbinden**: Wählen Sie ein Gerät aus den Scan-Ergebnissen aus
4. **Konfigurieren**: Richten Sie WiFi, Authentifizierung oder andere Geräteeinstellungen ein
5. **Überwachen**: Zeigen Sie Echtzeitdaten auf dem Gerätedetailbildschirm an

### Geräteverwaltung

- **Gerät hinzufügen**: Verwenden Sie den Scan-Bildschirm, um Bluetooth- oder Netzwerkgeräte zu entdecken
- **Geräteeinstellungen**: Tippen Sie auf das Einstellungssymbol in der Gerätedetailansicht
- **Authentifizierung**: Konfigurieren Sie Benutzername/Passwort für Geräte, die eine Authentifizierung erfordern
- **WiFi-Konfiguration**: Richten Sie die Netzwerkverbindung des Geräts ein
- **Leistungsgrenzen**: Konfigurieren Sie Ausgangsleistungsgrenzen
- **Gerät entfernen**: Langes Drücken auf Gerät in der Liste und Löschen auswählen

### Systemverwaltung

- **System erstellen**: Tippen Sie auf "Systeme" → "Hinzufügen", um ein neues System zu erstellen
- **Geräte zum System hinzufügen**: Wählen Sie Geräte aus und weisen Sie Rollen zu (Wechselrichter, Batterie, Zähler, Last)
- **Systemmetriken anzeigen**: Der Systemdetailbildschirm zeigt aggregierte Daten aller Geräte

### Shelly Script-Automatisierung

- **Vorlagen durchsuchen**: Shelly-Gerät öffnen → Menü → "Scripts" → "From Template"
- **Konfigurieren & Bereitstellen**: Parameter ausfüllen (automatisch ausgefüllt, wenn möglich), Vorschau oder direkt installieren
- **Skripte verwalten**: Parameter aktualisieren, auf neuere Versionen upgraden, aktivieren/deaktivieren oder löschen

### Netzwerk-Erkennung

Die App scannt automatisch nach Geräten mit:
- **Bluetooth**: Scannt nach gerätespezifischen Service-UUIDs
- **LAN-Scanning**: Überprüft lokale Subnetz-IP-Bereiche auf kompatible Geräte

## Mitwirken

Beiträge sind willkommen! Bitte befolgen Sie diese Richtlinien:

1. Repository forken
2. Feature-Branch erstellen (`git checkout -b feature/amazing-feature`)
3. Bestehende Code-Muster und Architektur befolgen
4. Gründlich auf echten Geräten testen
5. Änderungen committen (`git commit -m 'Add amazing feature'`)
6. Zum Branch pushen (`git push origin feature/amazing-feature`)
7. Pull Request öffnen

## Lizenz

Dieses Projekt ist Open Source. Lizenzdetails werden noch hinzugefügt.

## Danksagungen

- Erstellt mit [Flutter](https://flutter.dev/)
- Bluetooth-Unterstützung über [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus)
- Geräteprotokoll-Dokumentation:
  - [Zendure SDK](https://github.com/Zendure/zenSDK)
  - [Shelly Api/Protocol](https://shelly-api-docs.shelly.cloud/gen2/)
  - [Shelly Bluetooth Gat Protocol](https://www.shelly.com/de/blogs/documentation/kbsa-communicating-with-shelly-devices-via-bluetoo)
- Andere Projekte, die als Referenz verwendet wurden
  - [Shelly Bluetooth Protocol](https://github.com/epicRE/shelly-smart-device/blob/main/README.md)
  - [Zendure BLE Protocol](https://github.com/epicRE/zendure_ble)
  - [Shelly API Documentation](https://shelly-api-docs.shelly.cloud/)
  - [Hoymiles Protocol](https://github.com/suaveolent/hoymiles-wifi)
  - [Hoymiles Protocol](https://github.com/ohAnd/dtuGateway)
  - [Deye Sun Protocol](https://github.com/kbialek/deye-inverter-mqtt)
  - [Deye Sun and Hoymiles Protocol](https://github.com/tost11/OpenDTU-Push-Rest-API-and-Deye-Sun)

## Unterstützung

Für Probleme, Fragen oder Feature-Anfragen öffnen Sie bitte ein Issue auf GitHub.

---

**Erstellt mit ☀️ für eine nachhaltige Energiezukunft**

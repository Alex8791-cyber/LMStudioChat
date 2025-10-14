# LMStudioChat – Fernzugriff

**Native iOS-Chat-App (SwiftUI)** für lokale LLM-Konversation über **LM Studio (OpenAI-kompatibel)** – **auch von unterwegs**.

## Autor
**Alexander Söllner**

## Funktionen
- Chat-Interface wie ChatGPT
- Streamend: Token-by-Token Antworten (SSE)
- Lokale Conversation-History (persistent)
- Einstellungen: Server-URL, Modell-ID, API-Key, Temperatur, Top-p, Max-Tokens, System-Prompt
- **Fernzugriff** auf dein Heim-LLM via DynDNS/Port Forwarding oder Cloudflare Tunnel/Tailscale

---

## Voraussetzungen

### Heimserver (PC/Mac mit LM Studio)
- **LM Studio** installiert, Modell `qwen/qwen3-32b` geladen
- **OpenAI-kompatible API** gestartet (Host `0.0.0.0`, Port `1234`)
- **Router-Konfiguration:**
  - **Port Forwarding** (Port 1234 TCP auf die lokale IP des Servers)
  - **DynDNS** (z. B. No-IP, DuckDNS) ODER feste öffentliche IP
- **Firewall** auf Server: Port 1234 eingehend freigeben
- **Alternative (sicherer):** Cloudflare Tunnel oder Tailscale VPN (siehe unten)

### Mac (für Build)
- macOS Monterey+
- Xcode 15+
- Homebrew installiert
- Command Line Tools: `xcode-select --install`

### iPhone
- iOS 16.4+ (getestet auf iOS 18.6.2)
- Mobilfunk oder beliebiges WLAN (kein LAN erforderlich)

---

## Netzwerk-Setup (3 Optionen)

### Option 1: Port Forwarding + DynDNS (einfach, aber unsicher ohne HTTPS)

1. **Router-Admin-Panel öffnen** (z. B. `192.168.1.1`)
2. **Port Forwarding** einrichten:
   - Externer Port: `1234` (TCP)
   - Interner Port: `1234`
   - Ziel-IP: Lokale IP deines Servers (z. B. `192.168.1.50`)
3. **DynDNS einrichten:**
   - Registriere Hostname bei [No-IP](https://www.noip.com) oder [DuckDNS](https://www.duckdns.org)
   - Beispiel: `dein-heim-server.ddns.net`
   - Richte DynDNS-Client auf deinem Router oder Server ein (automatisches IP-Update)
4. **Server-URL in App:** `http://dein-heim-server.ddns.net:1234/v1/chat/completions`

**Sicherheitshinweis:** HTTP ohne TLS ist unsicher über das Internet! Siehe Option 3 für HTTPS.

---

### Option 2: Cloudflare Tunnel (sicher, kostenlos, kein Port Forwarding)

1. **Cloudflare-Account** erstellen (kostenlos)
2. **Cloudflared** auf deinem Server installieren:
   ```bash
   # macOS (Homebrew)
   brew install cloudflare/cloudflare/cloudflared

   # Windows: Download von https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/
   ```
3. **Tunnel erstellen:**
   ```bash
   cloudflared tunnel login
   cloudflared tunnel create lm-studio-tunnel
   cloudflared tunnel route dns lm-studio-tunnel dein-subdomain.deinedomain.com
   ```
4. **Config-Datei erstellen** (`~/.cloudflared/config.yml`):
   ```yaml
   tunnel: <TUNNEL-ID>
   credentials-file: /Users/deinname/.cloudflared/<TUNNEL-ID>.json

   ingress:
     - hostname: dein-subdomain.deinedomain.com
       service: http://localhost:1234
     - service: http_status:404
   ```
5. **Tunnel starten:**
   ```bash
   cloudflared tunnel run lm-studio-tunnel
   ```
6. **Server-URL in App:** `https://dein-subdomain.deinedomain.com/v1/chat/completions` (HTTPS automatisch!)

**Vorteile:** Kein Port Forwarding, kostenlos, automatisches HTTPS via Cloudflare.

---

### Option 3: Tailscale VPN (einfach, sicher, kein Port Forwarding)

1. **Tailscale** auf Server UND iPhone installieren:
   - Server: [https://tailscale.com/download](https://tailscale.com/download)
   - iPhone: App Store → "Tailscale"
2. **Auf beiden Geräten anmelden** (gleicher Tailscale-Account)
3. **Server-Tailscale-IP notieren** (z. B. `100.x.y.z`)
4. **Server-URL in App:** `http://100.x.y.z:1234/v1/chat/completions`

**Vorteile:** Privates VPN, verschlüsselt, kein Port Forwarding, einfachste Lösung.

---

## Installation & Build (iOS-App)

### 1. LM Studio auf Heimserver konfigurieren

1. **Modell laden:** `qwen/qwen3-32b`
2. **OpenAI-Server starten:**
   - Host: `0.0.0.0` (WICHTIG: nicht `127.0.0.1`)
   - Port: `1234`
   - API-Key: `lm-studio` (optional)
3. **Server läuft:** Klicke "Start Server"
4. **Firewall freigeben:** Port 1234 TCP eingehend

### 2. Projekt auf Mac einrichten

Das Projekt befindet sich in `C:\Users\ArtiCall\Desktop\MESSENGER\LMStudioChat`. Kopiere diesen Ordner auf deinen Mac (z. B. via USB-Stick, Cloud-Sync oder Git).

### 3. Bootstrap-Script ausführen

```bash
cd ~/Desktop/LMStudioChat  # oder dein Zielpfad
chmod +x Scripts/bootstrap.sh
./Scripts/bootstrap.sh
```

Das Script:
- Prüft Homebrew
- Installiert XcodeGen (falls nötig)
- Generiert `LMStudioChat.xcodeproj`
- Öffnet Xcode

### 4. Xcode Signing konfigurieren

1. Öffne `LMStudioChat.xcodeproj` in Xcode
2. Target → Signing & Capabilities → Team auswählen
3. Bundle ID: `com.deinname.lmstudiochat`

### 5. iPhone verbinden & Run

1. iPhone per USB anschließen
2. Xcode: Gerät als Run-Ziel wählen
3. Run (⌘R)
4. Auf iPhone: Trust-Zertifikat (Einstellungen → Allgemein → VPN & Geräteverwaltung)

### 6. App-Einstellungen ausfüllen

1. Zahnrad-Symbol tippen
2. **Server-URL:**
   - **Port Forwarding:** `http://dein-dyndns.ddns.net:1234/v1/chat/completions`
   - **Cloudflare Tunnel:** `https://dein-subdomain.deinedomain.com/v1/chat/completions`
   - **Tailscale VPN:** `http://100.x.y.z:1234/v1/chat/completions`
3. **Modell-ID:** `qwen/qwen3-32b`
4. **API-Key:** `lm-studio` (oder leer)
5. **Fertig** tippen

### 7. Test (auch unterwegs)

1. iPhone: WLAN ausschalten, nur Mobilfunk
2. Nachricht senden → Antwort erscheint token-weise

---

## Test: curl von außen (vor App-Build)

```bash
# Von einem anderen PC/Mac (nicht im Heim-LAN)
curl -X POST http://dein-dyndns.ddns.net:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer lm-studio" \
  -d '{
    "model": "qwen/qwen3-32b",
    "messages": [
      {"role": "user", "content": "Hallo!"}
    ],
    "stream": false
  }'
```

**Erwartete Ausgabe:** JSON mit `choices[0].message.content`.

---

## Troubleshooting

| Problem | Ursache | Lösung |
|---------|---------|--------|
| Keine Verbindung von außen | Port Forwarding fehlt | Router: Port 1234 TCP auf Server-IP weiterleiten |
| DynDNS funktioniert nicht | IP nicht aktualisiert | DynDNS-Client prüfen; manuelle IP-Update |
| Timeout | Server offline; Firewall blockiert | LM Studio Server starten; Firewall Port 1234 freigeben |
| HTTP 403/401 | API-Key falsch | Key in App = `lm-studio` (oder leer); Pfad: `/v1/chat/completions` |
| Cloudflare Tunnel down | `cloudflared` nicht gestartet | `cloudflared tunnel run lm-studio-tunnel` |
| Tailscale VPN keine Verbindung | Geräte nicht im gleichen Tailnet | Beide Geräte mit gleichem Account anmelden |
| ATS blockiert HTTP | HTTPS fehlt | Nutze Cloudflare Tunnel (HTTPS automatisch) ODER `NSAllowsArbitraryLoads = YES` (bereits in Info.plist gesetzt, nur Debug) |

---

## Sicherheit

### ⚠️ WICHTIG
- **HTTP ohne TLS** (Option 1) ist unsicher über das Internet → Daten unverschlüsselt!
- **Empfohlen:** Cloudflare Tunnel (HTTPS) oder Tailscale VPN (verschlüsselt)
- **API-Key:** Setze einen starken Key in LM Studio; speichere ihn in der App (wird in UserDefaults gespeichert → für Produktion: Keychain nutzen)
- **Rate Limiting:** LM Studio bietet kein natives Rate Limiting → Verwende Reverse-Proxy (z. B. Nginx) mit `limit_req_zone`
- **Keine sensiblen Daten:** Verwende das LLM nicht für vertrauliche Informationen ohne zusätzliche Verschlüsselung

### HTTPS mit Reverse-Proxy (fortgeschritten)

1. **Nginx auf Server installieren**
2. **Let's Encrypt-Zertifikat** für deine Domain:
   ```bash
   sudo certbot --nginx -d dein-dyndns.ddns.net
   ```
3. **Nginx-Config** (`/etc/nginx/sites-available/lm-studio`):
   ```nginx
   server {
       listen 443 ssl;
       server_name dein-dyndns.ddns.net;

       ssl_certificate /etc/letsencrypt/live/dein-dyndns.ddns.net/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/dein-dyndns.ddns.net/privkey.pem;

       location /v1/chat/completions {
           proxy_pass http://127.0.0.1:1234;
           proxy_http_version 1.1;
           proxy_set_header Connection "";
           proxy_buffering off;
       }
   }
   ```
4. **Port Forwarding:** Port 443 statt 1234
5. **Server-URL in App:** `https://dein-dyndns.ddns.net/v1/chat/completions`

---

## Lizenz & Kontakt

**Autor:** Alexander Söllner
**Projekt:** Private / Nicht-kommerziell
**Rückfragen:** GitHub Issues

---

## Checkliste

- [ ] LM Studio Server läuft (Host `0.0.0.0`, Port 1234)
- [ ] Modell `qwen/qwen3-32b` geladen
- [ ] Port Forwarding (Router: 1234 → Server-IP) ODER Cloudflare Tunnel ODER Tailscale VPN
- [ ] DynDNS eingerichtet (falls Port Forwarding)
- [ ] Firewall Port 1234 freigegeben
- [ ] curl-Test von außen erfolgreich
- [ ] Projekt auf Mac kopiert
- [ ] `bootstrap.sh` ausgeführt, Xcode-Projekt generiert
- [ ] Xcode Signing konfiguriert
- [ ] App auf iPhone installiert
- [ ] Server-URL in App korrekt (DynDNS/Cloudflare/Tailscale)
- [ ] Test von unterwegs (Mobilfunk) erfolgreich

**Viel Erfolg!**

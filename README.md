# Strava_DreamTeam_Edition
📁 Struktura projektu

Projekt został podzielony na trzy niezależne części, z których każda pełni inną funkcję i może być rozwijana oraz uruchamiana osobno.

root/
├── api/          # Backend / REST API
├── mobile/       # Aplikacja mobilna
└── admin-panel/  # Panel administracyjny (Web)

🔹 API

Katalog api/ zawiera backendową część projektu odpowiedzialną za logikę biznesową, komunikację z bazą danych oraz udostępnianie endpointów REST.

🔹 Mobile

Folder mobile/ to aplikacja mobilna korzystająca z API. Może być rozwijana niezależnie od pozostałych modułów.

🔹 Admin Panel

W admin-panel/ znajduje się panel zarządzania projektem – osobna aplikacja webowa umożliwiająca obsługę oraz konfigurację systemu.

Każdy moduł jest traktowany jako osobna aplikacja – posiada swoją strukturę, zależności, proces uruchamiania oraz środowisko.
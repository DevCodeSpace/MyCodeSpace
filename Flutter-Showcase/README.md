# 📱 Flutter Showcase

> A curated collection of production-style Flutter applications spanning connectivity, productivity, security, and utility domains — each built to demonstrate clean architecture, native platform integrations, and real-world problem solving.

---

## 📖 Project Overview

This portfolio demonstrates expertise in building polished, functional Flutter applications with a focus on: </br>
✨ **Native Platform Integration** — Camera, Bluetooth, geofencing, background services & system overlays </br>
✨ **Clean Architecture** — GetX / Provider state management with clear separation of concerns </br>
✨ **Offline-First & Peer-to-Peer** — Local networking, Bluetooth transfer, and on-device ML with no server dependency where possible </br>
✨ **Cross-Platform Reach** — Android, iOS, Web, and Desktop targets across the collection </br>
✨ **Real-World Utility** — Each app solves a genuine day-to-day problem, from document scanning to digital wellbeing </br>

Every project below has its own detailed README — click through for setup instructions, architecture notes, and full feature breakdowns.

---

## 🪪 [Aadhaar Data Extractor](Aadhar_Data_Extractor)

Scans an Aadhaar card's secure QR code via camera or gallery image and extracts the holder's details into a clean, verifiable summary card — no manual typing required.

<img src="Aadhar_Data_Extractor/assets/aadhar-logo.png" alt="Aadhaar Data Extractor" height="120" />

**Highlights:** QR/barcode scanning (ML Kit) · secure QR XML parsing · scan history · export & share

---

## 🔐 [Authenticator](Authenticator_App)

A two-factor authentication (2FA) app that generates live TOTP codes, similar to Google Authenticator — add accounts by scanning a QR code and get auto-refreshing 6-digit codes.

**Highlights:** RFC 6238 TOTP generation · QR enrollment · countdown timer · fully offline, on-device storage

---

## 💬 [Bluetooth Chat](Bluetooth_Chat_App)

Lets two nearby devices message each other — text, images, and video — entirely over Bluetooth, with zero WiFi or internet dependency.

**Highlights:** BLE + Classic Bluetooth · chunked file transfer with live progress · delivery status ticks · GetX MVC

---

## 📍 [GeoSentry](Geosentry)

A geofencing app for drawing virtual zones on a map and getting notified the moment a zone boundary is crossed.

**Highlights:** Interactive Google Maps zones · background location monitoring · local push notifications · event history log

---

## 🌐 [Pure WebRTC Video Calling](Meetup_Web)

A complete 1-to-1 video calling system built on pure WebRTC with Firestore-based signaling — no third-party video SDK required.

**Highlights:** Room creation & join-by-ID · mute/camera toggle & camera switch · Android, iOS & Web support

---

## 📤 [ShareSphere — P2P File Transfer](P2P_Share_App)

Transfers files directly between devices over the local WiFi network via an embedded HTTP server — no cables, no cloud upload.

**Highlights:** QR-code device pairing · local `shelf` HTTP server · live transfer progress · send/receive/history flow

---

## 🖥️ [ScreenCast Pro](Screencast_Pro)

Streams an Android phone's screen live to a Mac, Windows PC, or another Android device over WiFi using a custom UDP discovery protocol and WebSocket streaming — no cables or third-party services.

**Highlights:** System-wide `MediaProjection` capture · browser casting (MJPEG) · UDP auto-discovery · dynamic port allocation

---

## 🔒 [SecureAuth Vault](Secureauth_Vault)

An all-in-one security vault for credentials, documents, and 2FA codes — protected by biometric/PIN lock and AES-256 encryption, with optional encrypted Google Drive backup.

<img src="Secureauth_Vault/assets/logo/logo.png" alt="SecureAuth Vault" height="120" />

**Highlights:** Password & document vault · built-in TOTP authenticator · biometric + PIN lock · AES-256 encryption at rest · encrypted Drive backup

---

## 🧑‍💼 [Smart Attend — Face Attendance System](Smart_Attend)

An employee attendance app powered by face liveness detection — enroll via face scan, then check in/out with the same liveness flow, no manual entry.

**Highlights:** Face enrollment & liveness verification · live present/absent/late dashboard · attendance history log

---

## ⏳ [Stay On Track — Digital Wellbeing](Stay_On_Track)

Tracks time spent in each installed app, visualizes usage trends, and enforces daily limits with a system-level overlay nudge.

<img src="Stay_On_Track/assets/logo.png" alt="Stay On Track" height="120" />

**Highlights:** Per-app usage charts · daily time limits · background tracking · limit-reached overlay alert

---

## 🗳️ [Team Awards Voting System](Voting_System)

A Firebase-backed peer-recognition app where team members vote for colleagues across fun award categories, with one submission per person and live results.

<img src="Voting_System/assets/voting_img.png" alt="Team Awards Voting" height="180" />

**Highlights:** Firebase Auth login/register · multi-category voting flow · one-vote-per-user enforcement · live results screen

---

## 🖱️ [WiFi Mouse Pro](Wifi_Mouse_Connet_Via_Phone)

Transforms your smartphone into a low-latency remote input device — cursor, keyboard, scrolling, and media controls over WiFi.

**Highlights:** High-precision virtual trackpad · gyroscope motion control · remote keyboard · Node.js desktop server

---

## 🛠️ Tech Stack Across the Collection

| Category           | Technologies                                                                 |
| ------------------- | ----------------------------------------------------------------------------- |
| State Management    | GetX, Provider                                                                  |
| Connectivity        | Bluetooth (Classic & BLE), WebRTC, WebSockets, UDP, local HTTP servers          |
| On-Device ML        | Google ML Kit (barcode, text recognition), face liveness detection              |
| Location & Maps     | Google Maps, Geolocator, geofencing, background services                        |
| Backend             | Firebase (Auth, Firestore), Node.js                                              |
| Storage             | SharedPreferences, local file system                                              |

---

*Built with ❤️ by DevCodeSpace using Flutter • Showcasing native integrations, offline-first design, and real-world problem solving in mobile development*

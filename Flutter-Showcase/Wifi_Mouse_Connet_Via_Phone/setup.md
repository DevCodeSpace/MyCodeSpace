# Setup Guide

Follow the steps below to set up the WiFi Mouse Pro desktop server and connect it with your mobile application.

---

## Step 1: Install Node.js

Ensure that Node.js is installed on your system.

You can download it from: https://nodejs.org

---

## Step 2: Install Dependencies

Navigate to the server directory and install required packages:

```bash
npm install
```

---

## Step 3: Start Server

Run the following command to start the server:

```bash
node server.js
```

Expected output:

```
Server running on http://192.168.x.x:3000
```

---

## Step 4: Connect Mobile App

1. Launch WiFi Mouse Pro on your mobile device
2. The app will automatically detect available desktops on the network
3. Tap on the desktop you wish to connect to

---

## Notes

- Ensure both devices are connected to the same Wi-Fi network
- Allow firewall permissions if prompted
- Keep the server running while using the app

---

## Stopping the Server

Press:

```bash
Ctrl + C
```

in the terminal to stop the server

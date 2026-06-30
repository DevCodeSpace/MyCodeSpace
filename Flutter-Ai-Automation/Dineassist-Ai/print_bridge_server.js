/**
 * Print Bridge Server (Node.js)
 * ------------------------------
 * Flutter Web se HTTP POST receive karke ESC/POS printer ko TCP pe forward karta hai.
 *
 * Run karo:  node print_bridge_server.js
 * Port:      8080
 */

const http = require("http");
const net = require("net");
const url = require("url");

const PRINTER_PORT = 9100;
const SERVER_PORT = 8080;

const server = http.createServer((req, res) => {
  // CORS headers — har response pe
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.writeHead(200);
    res.end();
    return;
  }

  if (req.method !== "POST") {
    res.writeHead(405);
    res.end(JSON.stringify({ status: "error", message: "Only POST allowed" }));
    return;
  }

  const query = url.parse(req.url, true).query;

  const chunks = [];
  req.on("data", (chunk) => chunks.push(chunk));
  req.on("end", () => {
    let rawBytes;
    let printerIp = query.ip || "192.168.1.223";
    try {
      // Flutter Web base64 JSON bhejta hai
      const body = JSON.parse(Buffer.concat(chunks).toString());
      rawBytes = Buffer.from(body.bytes, "base64");
      if (body.ip) printerIp = body.ip;
    } catch (_) {
      // Fallback: raw binary (native client)
      rawBytes = Buffer.concat(chunks);
    }
    console.log(`[PRINT] ${rawBytes.length} bytes → ${printerIp}:${PRINTER_PORT}`);

    const socket = new net.Socket();
    socket.setTimeout(10000);

    const respond = (code, body) => {
      res.writeHead(code, { "Content-Type": "application/json" });
      res.end(JSON.stringify(body));
    };

    socket.connect(PRINTER_PORT, printerIp, () => {
      socket.write(rawBytes, () => {
        socket.destroy();
        console.log(`[OK]    Printed successfully`);
        respond(200, { status: "success" });
      });
    });

    socket.on("timeout", () => {
      socket.destroy();
      console.log(`[ERR]   Connection timed out`);
      respond(500, { status: "error", message: "Connection timed out" });
    });

    socket.on("error", (err) => {
      console.log(`[ERR]   ${err.message}`);
      respond(500, { status: "error", message: err.message });
    });
  });
});

server.listen(SERVER_PORT, "0.0.0.0", () => {
  console.log("========================================");
  console.log("  Print Bridge Server  —  Port 8080");
  console.log("  Keep this running while using the web app");
  console.log("========================================");
});

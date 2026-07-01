const WebSocket = require("ws");
const robot = require("robotjs");
const os = require("os");

// Improve smoothness
robot.setMouseDelay(0);

const PORT = 3000;
const sensitivity = 5;
const wss = new WebSocket.Server({ port: PORT });

console.log(`🚀 Trackpad Server running on port ${PORT}`);
let isDragging = false;

wss.on("connection", (ws, req) => {
  const clientIp = req.socket.remoteAddress;
  console.log(`📱 Connected: ${clientIp}`);

  ws.on("message", (message) => {
    try {
      const msg = message.toString();

      if (msg === "who_are_you") {
        const rawName = os.hostname();
        const cleanName = rawName.split(".")[0].replaceAll("-", " ");

        ws.send(
          JSON.stringify({
            type: "trackpad_server",
            name: cleanName,
          }),
        );
        return;
      }

      const data = JSON.parse(msg);
      const mouse = robot.getMousePos();

      switch (data.type) {
        case "move":
          const factor = isDragging ? 2 : 5;
          robot.moveMouse(
            Math.round(mouse.x + data.dx),
            Math.round(mouse.y + data.dy),
          );
          break;

        // 🔥 START DRAG
        case "mouse_down":
          robot.mouseToggle("down", "left");
          isDragging = true;
          break;

        // 🔥 END DRAG
        case "mouse_up":
          robot.mouseToggle("up", "left");
          isDragging = false;
          break;

        case "click":
          robot.mouseClick("left");
          break;

        case "double_click":
          robot.mouseClick("left");
          setTimeout(() => {
            robot.mouseClick("left");
          }, 100); // 👈 small delay
          break;

        case "right_click":
          robot.mouseClick("right");
          break;

        case "scroll":
          robot.scrollMouse(data.dx ?? 0, data.dy ?? 0);
          break;
        // 🔥 KEYBOARD SUPPORT
        // case "key_tap":
        //   robot.keyTap(data.key);
        //   break;
        // case "key_down":
        //   robot.keyToggle(data.key, "down");
        //   break;
        // case "key_up":
        //   robot.keyToggle(data.key, "up");
        //   break;
        case "key_tap":
          let mappedKey = mapSpecialKey(data.key);
          let modifiers = data.modifiers ? [...data.modifiers] : [];

          // 1. RobotJS strictly requires lowercase characters (e.g., 'a' not 'A').
          // If the key is a single uppercase letter, we must convert it and use 'shift'.
          const isLetter = mappedKey.length === 1;
          const isUpperCase =
            isLetter &&
            mappedKey === mappedKey.toUpperCase() &&
            mappedKey !== mappedKey.toLowerCase();

          if (isUpperCase) {
            mappedKey = mappedKey.toLowerCase(); // Convert "A" to "a"

            // Add the "shift" modifier so it actually types an uppercase letter on the host
            if (!modifiers.includes("shift")) {
              modifiers.push("shift");
            }
          }

          // 2. RobotJS does NOT support "capslock" as a modifier. Filter it out.UULHShsussH
          modifiers = modifiers.filter(
            (mod) => mod.toLowerCase() !== "capslock",
          );

          // 3. Map any remaining valid modifiers (ctrl, alt, shift, command)
          const validMods = modifiers.map((m) => mapSpecialKey(m));

          try {
            if (validMods.length > 0) {
              robot.keyTap(mappedKey, validMods);
            } else {
              robot.keyTap(mappedKey);
            }
          } catch (e) {
            console.error(
              `❌ RobotJS Error on keyTap('${mappedKey}', [${validMods}]):`,
              e.message,
            );
          }
          break;

        case "key_down":
          robot.keyToggle(mapSpecialKey(data.key), "down");
          break;

        case "key_up":
          robot.keyToggle(mapSpecialKey(data.key), "up");
          break;

        case "type":
          robot.typeString(data.text);
          break;

        case "key_combo":
          const keys = data.keys;
          const mainKey = keys.pop(); // last key (c)
          robot.keyTap(mainKey, keys); // modifiers: ['control']
          break;

        default:
          console.log("Unknown action:", data);
      }
    } catch (err) {
      console.error("❌ Error:", err.message);
    }
  });

  ws.on("close", () => {
    if (isDragging) {
      robot.mouseToggle("up", "left");
      isDragging = false;
    }
    console.log(`❌ Disconnected: ${clientIp}`);
  });
});

/**
 * Maps incoming labels to robotjs key strings
 * Documentation: http://robotjs.io/docs/syntax#keys
 */
function mapSpecialKey(key) {
  // const k = key.toLowerCase();
  const mapping = {
    ctrl: "control",
    win: "command", // RobotJS uses 'command' for the Windows/Meta key
    meta: "command",
    alt: "alt",
    shift: "shift",
    caps: "capslock",
    esc: "escape",
    "⌫": "backspace",
    backspace: "backspace",
    enter: "enter",
    tab: "tab",
    space: "space",
    up: "up",
    down: "down",
    left: "left",
    right: "right",
    del: "delete",
    f1: "f1",
    f2: "f2",
    f3: "f3",
    f4: "f4",
    f5: "f5",
    f6: "f6",
    f7: "f7",
    f8: "f8",
    f9: "f9",
    f10: "f10",
    f11: "f11",
    f12: "f12",
  };
  return mapping[key] || key;
}

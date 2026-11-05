import { execFile } from "node:child_process";
import { appendFileSync, mkdirSync, realpathSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ON = 0;
const OFF = 1;

const pluginDir = dirname(realpathSync(fileURLToPath(import.meta.url)));
const scriptsDir = dirname(pluginDir);
const logFile = join(pluginDir, "logs", "plugin.log");

const scripts = {
  "com.anthonyterrell.avtoggles.webcam": join(scriptsDir, "toggle-webcam.sh"),
  "com.anthonyterrell.avtoggles.mic": join(scriptsDir, "toggle-mic.sh"),
};

const keys = new Map();
const busy = new Set();

function log(message) {
  mkdirSync(dirname(logFile), { recursive: true });
  appendFileSync(logFile, `${new Date().toISOString()} ${message}\n`);
}

function arg(name) {
  return process.argv[process.argv.indexOf(`-${name}`) + 1];
}

function run(script, args = []) {
  return new Promise((resolve, reject) => {
    const options = { timeout: 20_000, env: { ...process.env, TOGGLE_QUIET: "1" } };
    execFile(script, args, options, (error, stdout, stderr) => {
      if (error) reject(new Error((stderr || error.message).trim()));
      else resolve(stdout.trim());
    });
  });
}

function stateFrom(output) {
  if (/\b(off|muted)\b/i.test(output)) return OFF;
  if (/\bon\b/i.test(output)) return ON;
  throw new Error(`Unexpected script output: ${output}`);
}

const socket = new WebSocket(`ws://127.0.0.1:${arg("port")}`);

function send(event, context, payload) {
  socket.send(JSON.stringify({ event, context, payload }));
}

function setState(action, state) {
  for (const [context, keyAction] of keys) {
    if (keyAction === action) send("setState", context, { state });
  }
}

async function refresh(action) {
  try {
    setState(action, stateFrom(await run(scripts[action], ["--status"])));
  } catch (error) {
    log(`status ${action}: ${error.message}`);
  }
}

async function toggle(action, context) {
  if (busy.has(action)) return;
  busy.add(action);
  try {
    setState(action, stateFrom(await run(scripts[action])));
  } catch (error) {
    log(`toggle ${action}: ${error.message}`);
    send("showAlert", context);
    await refresh(action);
  } finally {
    busy.delete(action);
  }
}

socket.addEventListener("open", () => {
  socket.send(JSON.stringify({ event: arg("registerEvent"), uuid: arg("pluginUUID") }));
  log("registered");
});

socket.addEventListener("message", ({ data }) => {
  const { event, action, context } = JSON.parse(data);

  if (event === "systemDidWakeUp") {
    new Set(keys.values()).forEach(refresh);
    return;
  }
  if (!scripts[action]) return;

  if (event === "willAppear") {
    keys.set(context, action);
    refresh(action);
  } else if (event === "willDisappear") {
    keys.delete(context);
  } else if (event === "keyDown") {
    toggle(action, context);
  }
});

socket.addEventListener("close", () => process.exit(0));

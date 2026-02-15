# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

This helps Jarvis understand your environment, integrations, and tool preferences.

---

## 🧰 Email & Calendar Tools

### Microsoft 365 (M365) — Outlook Email & Calendar

- **Primary email & calendar provider:** Microsoft 365 via **Clippy**
- Clippy is connected to your **Outlook mailbox** and **Outlook calendar** (M365), handling:
  - Reading and summarizing emails
  - Extracting meeting details from calendar
  - Scheduling, rescheduling, and cancelling meetings
  - Creating, updating, and managing calendar events

**Preferred commands:**

```bash
clippy mail inbox --unread --limit 30 --json
clippy calendar today --json
clippy calendar tomorrow --json
clippy calendar week --json
```

**Rules:**

- Treat Clippy as the **canonical source of truth** for inbox + calendar.
- Prefer `--json` output whenever available.
- Never answer calendar questions from memory — run a live command in the same turn.
- If a command fails, report the failure briefly and include the exact command that failed.

---

## 📡 Notification Channel

### Telegram

- **Primary delivery channel** for all alerts, reminders, and notifications.
- Jarvis uses your configured Telegram bot token + chat ID to send messages.

**Send pattern:**

```bash
openclaw message send --channel telegram --target <CHAT_ID> --message "..."
```

---

## 🧠 Model & Task Routing

### Transcription

- **Preferred model:** Whisper (medium) for accurate audio transcriptions (calls, recordings, meetings).

### Web Search

- **Preferred web search tool:** Tavily for external context / open research.
- **Hard rule:** Use only Tavily for web search.
- Do not use Brave or web_fetch.
- **Command:** `tavily-search "<query>"`
- Do not chain commands (`cd`, `&&`, etc.).

### Task Execution

- Calendar & email manipulation must always go through Clippy (M365).
- Validate key claims against live tools in the same turn whenever possible.

---

## 🍽 Restaurant Discovery & Booking

### Discovery

- Primary: `goplaces`
- Fallback: `tavily-search`

### Booking execution

- Use browser automation (e.g., Playwright MCP skill).
- Must use official booking page.
- Do not switch to phone-call/manual instructions unless the user explicitly requests it.

### Candidate ranking

1. Rating (descending)
2. Review count (descending)
3. Distance (ascending, Abu Dhabi bias)

---

## 🧠 Integrations & Data Signals

### WHOOP (Health Data)

- WHOOP readiness / sleep / strain integration
- Used in daily briefs and readiness-based scheduling recommendations
- WHOOP signals inform decisions — they do not auto-modify calendar events

---

## 🗣 TTS & Voice (Optional)

### ElevenLabs (sag)

- Preferred voice: Nova
- Default delivery: Telegram voice note

---

## 🔐 Security Rules

- Never place credentials in markdown.
- Never store plaintext API keys.
- Keep secrets in environment variables or a secure vault.
- Do not exfiltrate private data.
- Do not run destructive system commands without explicit confirmation.

Inbox + calendar are private contexts. Do not leak them in shared chats.

---

## 🛠 Notes & To-Dos

- Store Telegram chat ID securely.
- Define M365 priority filters (senior leadership list, urgency keywords).
- Keep WHOOP readiness threshold documented if used.
- Ensure tokens and OAuth credentials are stored securely.

---

## Why Separate?

Skills are shared. Your setup is yours.

Keeping local notes here allows you to:
- Update skills without losing environment specifics
- Share skills without leaking infrastructure
- Maintain deterministic, consistent tool routing
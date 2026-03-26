---
name: wa
description: >
  Read and send WhatsApp messages via SQLite DB access and a verified send
  script. Use when user says "check WhatsApp", "read WhatsApp", "messages
  from X", "send WhatsApp to X", "message X on WhatsApp", or any WhatsApp
  read/send task.
---

# WhatsApp Skill

## CRITICAL: Sending Rules

**NEVER send without explicit confirmation.** Wrong-number sends leak confidential info.

- Block unverified sends via a PreToolUse hook (see hooks/).
- NEVER construct phone numbers from memory.
- Discussion/brainstorming is NOT a send instruction. Only "send", "go", "send it" counts.

**Only send flow:**
1. Run your verified send script (dry run: resolves JID, shows phone, exits without sending)
2. Show the user the resolved phone number
3. Wait for explicit "yes" / "send" / "go"
4. Run with `--confirmed` flag

## Reading Messages

<!-- Customize: set the path to your WhatsApp SQLite DB -->
<!-- macOS WhatsApp Desktop stores it at: -->
<!-- ~/Library/Group Containers/group.net.whatsapp.WhatsApp.shared/ChatStorage.sqlite -->

### Step 1: Copy the DB

```bash
DB_SOURCE="<PATH_TO_WHATSAPP_CHATSTORE_SQLITE>"
cp "$DB_SOURCE" /tmp/wa-chat.sqlite
```

If the copy fails, the source is unavailable. Do not proceed; tell the user.

### Step 2: Find a contact

```bash
sqlite3 /tmp/wa-chat.sqlite "
SELECT ZCONTACTJID, ZCONTACTIDENTIFIER, ZPARTNERNAME
FROM ZWACHATSESSION
WHERE ZPARTNERNAME LIKE '%Name%';
"
```

### Step 3: Read DM messages

```bash
sqlite3 /tmp/wa-chat.sqlite "
SELECT ZFROMJID, ZTEXT, datetime(ZMESSAGEDATE + 978307200, 'unixepoch') as msg_time
FROM ZWAMESSAGE
WHERE ZFROMJID LIKE '%PHONE_OR_LID%'
ORDER BY ZMESSAGEDATE DESC
LIMIT 20;
"
```

Replace `PHONE_OR_LID` with phone digits or LID from step 2 (no `+`, no spaces).

### Step 4: Read group messages

```bash
sqlite3 /tmp/wa-chat.sqlite "
SELECT ZMEMBERJID, ZTEXT, datetime(ZMESSAGEDATE + 978307200, 'unixepoch') as msg_time
FROM ZWAMESSAGE
WHERE ZCHATSESSION IN (
  SELECT Z_PK FROM ZWACHATSESSION WHERE ZPARTNERNAME LIKE '%GroupName%'
)
ORDER BY ZMESSAGEDATE DESC
LIMIT 20;
"
```

### Step 5: Read full conversation (both sides)

```bash
sqlite3 /tmp/wa-chat.sqlite "
SELECT
  CASE WHEN ZFROMJID IS NULL THEN 'Me' ELSE ZFROMJID END as sender,
  ZTEXT,
  datetime(ZMESSAGEDATE + 978307200, 'unixepoch') as msg_time
FROM ZWAMESSAGE
WHERE ZCHATSESSION IN (
  SELECT Z_PK FROM ZWACHATSESSION WHERE ZCONTACTJID LIKE '%PHONE_OR_LID%'
)
  AND ZTEXT IS NOT NULL
ORDER BY ZMESSAGEDATE DESC
LIMIT 30;
"
```

Outgoing messages have `ZFROMJID = NULL`.

## Common Tasks

### "What did X say lately?"
1. Copy DB
2. Find contact JID
3. Run full conversation query with LIMIT 20
4. Show messages newest-first, formatted as `[time] sender: text`

### "Any new WhatsApp messages?"
1. Copy DB
2. Query all sessions ordered by last message time:

```bash
sqlite3 /tmp/wa-chat.sqlite "
SELECT ZPARTNERNAME, datetime(ZLASTMESSAGEDATE + 978307200, 'unixepoch') as last_msg
FROM ZWACHATSESSION
ORDER BY ZLASTMESSAGEDATE DESC
LIMIT 20;
"
```

### "Send X a message saying Y"
1. Draft the message, show user for review
2. Run verified send script (dry run)
3. Show resolved phone number
4. Wait for explicit send confirmation
5. Run with `--confirmed`

## Troubleshooting

**DB copy fails:** Source is unavailable (mount down, app not running). Tell user.

**ZTEXT is NULL:** Message may be media-only (image, video, audio, sticker).

**Contact not found:** Try partial name, try phone digits, try ZCONTACTIDENTIFIER column.

**Timestamp offset:** `978307200` is Apple Cocoa epoch (Jan 1 2001). This is correct for WhatsApp Desktop on macOS.

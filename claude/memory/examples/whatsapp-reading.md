# WhatsApp Message Reading Template

Direct SQLite access to WhatsApp Desktop messages. Works for any chat: DMs, groups, any contact.

## Why SQLite Instead of WhatsApp Web?

- **Reliable** - No web automation brittleness, no rate limits, no UI lag
- **Universal** - Works for any chat (groups, archived, muted, etc.)
- **Complete** - Full message history, media paths, read receipts, etc.
- **Fast** - Query results in milliseconds

## Database Location

### macOS
```bash
~/Library/Group Containers/group.net.whatsapp.WhatsApp.shared/ChatStorage.sqlite
```

### Windows
```
%AppData%\WhatsApp\Databases\ChatStorage.sqlite
```

### Linux
```
~/.local/share/WhatsApp/ChatStorage.sqlite
```

## Remote Access (via SSHFS)

When accessing from a remote server:

```bash
# Mount WhatsApp database from Mac
sshfs <YOUR_USER>@<YOUR_MAC>:/Library/Group\ Containers/group.net.whatsapp.WhatsApp.shared /mnt/mac

# Copy DB
cp "/mnt/mac/ChatStorage.sqlite" /tmp/wa-chat.sqlite

# Query
sqlite3 /tmp/wa-chat.sqlite "SELECT ..."
```

## Common Queries

### Find All Contacts

```sql
SELECT ZCONTACTJID, ZCONTACTIDENTIFIER, ZPARTNERNAME
FROM ZWACHATSESSION
ORDER BY ZPARTNERNAME ASC;
```

Returns:
- `ZCONTACTJID` - Phone JID or LID (e.g., `919876543210@s.whatsapp.net` or `244813203026085@lid`)
- `ZCONTACTIDENTIFIER` - Phone number (e.g., `+919876543210`)
- `ZPARTNERNAME` - Display name

### Find Contact by Name (Partial Match)

```sql
SELECT ZCONTACTJID, ZCONTACTIDENTIFIER, ZPARTNERNAME
FROM ZWACHATSESSION
WHERE ZPARTNERNAME LIKE '%John%'
LIMIT 10;
```

### Get Recent Messages from a Contact

```sql
SELECT ZFROMJID, ZTEXT, datetime(ZMESSAGEDATE + 978307200, 'unixepoch') as msg_time
FROM ZWAMESSAGE
WHERE ZFROMJID LIKE '%<PHONE_OR_LID>%'
ORDER BY ZMESSAGEDATE DESC
LIMIT 20;
```

Parameters:
- `ZFROMJID` - Who sent the message (their JID)
- `ZTEXT` - Message text
- `ZMESSAGEDATE` - Timestamp (epoch offset from 2001-01-01)
- `978307200` - Seconds between 1970-01-01 and 2001-01-01 (iOS epoch conversion)

### Search Messages by Keyword

```sql
SELECT ZFROMJID, ZTEXT, datetime(ZMESSAGEDATE + 978307200, 'unixepoch') as msg_time
FROM ZWAMESSAGE
WHERE ZTEXT LIKE '%keyword%'
ORDER BY ZMESSAGEDATE DESC
LIMIT 20;
```

### Get All Chats (Summary)

```sql
SELECT ZPARTNERNAME, ZLASTMESSAGE, datetime(ZCONTACTSTATUS + 978307200, 'unixepoch') as last_activity
FROM ZWACHATSESSION
ORDER BY ZLASTMESSAGE DESC;
```

### Get Media Paths from Messages

```sql
SELECT ZFROMJID, ZTEXT, ZMEDIASECTIONCOUNT, ZMEDIAURL
FROM ZWAMESSAGE
WHERE ZFROMJID LIKE '%<PHONE_OR_LID>%' AND ZMEDIAURL IS NOT NULL
ORDER BY ZMESSAGEDATE DESC
LIMIT 20;
```

Media files are typically stored in:
- `~/Library/Group Containers/group.net.whatsapp.WhatsApp.shared/Media/`
- Find by `ZMEDIAURL` field

## Important Notes

### JID Formats

| Format | Example | Use For |
|--------|---------|---------|
| Phone JID | `919876543210@s.whatsapp.net` | Most contacts (SMS-based) |
| LID | `244813203026085@lid` | Newer WhatsApp accounts (no phone sync) |
| Group JID | `120363123456789@g.us` | Group chats |

Phone JIDs don't include `+` prefix. LIDs are numeric identifiers without phone association.

### Timestamp Handling

WhatsApp uses iOS-style epoch (2001-01-01 as origin):
- `ZMESSAGEDATE` is in seconds since 2001-01-01
- Convert to Unix time: `ZMESSAGEDATE + 978307200`
- Then use `datetime(epoch_time, 'unixepoch')` in SQLite

### Read Receipts

Column `ZMESSAGESTATUSFLAGS` indicates:
- `0` = sent, not delivered
- `1` = delivered
- `2` = read
- `3` = played (for media)

### Before Sending (Never Guess JIDs)

Always look up the correct JID before sending messages:

```sql
SELECT ZCONTACTJID, ZCONTACTIDENTIFIER
FROM ZWACHATSESSION
WHERE ZPARTNERNAME LIKE '%ContactName%';
```

NEVER use JIDs from memory or previous sessions. Always query fresh.

## Safety Tips

1. **Copy before querying** - `cp ChatStorage.sqlite /tmp/wa-read.sqlite` (prevents locking)
2. **Read-only mode** - Use `.read-only` flag if available
3. **Verify contact before sending** - Query the DB to confirm phone number
4. **Never modify** - These queries are read-only; database integrity matters
5. **Expire temporary copies** - Delete `/tmp/wa-*.sqlite` when done

## Example Workflow

```bash
# 1. Copy database from Mac
sshfs mac:/Library/Group\ Containers/group.net.whatsapp.WhatsApp.shared /mnt/mac
cp "/mnt/mac/ChatStorage.sqlite" /tmp/wa-chat.sqlite

# 2. Find contact
sqlite3 /tmp/wa-chat.sqlite \
  "SELECT ZCONTACTJID, ZCONTACTIDENTIFIER FROM ZWACHATSESSION WHERE ZPARTNERNAME LIKE '%John%';"

# 3. Get recent messages
sqlite3 /tmp/wa-chat.sqlite \
  "SELECT ZTEXT, datetime(ZMESSAGEDATE + 978307200, 'unixepoch') FROM ZWAMESSAGE \
   WHERE ZFROMJID LIKE '%919876543210@s.whatsapp.net%' ORDER BY ZMESSAGEDATE DESC LIMIT 10;"

# 4. Cleanup
rm /tmp/wa-chat.sqlite
```

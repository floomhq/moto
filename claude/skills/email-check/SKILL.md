---
name: email-check
description: >
  Check, read, and search emails across IMAP accounts. Use when user
  says "check email", "read inbox", "any new emails", "check mail", "email from X",
  "unread messages", or mentions checking specific email accounts.
---

# Email Check Skill

## CRITICAL: Preserve Read/Unread Status

Users often use UNREAD status to track items. **NEVER mark emails as read.**

- Use `BODY.PEEK[]` NOT `RFC822` (RFC822 marks as read)
- If accidentally marked read: `mail.store(num, '-FLAGS', '\\Seen')`

## How to check emails

Use Python with `imaplib`. Always use `BODY.PEEK[]` for fetching.

```python
import imaplib
import email
from email.header import decode_header

def check_inbox(server, email_addr, password, folder="INBOX", unseen_only=True, limit=10):
    mail = imaplib.IMAP4_SSL(server)
    mail.login(email_addr, password)
    mail.select(folder, readonly=True)  # readonly=True as extra safety

    criteria = "UNSEEN" if unseen_only else "ALL"
    status, messages = mail.search(None, criteria)
    msg_ids = messages[0].split()[-limit:] if messages[0] else []

    results = []
    for mid in msg_ids:
        # CRITICAL: BODY.PEEK not RFC822
        status, data = mail.fetch(mid, "(BODY.PEEK[HEADER.FIELDS (FROM SUBJECT DATE)])")
        header = email.message_from_bytes(data[0][1])
        subject = decode_header(header.get("Subject", ""))[0][0]
        if isinstance(subject, bytes):
            subject = subject.decode(errors="replace")
        results.append({
            "from": header.get("From", ""),
            "subject": subject,
            "date": header.get("Date", "")
        })

    mail.logout()
    return results
```

## Common tasks

### Check for unread messages
Loop through configured accounts, report unread count and latest subjects per account.

### Search for email from specific sender
```python
mail.search(None, 'FROM "sender@example.com"')
```

### Search by subject
```python
mail.search(None, 'SUBJECT "keyword"')
```

### Check specific folder
Gmail labels map to IMAP folders: `[Gmail]/Sent Mail`, `[Gmail]/Drafts`, `[Gmail]/Spam`

### Date range search
```python
mail.search(None, 'SINCE "01-Mar-2026" BEFORE "08-Mar-2026"')
```

## Setup

Configure your accounts in environment variables or a config file:
```
IMAP_SERVER=imap.gmail.com
IMAP_EMAIL=you@example.com
IMAP_PASSWORD=your-app-password
```

For Gmail, use App Passwords (not your main password): Google Account > Security > 2-Step Verification > App passwords.

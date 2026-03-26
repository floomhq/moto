---
name: dns
description: >
  DNS management via API. Add, update, delete DNS records for your domains.
  Use when user says "dns", "add dns record", "update dns", "dns for X",
  "add subdomain", "point domain", "create dns record", or "delete dns record".
---

# DNS Management

<!-- Customize: replace with your DNS provider's API. This template uses a generic REST API pattern. -->

## Auth

```bash
# Set your DNS provider API key
DNS_API_KEY="<YOUR_DNS_API_KEY>"
DNS_API_BASE="<YOUR_DNS_API_BASE_URL>"  # e.g., https://api.hosting.ionos.com/dns/v1/zones
```

Header: `X-API-Key: $DNS_API_KEY` (or `Authorization: Bearer $DNS_API_KEY` depending on provider)

## Known Zone IDs

<!-- Customize: add your domains and zone IDs -->

| Domain | Zone ID |
|--------|---------|
| example.com | `<ZONE_ID>` |

## Operations

### List all zones (find zone ID)
```bash
curl -s -H "X-API-Key: $DNS_API_KEY" "$DNS_API_BASE" | jq '.[] | {name, id}'
```

### List records for a zone
```bash
curl -s -H "X-API-Key: $DNS_API_KEY" "$DNS_API_BASE/{zoneId}" | jq '.records[] | {name, type, content, id}'
# Filter by type:
curl -s -H "X-API-Key: $DNS_API_KEY" "$DNS_API_BASE/{zoneId}?recordType=A"
```

### Add record
```bash
curl -s -X POST \
  -H "X-API-Key: $DNS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '[{"name":"sub.domain.com","type":"A","content":"1.2.3.4","ttl":3600}]' \
  "$DNS_API_BASE/{zoneId}/records"
```

### Update record (need record ID first)
```bash
curl -s -X PUT \
  -H "X-API-Key: $DNS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content":"1.2.3.4","ttl":3600}' \
  "$DNS_API_BASE/{zoneId}/records/{recordId}"
```

### Delete record
```bash
curl -s -X DELETE \
  -H "X-API-Key: $DNS_API_KEY" \
  "$DNS_API_BASE/{zoneId}/records/{recordId}"
```

## Workflow

1. If zone ID unknown: list zones, find matching domain
2. List existing records for the zone
3. Add / update / delete as needed
4. Verify: `dig sub.domain.com @8.8.8.8` (propagation takes 1-5 min)

## Common Record Types

| Type | Use case | Example content |
|------|----------|-----------------|
| A | IPv4 | `65.21.90.216` |
| CNAME | Alias | `cname.vercel-dns.com` |
| TXT | Verification, SPF | `"v=spf1 include:..."` |
| MX | Email | `10 smtp.example.com` |

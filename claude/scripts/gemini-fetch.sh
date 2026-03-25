#!/bin/bash
# Fetch URL content via Gemini API (fallback when Claude's WebFetch is blocked)
# Usage: gemini-fetch.sh [--raw] "https://example.com"
#
# Requires: GEMINI_API_KEY environment variable

RAW=0
if [ "$1" = "--raw" ]; then
  RAW=1
  shift
fi

URL="$1"
if [ -z "$URL" ]; then
  echo "Usage: gemini-fetch.sh [--raw] <url>" >&2
  exit 1
fi

API_KEY="${GEMINI_API_KEY:?Set GEMINI_API_KEY environment variable}"
API_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${API_KEY}"

PROMPT="Visit this URL and extract ALL the text content from the page. Return every piece of text you find, preserving the structure. Do not summarize. URL: ${URL}"

if command -v jq >/dev/null 2>&1; then
  PAYLOAD=$(jq -n --arg prompt "$PROMPT" '{
    contents: [{parts: [{text: $prompt}]}],
    tools: [{url_context: {}}]
  }')
else
  PAYLOAD=$(python3 -c "
import json, sys
print(json.dumps({
    'contents': [{'parts': [{'text': sys.argv[1]}]}],
    'tools': [{'url_context': {}}]
}))
" "$PROMPT")
fi

HTTP_RESPONSE=$(curl -s --max-time 30 -w "\n%{http_code}" \
  "$API_URL" \
  -H 'Content-Type: application/json' \
  -d "$PAYLOAD" 2>/dev/null)

CURL_EXIT=$?
if [ $CURL_EXIT -ne 0 ]; then
  [ $CURL_EXIT -eq 28 ] && echo "gemini-fetch: request timed out after 30s" >&2 || echo "gemini-fetch: curl failed (exit $CURL_EXIT)" >&2
  exit 1
fi

HTTP_CODE=$(echo "$HTTP_RESPONSE" | tail -1)
BODY=$(echo "$HTTP_RESPONSE" | sed '$d')

[ "$RAW" = "1" ] && echo "$BODY" && exit 0

if [ "$HTTP_CODE" != "200" ]; then
  ERR_MSG=$(echo "$BODY" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    err = data.get('error', {})
    print(f\"{err.get('code', 'unknown')}: {err.get('message', 'unknown error')}\")
except:
    print('unknown error')
" 2>/dev/null)
  echo "gemini-fetch: API error (HTTP $HTTP_CODE): $ERR_MSG" >&2
  exit 1
fi

RESULT=$(echo "$BODY" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    candidate = data.get('candidates', [{}])[0]
    finish = candidate.get('finishReason', '')
    if finish in ('SAFETY', 'RECITATION', 'OTHER'):
        print(f'gemini-fetch: response blocked ({finish})', file=sys.stderr)
        sys.exit(1)
    parts = candidate.get('content', {}).get('parts', [])
    texts = [p['text'] for p in parts if 'text' in p]
    if not texts:
        print('gemini-fetch: empty response from API', file=sys.stderr)
        sys.exit(1)
    print('\n'.join(texts))
except json.JSONDecodeError:
    print('gemini-fetch: invalid JSON in API response', file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f'gemini-fetch: {e}', file=sys.stderr)
    sys.exit(1)
")

PYTHON_EXIT=$?
[ $PYTHON_EXIT -ne 0 ] && exit 1

if [ -z "$RESULT" ] || echo "$RESULT" | grep -qi "content is provided above"; then
  RETRY_PROMPT="Fetch the web page at this URL and return its full text content verbatim. Include all headings, paragraphs, lists, and any other text. Do not add commentary. URL: ${URL}"
  if command -v jq >/dev/null 2>&1; then
    RETRY_PAYLOAD=$(jq -n --arg prompt "$RETRY_PROMPT" '{contents: [{parts: [{text: $prompt}]}], tools: [{url_context: {}}]}')
  else
    RETRY_PAYLOAD=$(python3 -c "import json, sys; print(json.dumps({'contents': [{'parts': [{'text': sys.argv[1]}]}], 'tools': [{'url_context': {}}]}))" "$RETRY_PROMPT")
  fi
  RETRY_RESPONSE=$(curl -s --max-time 30 -w "\n%{http_code}" "$API_URL" -H 'Content-Type: application/json' -d "$RETRY_PAYLOAD" 2>/dev/null)
  RETRY_CODE=$(echo "$RETRY_RESPONSE" | tail -1)
  RETRY_BODY=$(echo "$RETRY_RESPONSE" | sed '$d')
  if [ "$RETRY_CODE" = "200" ]; then
    RETRY_RESULT=$(echo "$RETRY_BODY" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    parts = data.get('candidates', [{}])[0].get('content', {}).get('parts', [])
    texts = [p['text'] for p in parts if 'text' in p]
    if texts: print('\n'.join(texts))
except: pass
")
    if [ -n "$RETRY_RESULT" ] && ! echo "$RETRY_RESULT" | grep -qi "content is provided above"; then
      echo "$RETRY_RESULT"
      exit 0
    fi
  fi
  [ -n "$RESULT" ] && echo "$RESULT" || { echo "gemini-fetch: could not extract useful content" >&2; exit 1; }
else
  echo "$RESULT"
fi

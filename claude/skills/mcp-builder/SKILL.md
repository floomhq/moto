---
name: mcp-builder
description: Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. Use when building MCP servers to integrate external APIs or services, whether in Python (FastMCP) or Node/TypeScript (MCP SDK).
---

# MCP Server Development Guide

## Overview

Create MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. The quality of an MCP server is measured by how well it enables LLMs to accomplish real-world tasks.

---

# Process

## High-Level Workflow

### Phase 1: Deep Research and Planning

#### 1.1 Understand Modern MCP Design

**API Coverage vs. Workflow Tools:**
Balance comprehensive API endpoint coverage with specialized workflow tools. When uncertain, prioritize comprehensive API coverage.

**Tool Naming and Discoverability:**
Use consistent prefixes (e.g., `github_create_issue`, `github_list_repos`) and action-oriented naming.

**Actionable Error Messages:**
Error messages should guide agents toward solutions with specific suggestions and next steps.

#### 1.2 Study MCP Protocol Documentation

Start with the sitemap: `https://modelcontextprotocol.io/sitemap.xml`

Then fetch specific pages with `.md` suffix for markdown format.

#### 1.3 Framework Documentation

**Recommended stack:**
- **Language**: TypeScript (high-quality SDK support, good AI model familiarity, static typing)
- **Transport**: Streamable HTTP for remote servers (stateless JSON). stdio for local servers.

**For TypeScript:**
- TypeScript SDK: `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md`

**For Python:**
- Python SDK: `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md`

#### 1.4 Plan Your Implementation

Review the service's API documentation to identify key endpoints, authentication requirements, and data models. List endpoints to implement, starting with the most common operations.

---

### Phase 2: Implementation

#### 2.1 Set Up Project Structure

**TypeScript:**
```
my-mcp-server/
├── src/
│   ├── index.ts
│   └── tools/
├── package.json
├── tsconfig.json
└── README.md
```

**Python:**
```
my-mcp-server/
├── server.py
├── requirements.txt
└── README.md
```

#### 2.2 Implement Core Infrastructure

Create shared utilities:
- API client with authentication
- Error handling helpers
- Response formatting (JSON/Markdown)
- Pagination support

#### 2.3 Implement Tools

For each tool:

**Input Schema (TypeScript with Zod):**
```typescript
import { z } from 'zod';

const SearchParams = z.object({
  query: z.string().describe('Search query'),
  limit: z.number().optional().default(10).describe('Max results'),
});
```

**Input Schema (Python with Pydantic):**
```python
from pydantic import BaseModel, Field

class SearchParams(BaseModel):
    query: str = Field(description="Search query")
    limit: int = Field(default=10, description="Max results")
```

**Tool Description:**
- Concise summary of functionality
- Parameter descriptions with examples
- Return type schema

**Tool Annotations:**
- `readOnlyHint`: true/false
- `destructiveHint`: true/false
- `idempotentHint`: true/false

---

### Phase 3: Review and Test

#### 3.1 Code Quality

Review for:
- No duplicated code (DRY principle)
- Consistent error handling
- Full type coverage
- Clear tool descriptions

#### 3.2 Build and Test

**TypeScript:**
```bash
npm run build
npx @modelcontextprotocol/inspector
```

**Python:**
```bash
python -m py_compile server.py
```

---

### Phase 4: Create Evaluations

Create 10 evaluation questions to test whether LLMs can effectively use the MCP server.

**Requirements for each question:**
- **Independent**: Not dependent on other questions
- **Read-only**: Only non-destructive operations required
- **Complex**: Requiring multiple tool calls and deep exploration
- **Realistic**: Based on real use cases
- **Verifiable**: Single, clear answer that can be verified by string comparison
- **Stable**: Answer won't change over time

**Output format:**
```xml
<evaluation>
  <qa_pair>
    <question>Your question here</question>
    <answer>The verifiable answer</answer>
  </qa_pair>
</evaluation>
```

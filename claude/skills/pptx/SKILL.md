---
name: pptx
description: "Use this skill any time a .pptx file is involved in any way — as input, output, or both. This includes: creating slide decks, pitch decks, or presentations; reading, parsing, or extracting text from any .pptx file; editing, modifying, or updating existing presentations; combining or splitting slide files; working with templates, layouts, speaker notes, or comments. Trigger whenever the user mentions \"deck,\" \"slides,\" \"presentation,\" or references a .pptx filename, regardless of what they plan to do with the content afterward."
---

# PPTX Skill

## Quick Reference

| Task | Guide |
|------|-------|
| Read/analyze content | `python -m markitdown presentation.pptx` |
| Edit or create from template | Unpack XML, edit, repack |
| Create from scratch | Use pptxgenjs |

---

## Reading Content

```bash
# Text extraction
python -m markitdown presentation.pptx

# Raw XML
unzip -o presentation.pptx -d unpacked/
```

---

## Creating from Scratch

Install: `npm install -g pptxgenjs`

```javascript
const pptx = new PptxGenJS();

const slide = pptx.addSlide();
slide.addText("Hello World", { x: 1, y: 1, w: 8, h: 1, fontSize: 36 });

pptx.writeFile({ fileName: "presentation.pptx" });
```

---

## Design Ideas

**Don't create boring slides.** Consider these ideas for each slide.

### Before Starting

- **Pick a bold, content-informed color palette**: Should feel designed for THIS topic.
- **Dominance over equality**: One color should dominate (60-70% visual weight).
- **Dark/light contrast**: Dark backgrounds for title + conclusion, light for content.
- **Commit to a visual motif**: Pick ONE distinctive element and repeat it.

### Color Palettes

| Theme | Primary | Secondary | Accent |
|-------|---------|-----------|--------|
| **Midnight Executive** | `1E2761` (navy) | `CADCFC` (ice blue) | `FFFFFF` (white) |
| **Forest & Moss** | `2C5F2D` (forest) | `97BC62` (moss) | `F5F5F5` (cream) |
| **Coral Energy** | `F96167` (coral) | `F9E795` (gold) | `2F3C7E` (navy) |
| **Warm Terracotta** | `B85042` (terracotta) | `E7E8D1` (sand) | `A7BEAE` (sage) |
| **Charcoal Minimal** | `36454F` (charcoal) | `F2F2F2` (off-white) | `212121` (black) |

### Typography

| Header Font | Body Font |
|-------------|-----------|
| Georgia | Calibri |
| Arial Black | Arial |
| Calibri | Calibri Light |
| Cambria | Calibri |

| Element | Size |
|---------|------|
| Slide title | 36-44pt bold |
| Section header | 20-24pt bold |
| Body text | 14-16pt |
| Captions | 10-12pt muted |

### Avoid (Common Mistakes)

- **Don't repeat the same layout** - vary columns, cards, and callouts across slides
- **Don't center body text** - left-align paragraphs; center only titles
- **Don't default to blue** - pick colors that reflect the specific topic
- **Don't create text-only slides** - add images, icons, charts, or visual elements
- **NEVER use accent lines under titles** - hallmark of AI-generated slides; use whitespace instead

---

## QA (Required)

**Assume there are problems. Your job is to find them.**

### Content QA

```bash
python -m markitdown output.pptx
```

Check for missing content, typos, wrong order.

**Check for leftover placeholder text:**
```bash
python -m markitdown output.pptx | grep -iE "xxxx|lorem|ipsum|placeholder"
```

### Visual QA

Convert slides to images for visual inspection:

```bash
soffice --headless --convert-to pdf output.pptx
pdftoppm -jpeg -r 150 output.pdf slide
```

This creates `slide-01.jpg`, `slide-02.jpg`, etc. Inspect each one.

### Verification Loop

1. Generate slides → Convert to images → Inspect
2. List issues found (if none found, look again more critically)
3. Fix issues
4. Re-verify affected slides
5. Repeat until a full pass reveals no new issues

---

## Dependencies

- `pip install "markitdown[pptx]"` - text extraction
- `npm install -g pptxgenjs` - creating from scratch
- LibreOffice (`soffice`) - PDF conversion
- Poppler (`pdftoppm`) - PDF to images

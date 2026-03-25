---
name: xlsx
description: "Use this skill any time a spreadsheet file is the primary input or output. This means any task where the user wants to: open, read, edit, or fix an existing .xlsx, .xlsm, .csv, or .tsv file (e.g., adding columns, computing formulas, formatting, charting, cleaning messy data); create a new spreadsheet from scratch or from other data sources; or convert between tabular file formats. Trigger especially when the user references a spreadsheet file by name or path. Also trigger for cleaning or restructuring messy tabular data files into proper spreadsheets."
---

# Requirements for Outputs

## All Excel files

### Professional Font
Use a consistent, professional font (e.g., Arial, Times New Roman) for all deliverables unless otherwise instructed.

### Zero Formula Errors
Every Excel model MUST be delivered with ZERO formula errors (#REF!, #DIV/0!, #VALUE!, #N/A, #NAME?).

### Preserve Existing Templates
Study and EXACTLY match existing format, style, and conventions when modifying files. Never impose standardized formatting on files with established patterns.

## Financial models

### Color Coding Standards

#### Industry-Standard Color Conventions
- **Blue text (RGB: 0,0,255)**: Hardcoded inputs and numbers users will change for scenarios
- **Black text (RGB: 0,0,0)**: ALL formulas and calculations
- **Green text (RGB: 0,128,0)**: Links pulling from other worksheets within same workbook
- **Red text (RGB: 255,0,0)**: External links to other files
- **Yellow background (RGB: 255,255,0)**: Key assumptions needing attention

### Number Formatting Standards
- **Years**: Format as text strings (e.g., "2024" not "2,024")
- **Currency**: Use $#,##0 format; ALWAYS specify units in headers ("Revenue ($mm)")
- **Zeros**: Use number formatting to make all zeros "-"
- **Percentages**: Default to 0.0% format (one decimal)
- **Multiples**: Format as 0.0x for valuation multiples
- **Negative numbers**: Use parentheses (123) not minus -123

---

# XLSX creation, editing, and analysis

## CRITICAL: Use Formulas, Not Hardcoded Values

**Always use Excel formulas instead of calculating values in Python and hardcoding them.**

```python
# ❌ WRONG - Hardcoding Calculated Values
total = df['Sales'].sum()
sheet['B10'] = total  # Hardcodes 5000

# ✅ CORRECT - Using Excel Formulas
sheet['B10'] = '=SUM(B2:B9)'
sheet['C5'] = '=(C4-C2)/C2'
sheet['D20'] = '=AVERAGE(D2:D19)'
```

## Reading and analyzing data

```python
import pandas as pd

# Read Excel
df = pd.read_excel('file.xlsx')
all_sheets = pd.read_excel('file.xlsx', sheet_name=None)  # All sheets as dict

# Analyze
df.head()
df.info()
df.describe()
```

## Common Workflow

1. **Choose tool**: pandas for data analysis, openpyxl for formulas/formatting
2. **Create/Load**: Create new workbook or load existing file
3. **Modify**: Add/edit data, formulas, and formatting
4. **Save**: Write to file
5. **Recalculate formulas (MANDATORY IF USING FORMULAS)**: Use LibreOffice macro or recalculation script
6. **Verify and fix any errors**: Check for #REF!, #DIV/0!, #VALUE!, #NAME?

## Creating new Excel files

```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment

wb = Workbook()
sheet = wb.active

# Add data
sheet['A1'] = 'Hello'
sheet['B2'] = '=SUM(A1:A10)'

# Formatting
sheet['A1'].font = Font(bold=True, color='FF0000')
sheet['A1'].fill = PatternFill('solid', start_color='FFFF00')
sheet['A1'].alignment = Alignment(horizontal='center')
sheet.column_dimensions['A'].width = 20

wb.save('output.xlsx')
```

## Editing existing Excel files

```python
from openpyxl import load_workbook

wb = load_workbook('existing.xlsx')
sheet = wb.active

# Modify cells
sheet['A1'] = 'New Value'
sheet.insert_rows(2)
sheet.delete_cols(3)

wb.save('modified.xlsx')
```

## Formula Verification Checklist

- [ ] **Test 2-3 sample references**: Verify they pull correct values before building full model
- [ ] **Column mapping**: Confirm Excel columns match expectations
- [ ] **Row offset**: Remember Excel rows are 1-indexed (DataFrame row 5 = Excel row 6)
- [ ] **NaN handling**: Check for null values with `pd.notna()`
- [ ] **Division by zero**: Check denominators before using `/` in formulas (#DIV/0!)
- [ ] **Wrong references**: Verify all cell references point to intended cells (#REF!)
- [ ] **Cross-sheet references**: Use correct format (Sheet1!A1) for linking sheets

## Best Practices

- **pandas**: Best for data analysis, bulk operations, and simple data export
- **openpyxl**: Best for complex formatting, formulas, and Excel-specific features
- Use `data_only=True` to read calculated values - but **Warning**: saving with this flag permanently loses formulas
- Write minimal, concise Python code without unnecessary comments

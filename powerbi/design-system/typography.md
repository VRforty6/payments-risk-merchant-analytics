# Typography Guidelines

## Font Family
**Primary Font**: Segoe UI

**Why Segoe UI?**
- It is the system font for Windows, ensuring clarity and legibility across different resolutions.
- It is available on all Windows machines where Power BI Desktop runs.
- It has excellent readability for both dense data and headings.
- It pairs well with numeric data due to its proportional figures.

**Fallback Stack**: `Segoe UI, system-ui, -apple-system, BlinkMacSystemFont, 'Sans Serif'`

## Typographic Scale

We use a modular scale based on a ratio of 1.25 (minor third) for harmonious progression.

| Token | Size (px) | Usage |
|-------|-----------|-------|
| Display / 4XL | 30 | Rarely used, for major section headers on large screens |
| Display / 3XL | 24 | Page titles in dashboards |
| Display / 2XL | 20 | Section titles, major KPI labels |
| Display / XL | 16 | Subsection titles, card headers |
| Heading / L | 14 | Subheaders within cards, table headers |
| Heading / M | 12 | Column headers in tables, metric labels |
| Heading / S | 10 | Footnotes, axis labels (when space constrained) |
| Body / L | 14 | Body text in tables, tooltip bodies |
| Body / M | 12 | Detail text, secondary information |
| Body / S | 10 | Captions, dense data labels |
| Label / M | 12 | Form labels, slicer headers |
| Caption | 10 | Status messages, helper text |

## Font Weights

| Weight | Value | Usage |
|--------|-------|-------|
| Regular | 400 | Body text, labels |
| Medium | 500 | Semi-bold for emphasis without dominance |
| SemiBold | 600 | Key metrics, important labels |
| Bold | 700 | Header text, section titles |

## Line Height & Letter Spacing

| Context | Line Height | Letter Spacing |
|---------|-------------|----------------|
| Display | 1.2 | -0.5px (tight) |
| Heading | 1.3 | 0px |
| Body | 1.4 | 0px |
| Label | 1.2 | 0px |
| Caption | 1.2 | 0px |

## Text Styles in Power BI

When applying text styles in Power BI Desktop, use the following settings:

### Titles (Page, Section, Card)
- Font: Segoe UI
- Size: As per token (e.g., 24px for page title)
- Weight: SemiBold (600) or Bold (700) for highest prominence
- Color: Primary Text (#F8FAFC)
- Alignment: Left or Center as per layout

### Labels (Axis, Data Point, Tooltip)
- Font: Segoe UI
- Size: 10-12px
- Weight: Regular (400) or Medium (500)
- Color: Secondary Text (#94A3B8) for axis labels, Primary Text for tooltip values
- Alignment: Context-dependent

### Values (KPIs, Data Labels)
- Font: Segoe UI
- Size: Varies by importance (KPI values: 24-32px, card values: 14-18px)
- Weight: Bold (700) for KPIs, SemiBold (600) for card values
- Color: 
  - Primary Value: Primary Text (#F8FAFC) or Accent colors for emphasis
  - Secondary Value: Secondary Text (#94A3B8)
  - Status-based: Positive/Warning/Negative colors as per semantic tokens

## Accessibility Considerations

### Contrast Ratios
- All text must meet WCAG 2.1 AA contrast ratios:
  - Normal text: minimum 4.5:1
  - Large text (18pt+ or 14pt bold): minimum 3:1
- Primary Text (#F8FAFC) on Page Background (#0F172A) = 15.3:1 ✓
- Secondary Text (#94A3B8) on Page Background (#0F172A) = 7.3:1 ✓
- Accent Blue (#3B82F6) on Card Background (#111827) = 5.6:1 ✓

### Text Scaling
- Ensure text remains legible when scaled up to 200%.
- Avoid using text in images; all text should be selectable where possible (though Power BI has limitations).

## Implementation Notes for Power BI

1. **Title Objects**: Use the built-in title properties of visuals and pages where possible. For custom positioning, use text boxes.
2. **Consistency**: Apply the same font family to all text elements. Do not mix fonts.
3. **Dynamic Sizing**: Unlike paginated reports, Power BI does not support dynamic font sizing based on viewport. Design for the target canvas size (1280x720 or 1366x768).
4. **Tooltip Text**: Tooltip pages in Power BI have automatic font scaling; set base size to 12px for body text.
5. **Data Labels**: When enabling data labels on charts, set font size to 10pt and color to match the context (often Primary Text on dark backgrounds).

## References

- Microsoft Fluent Design System: https://microsoft.github.io/foundation-components/
- Power BI Accessibility: https://learn.microsoft.com/power-bi/fundamentals/desktop-accessibility-overview
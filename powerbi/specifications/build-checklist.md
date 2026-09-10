# Build Checklist

This checklist serves as a final validation before considering a report page (or the entire report) complete. It consolidates requirements from the design system, specifications, and implementation rules.

## General Project Setup
- [ ] Repository structure is correct:
  - `/powerbi/assets/` contains logos, navigation icons, controls, and background SVGs
  - `/powerbi/design-system/` contains tokens, typography, spacing-grid, component library, and implementation rules
  - `/powerbi/specifications/` contains all page specs, master layout, navigation bookmarks, tooltip spec, selection pane order, and this checklist
  - `/powerbi/theme/` contains the JSON theme file
  - `/powerbi/dax/` contains the DAX measures document
- [ ] Theme file `/powerbi/theme/payments-risk-theme.json` is valid JSON and includes all required properties (name, dataColors, background, foreground, etc.)
- [ ] All SVG assets are present, well‑formed, and editable (open in a text editor to verify XML structure)

## Per‑Page Validation
Repeat the following for each of the five report pages:
1. Executive Overview
2. Merchant Risk Analysis
3. Transaction Diagnostics
4. Data Quality & Reconciliation
5. Merchant Drillthrough

### 1. Canvas and Theme
- [ ] Page size set to exactly 1280 × 720 pixels (Format → Page size → Custom)
- [ ] Theme applied: `/powerbi/theme/payments-risk-theme.json` (View → Themes → Browse for theme)
- [ ] Page background color is `#0F172A` (set in theme or Format → Page background)

### 2. Layout and Grid
- [ ] Snap to grid and snap to objects enabled (View tab)
- [ ] Margins respected: 24px outer margin on all sides
- [ ] Navigation ribbon present on left edge:
  - Collapsed width: 64px (icons only)
  - Expanded width: 240px (icons + text)
  - Background color: `#0B1120`
  - Items vertically spaced with 24px top and bottom margins, 16px between items
  - Icons: 20x20px, colored correctly (default `#94A3B8`, selected/hover `#F8FAFC`)
  - Text labels: Segoe UI, 12pt, Medium (500), colored correctly
- [ ] Header height: 64px, transparent background
  - Title and subtitle left‑aligned, vertically centered
  - Date slicer, filter button, reset button right‑aligned, vertically centered
  - All header text uses Segoe UI
- [ ] Content area lies below header and respects navigation ribbon width
- [ ] KPI row (if present) placed 24px below header bottom
  - KPI card dimensions: 150px wide × 90px high (or as specified per page)
  - Gap between KPI cards: 23px
  - Vertical margins above and below KPI row: 24px
  - KPI card styling:
    - Background: `#111827`
    - Border: 1px solid `#243044`
    - Border radius: 8px
    - Internal padding: 16px
    - Value font: Segoe UI Bold (600‑700), size 24‑28pt, color `#F8FAFC` or conditional
    - Label font: Segoe UI Regular (400), size 10‑12pt, color `#94A3B8`
- [ ] Chart containers:
  - Background: `#172033` (Raised Surface)
  - Border: 1px solid `#243044`
  - Border radius: 8px
  - Internal padding: 20px on all sides
  - Margin below container: 24px
  - Title (if present): Segoe UI SemiBold (600), 14pt, color `#F8FAFC`
- [ ] Visuals use correct chart types as specified in the page specification
- [ ] Axis labels, tick marks, and legend text use Segoe UI Regular (400), 10‑12pt, color `#94A3B8`
- [ ] Gridlines: subtle, using `#243044` at 10‑20% opacity or dashed
- [ ] Data colors follow the theme’s `dataColors` array in order:
  1. `#7C3AED` (Primary Violet)
  2. `#4F46E5` (Indigo)
  3. `#3B82F6` (Accent Blue)
  4. `#22C55E` (Positive)
  5. `#F59E0B` (Warning)
  6. `#EF4444` (Negative)
  7. `#06B6D4` (Info)
  8. `#A855F7` (Variant)
- [ ] Tooltips assigned and styled per `specifications/tooltip-specification.md`
  - Tooltip page size: 320 × 240 (Tooltip)
  - Background: `#111827`, border: 1px solid `#243044`, border radius: 6px, padding: 12px
  - Text: Segoe UI, values SemiBold (600) 11pt, labels Regular (400) 11pt
- [ ] Cross‑filtering and drillthrough interactions configured as per page specification
- [ ] Conditional formatting applied where specified (e.g., KPI thresholds, bar chart gradients)
- [ ] All text legible and meets contrast ratios (use WebAIM Contrast Checker or similar)
- [ ] No overlapping or misaligned objects (use arrow keys to nudge; movement should be in 4px increments with snap to grid)
- [ ] Selection pane names follow `specifications/selection-pane-order.md`
- [ ] Groups are used and named appropriately in the Selection pane
- [ ] Page performs acceptably with the full dataset (no excessive visual lag)

### 3. Interactivity and Navigation
- [ ] Navigation ribbon items:
  - Each icon/group correctly navigates to its intended page via Bookmark action
  - Tooltip on each item shows the name of the target page
  - Selected item highlights correctly (icon/text color change to `#F8FAFC`)
  - Optional: Nav toggle button (if implemented) correctly expands/collapses the ribbon
- [ ] Slicers:
  - Properly configured (single/multi select, dropdown, checkbox, date range, slider)
  - Clear labels and helpful hints (if needed)
  - Synced across pages where applicable (right‑click → Sync slicing)
  - Default states set as per page specification
- [ ] Buttons:
  - Correct action assigned (Page navigation, Back, Reset, etc.)
  - Visual feedback via bookmarks (hover/pressed states) if custom buttons used
  - Standard button sizes: 32x32px for icons, 36px height for text buttons
- [ ] Drillthrough:
  - Target page set as Drillthrough type in Page properties
  - Drillthrough field(s) added (typically `DimMerchant[MarcketKey]`)
  - “Keep all filters” enabled if desired
  - Back button (automatic or custom) works to return to previous state
  - Tooltips assigned to source visuals that trigger drillthrough
- [ ] Tooltips:
  - Assigned to all relevant visuals (charts, cards, maps, etc.)
  - Contain only static information (no buttons or links)
  - Follow the tooltip spec for layout and text styles

### 4. Accessibility
- [ ] All text meets WCAG 2.1 AA contrast ratios:
  - Normal text: ≥4.5:1 against immediate background
  - Large text (18pt+ or 14pt bold): ≥3:1
  - Key pairs verified (e.g., Primary Text on Page Background, Secondary Text on Card Background, etc.)
- [ ] No reliance on color alone to convey information; always include labels, patterns, or shapes
- [ ] Font sizes legible at 100% zoom (minimum body text 10pt)
- [ ] Logical tab order (though limited in Power BI): navigation → header controls → body content (left‑to‑right, top‑to‑bottom) → footer
- [ ] Screen‑reader friendly: clear titles and labels for all visuals (set the Title field in visual properties)

### 5. Performance
- [ ] No more than 6‑8 visuals per page (exceptions for simple KPI rows or slicers)
- [ ] Visuals are appropriately aggregated (e.g., daily not transaction‑level unless necessary)
- [ ] Images are compressed and optimized (if using imported PNG/JPEG)
- [ ] SVG shapes used where possible instead of imported images for icons and simple graphics
- [ ] DAX measures reviewed for efficiency (use variables, avoid unnecessary iterations)
- [ ] Query reduction: consider aggregating data in the model if real‑time granularity is not required

## Documentation and Handoff
- [ ] All specification files are present and up to date
- [ ] The design system files (`/powerbi/design-system/*`) reflect the final implemented design
- [ ] Any deviations from the specifications are documented and justified
- [ ] A README or handoff note is present in `/powerbi/` explaining how to use the theme, apply specifications, and maintain the design system

## Final Sign‑off
- [ ] The report has been reviewed against this checklist and all items are marked as complete
- [ ] Any known issues or limitations are documented separately
# Implementation Rules

## Overview

This document provides concrete rules and guidelines for implementing the Payments Risk & Analytics design system in Microsoft Power BI Desktop. Following these rules ensures consistency, maintainability, and fidelity to the design intent.

## General Principles

1. **Consistency Over Creativity**: Within this report suite, prioritize consistency with the design system over unique visual treatments.
2. **Accessibility First**: Ensure all implementations meet WCAG 2.1 AA contrast ratios and are navigable via keyboard (where possible in Power BI).
3. **Performance Conscious**: Minimize use of shapes and images that can impact render speed, especially on large datasets.
4. **Maintainability**: Design for ease of updates; use consistent naming and grouping in the Selection pane.
5. **Truth to Materials**: Represent interactive elements as they behave; do not fake interactivity where none exists.

## File and Project Organization

### Repository Structure
```
/powerbi
  /assets
    /logos
    /navigation
    /controls
    /backgrounds
  /design-system
    (tokens, typography, spacing, components, rules)
  /specifications
    (page specs, build guide, etc.)
  /theme
    payments-theme.json
  /dax
    dax-measures.md
  [Optional] /templates
    template.pbix
```

### Asset Sources
- **SVG Sources**: Store editable SVG files in `/assets` subdirectories as specified.
- **Exported Assets**: For use in Power BI, export PNGs at 1x, 2x, and 3x scale for raster needs, but prefer SVG where supported.
- **Master PBIX**: Maintain a template file (`/templates/template.pbix`) containing:
  - Theme applied
  - Page size set
  - Navigation shell built (with bookmarks)
  - Placeholder components styled correctly
  - For each new report page, duplicate a template page.

## Canvas and Page Setup

### 1. Canvas Size
- **Rule IR-1**: Set canvas size to exactly 1280 × 720 pixels (W x H) for all report pages.
  - *Justification*: Standard 16:9 resolution, ensures consistent positioning and scalability.
  - *Implementation*: Format → Page size → Type: Custom → Width: 1280, Height: 720.

### 2. Background
- **Rule IR-2**: Apply the page background color from the theme: `#0F172A`.
  - *Implementation*: Format → Page background → Color: #0F172A.
  - *Note*: Do not use images or gradients for page background unless specified in background SVGs (which are layered on top).

### 3. Visibility Guides
- **Rule IR-3**: Enable "Snap to grid" and "Snap to objects" (View tab) for precise alignment.
- **Rule IR-4**: Use a temporary grid overlay (optional) during design to validate placement against the 4px grid, but remove before finalizing.

## Layering and Z-Order

### 4. Background Layers
- **Rule IR-5**: Background SVG elements (if used) shall be placed as the bottom-most layer, directly on the canvas.
  - *Implementation*: Send backward to ensure no other elements appear beneath.
- **Rule IR-6**: Page background color (set in Format) lies beneath background SVG elements.

### 5. Content Order
- **Rule IR-7**: Logical stacking order (back to front):
  1. Page background color
  2. Background SVG (e.g., decorative accents, structural chrome)
  3. Main content (navigation ribbon, header, body)
  4. Overlays (tooltips, modals, alerts)
  5. Selection highlights (if any)

### 6. Naming Convention
- **Rule IR-8**: Use the following naming convention in the Selection pane:
  ```
  [Area]-[Subarea]-[Purpose]-[Instance if needed]
  ```
  Examples:
  - `Background-Structural-Horizon`
  - `Nav-Ribbon-Background`
  - `Nav-Ribbon-Item-Home`
  - `Header-Title-PageTitle`
  - `Header-Subtitle-PeriodLabel`
  - `Header-Slicer-DateRange`
  - `Header-Button-FilterToggle`
  - `Body-KPIRow-TransactionValue`
  - `Body-ChartContainer-TransactionTrend`
  - `Body-Visual-TransactionTrendLine`
  - `Footer-Text-Credit`
  - `Overlay-Tooltip-Export`
  - `Overlay-Modal-ConfirmDelete`
- **Rule IR-9**: Group related elements (e.g., all pieces of a nav item, a KPI card) and name the group appropriately.

## Specific Component Implementation

### 7. Navigation Ribbon
- **Rule IR-10**: The navigation ribbon shall be a fixed vertical strip on the left edge.
  - **Collapsed Width**: 64px
  - **Expanded Width**: 240px
  - **Implementation**:
    - Create a rectangle shape: X=0, Y=0, Width=64 (or 240), Height=720, Fill=#0B1120, No outline.
    - Name: `Nav-Ribbon-Background`
    - Place all nav items within this x-range.
- **Rule IR-11**: Nav items shall be vertically spaced with 16px between item centers (or 12px between bottom of one item and top of next).
  - First item top margin: 24px from top edge.
  - Last item bottom margin: 24px from bottom edge.
  - *Implementation*: Use guides or manual Y-positioning.
- **Rule IR-12**: Each nav item (in expanded state) consists of:
  - Left padding: 12px
  - Icon: 20x20px, left-aligned within item after padding
  - Space between icon and text: 12px
  - Text: left-aligned, vertically centered
  - Right padding: 12px (flexible to fill width)
  - *Alternative*: If text is omitted (collapsed), center the icon horizontally.
- **Rule IR-13**: Use the following colors for nav items:
  - **Icon Color (Default)**: #94A3B8 (Secondary Text)
  - **Icon Color (Hover)**: #F8FAFC (Primary Text)
  - **Icon Color (Selected)**: #F8FAFC (Primary Text)
  - **Text Color (Default)**: #94A3B8
  - **Text Color (Hover)**: #F8FAFC
  - **Text Color (Selected)**: #F8FAFC
  - **Background (Hover)**: #13182A (10% lift from nav background)
  - **Background (Selected)**: None (rely on text/icon color change) OR use a 4px left bar in #7C3AED
- **Rule IR-14**: Implement navigation via Bookmarks:
  - Each nav item (group) has two bookmarks: "Selected" and "Deselected" (or use one bookmark per state with visibility).
  - Simpler: Use the "Selection" pane visibility toggles with a single bookmark per view state, but for multiple states, use multiple bookmarks.
  - Recommended: For each page, create a bookmark that sets:
    - Correct page as active
    - Nav item for that page set to "Selected" state (via color change)
    - All other nav items set to "Default" state
- **Rule IR-15**: The logo shall be placed at the top of the nav ribbon, centered horizontally.
  - **Size**: Max width 48px (height auto) to maintain padding.
  - **Margin**: Top: 24px, Bottom: 24px (to first nav item)
  - *Implementation*: Image or shape, centered in the nav ribbon width.

### 8. Header
- **Rule IR-16**: The header shall be a 64px tall strip at the top, full width of the canvas.
  - *Implementation*: Rectangle: X=0, Y=0, Width=1280, Height=64, Fill=Transparent (or inherit page background).
  - Content placed within, respecting outer margins.
- **Rule IR-17**: Header content shall be horizontally aligned with the column grid (if visible) or respect the outer margin (24px) when nav is collapsed, or start at 240px when nav is expanded.
  - *Dynamic*: Since nav width changes, use two sets of positions (or approximate with a margin that works for both).
  - **Recommended Approach**: 
    - Place elements at X=24 (left margin) when nav collapsed.
    - When nav expanded, these elements will be at X=24+240=264, which may misalign with grid.
    - **Solution**: Design for expanded state (nav width 240) and accept that collapsed state will have a larger left margin (24+240=264px) OR create two separate header layouts and switch via bookmarks when toggling nav.
    - Given complexity, we recommend fixing the layout for expanded nav (most common for reporting) and placing content at X=264 (24 margin + 240 nav) from left edge.
    - Right content (date slicer, buttons) aligns to right edge minus 24px margin.
- **Rule IR-18**: Vertical centering within header:
  - Text baseline: vertically center within 64px height.
  - *Implementation*: Set Y position so that text height centers (e.g., for 14pt text ~19px height, Y = (64-19)/2 = 22.5px → round to 22 or 23).
- **Rule IR-19**: Elements:
  - **Left-aligned**: Page Title, Subtitle (if any)
  - **Right-aligned**: Date Slicer, Filter Button, Reset Filter Button (in that order from right to left)
  - *Spacing*: 12px between adjacent elements.

### 9. KPI Row
- **Rule IR-20**: KPI cards shall be placed in a single horizontal row below the header with 24px vertical margin from header bottom.
  - *Implementation*: First KPI card top = header bottom (64) + 24 = 88px from top.
- **Rule IR-21**: KPI card spacing:
  - Horizontal gap between cards: 24px
  - Vertical margins: 24px above and below the row (to separate from other content)
  - *Implementation*: Position each card sequentially: X = previous X + previous width + 24
- **Rule IR-22**: KPI card dimensions:
  - **Width**: 180px
  - **Height**: 90px
  - *Justification*: Allows 6 cards with margins: 6*180 + 5*24 = 1080 + 120 = 1200px width, leaving 40px total horizontal margin (20px each side) within the 1240px content area (1280 - 2*24).
    - Actually, content width depends on nav state. For expanded nav (240px), content width = 1280 - 240 - 24 (right margin) = 1016px? Let's recalc.
    - Better: Define content area as:
      - Left: edge of nav ribbon (0 if collapsed, 240 if expanded)
      - Right: canvas width minus right margin (1280 - 24 = 1256)
      - Width = 1256 - left_edge
      - For expanded nav: width = 1256 - 240 = 1016px
      - 6 cards at 180px = 1080px > 1016px → too wide.
    - **Adjustment**: Either reduce card width or reduce number of cards.
    - Given the spec requires 6 KPI cards, we must adjust.
    - **Revised**: 
      - Target: 6 cards in 1016px width with 24px gap between.
      - Total gap: 5 * 24 = 120px
      - Total width for cards: 1016 - 120 = 896px
      - Per card width: 896 / 6 ≈ 149.33px → round to 150px.
    - **Rule IR-22a**: KPI card width = 150px, height = 90px (aspect ratio 5:3).
    - Recalculate horizontal margin: 
      - Used: 6*150 + 5*24 = 900 + 120 = 1020px
      - Available: 1016px → slight overflow of 4px → reduce gap to 23px or accept 2px overflow each side.
      - Final: Use 150px width, 23px gap → total = 6*150 + 5*23 = 900 + 115 = 1015px (within 1016px).
      - Vertical margins remain 24px.
- **Rule IR-23**: KPI card styling:
  - Background: #111827 (Card Background)
  - Border: 1px solid #243044 (Border)
  - Border Radius: 8px
  - Internal Padding: 16px (all sides)
  - *Implementation*: Set via shape properties or visual background if using Card visual.
- **Rule IR-24**: KPI content layout:
  - Value: Top half, large font (24-28pt), Bold, Primary Text (#F8FAFC) or Accent color
  - Label: Bottom half, smaller font (10-12pt), Regular, Secondary Text (#94A3B8)
  - Indicator (if any): Right-aligned, vertically centered, 12x12px
  - *Implementation*: Use two text boxes (value and label) and optionally a shape for indicator, grouped within the card boundary.

### 10. Chart Containers
- **Rule IR-25**: All charts shall be placed within a consistent container to ensure uniform appearance.
  - **Background**: #172033 (Raised Surface)
  - **Border**: 1px solid #243044 (Border)
  - **Border Radius**: 8px
  - **Padding**: 20px (all sides)
  - *Implementation*: 
    - Option A: Draw a rectangle with these properties, place the chart inside, align to inner edges.
    - Option B: Set the chart's background color and add borders via formatting if available, then manually position to leave 20px margin.
    - Given Power BI limitations, Option A is more reliable: create a "chart frame" shape, then place the visual so its edges align with the inner rectangle (i.e., visual positioned at (x+20, y+20) with width = frame width - 40, height = frame height - 40).
- **Rule IR-26**: Chart titles shall be placed within the top padding area (inside the 20px padding) or as part of the visual's title property.
  - If using visual title: Set font to Segoe UI SemiBold 14pt, color #F8FAFC, left-aligned.
  - If using separate text box: position at top-left inside padding.
- **Rule IR-27**: Axis labels and tick marks shall use Secondary Text (#94A3B8) at 10pt.
- **Rule IR-28**: Gridlines shall be subtle:.stroke #243044 at 20% opacity (or dashed if solid too harsh).
- **Rule IR-29**: Data colors shall follow the theme's `dataColors` array in order: 
  1. #7C3AED (Primary Violet)
  2. #4F46E5 (Indigo)
  3. #3B82F6 (Accent Blue)
  4. #22C55E (Positive)
  5. #F59E0B (Warning)
  6. #EF4444 (Negative)
  7. #06B6D4 (Info)
  8. #A855F7 (Variant)
- **Rule IR-30**: Legends shall use Secondary Text for labels, marker size consistent, and be positioned at bottom-right of chart area unless it obscures data.

### 11. Tooltips
- **Rule IR-31**: Use custom tooltip pages for all charts and key data points.
  - **Tooltip Page Size**: 320 × 240 pixels (Aspect 4:3) or adjust based on content density.
  - **Background**: #111827 (Card Background)
  - **Border**: 1px solid #243044 (Border)
  - **Border Radius**: 6px
  - **Padding**: 12px (all sides)
  - **Shadow**: 0px 4px 12px rgba(0,0,0,0.15) (if supported via shape effects or accept flat)
- **Rule IR-32**: Tooltip content shall follow the hierarchy:
  - **Title** (if needed): Bold, 12pt, Primary Text, margin-bottom 4px
  - **Sections divided by 1px solid #243044 at 20% opacity, margin 8px vertical
  - **Label-Value Pairs**: Label: Secondary Text, 11pt; Value: Primary Text, 11pt; right-align value or use space-between layout
  - **Icons**: 16x16px, Secondary Text, left of label with 8px spacing
- **Rule IR-33**: Do not include interactive elements (buttons, links) in tooltips.
- **Rule IR-34**: Assign tooltips via the visualization's Tooltip field well (drag desired fields there).

### 12. Interactions and Behavior

#### 12.1 Cross-Filtering
- **Rule IR-35**: Enable cross-filtering in both directions for related visuals unless it causes performance issues or confusion.
  - *Exception*: Avoid bidirectional filtering between two high-cardinality tables that could create many-to-many relationships causing ambiguity.
  - *Implementation*: Edit interactions via the Format → Edit interactions menu.

#### 12.2 Drillthrough
- **Rule IR-36**: Designate one page as the drillthrough target (Merchant Drillthrough).
  - **Setup**: On the target page, go to Page properties → Drillthrough → Type: Draggable field → Add MerchantKey (and/or MerchantName as supplemental).
  - **Back Navigation**: Include a back button in the header that uses the "Back" bookmark (automatically created by Power BI when drillthrough is used) or a custom bookmark that returns to the source page.
- **Rule IR-37**: From source visuals, enable drillthrough by dragging the relevant field (e.g., MerchantKey) to the Drillthrough filters well of the visual.

#### 12.3 Buttons and Navigation
- **Rule IR-38**: For page navigation (including nav ribbon and buttons), use Bookmarks to store and apply state.
  - **Best Practice**: Create a bookmark for each page that sets:
    - Current page view
    - Selected state of nav items
    - Any applicable filters or slicer states (if desired to persist)
  - **Navigation Button**: Set action to "Bookmark" and select the appropriate bookmark.
- **Rule IR-39**: Ensure the "Back" functionality works as expected:
  - When a drillthrough page is opened, Power Bi automatically creates a bookmark for the return state.
  - Use a button with action "Back" to return to the previous state.
  - For custom navigation (e.g., from homepage to detail via button), manually manage a stack or use explicit "go to page" bookmarks.

#### 12.4 Selection and Persistence
- **Rule IR-40**: Slicer selections should persist across pages when using sync slicers.
  - **Implementation**: 
    - Create each slicer once.
    - Right-click → Sync slicing → Apply to all relevant pages.
    - Ensure the slicer is visible (or hidden but synced) on each page where it should apply.
- **Rule IR-41**: Avoid using page-level filters when a slicer can provide the same functionality with better visibility and control.

### 13. Accessibility

#### 13.1 Color Contrast
- **Rule IR-42**: Verify all text meets WCAG 2.1 AA contrast ratios:
  - Normal text: ≥4.5:1 against background
  - Large text (18pt+ or 14pt bold): ≥3:1
  - Use tools like WebAIM Contrast Checker.
  - Key pairs:
    - Primary Text (#F8FAFC) on Page Background (#0F172A): 15.3:1 ✓
    - Secondary Text (#94A3B8) on Page Background (#0F172A): 7.3:1 ✓
    - Primary Text on Card Background (#111827): 12.6:1 ✓
    - Secondary Text on Card Background (#111827): 5.4:1 ✓
    - Accent Blue (#3B82F6) on Card Background (#111827): 5.6:1 ✓
    - White on Primary Violet (#7C3AED): 4.8:1 ✓ (for button text)
    - Black on White: 21:1 ✓ (not used)

#### 13.2 Text Scaling
- **Rule IR-43**: Avoid using text in images; all text should be selectable where possible.
  - In Power BI, text in visuals, text boxes, and shapes is selectable when exported to PDF or viewed in focus mode, but not in editing mode.
  - Ensure font sizes are legible at 100% zoom; minimum body text 10pt.

#### 13.3 Focus Order
- **Rule IR-44**: While tab order is limited in Power BI, ensure a logical flow:
  - Start from navigation (if interactive)
  - Then header controls (slicers, buttons)
  - Then main content (left to right, top to bottom)
  - Then footer
  - This is generally the default reading order.

#### 13.4 Screen Readers
- **Rule IR-45**: Provide clear titles and labels for all visuals.
  - Use the `Title` field in visual properties to describe the purpose.
  - Avoid relying solely on color to convey information; use labels, patterns, or shapes.

### 14. Performance

#### 14.1 Visual Complexity
- **Rule IR-46**: Limit the number of visuals per page to 6-8 to maintain performance and clarity.
  - Combine related metrics into single visuals where possible (e.g., combo chart).
  - Use tabs or drillthrough for secondary details.

#### 14.2 Image Usage
- **Rule IR-47**: Use SVG shapes where possible instead of imported images for icons and simple graphics.
  - For complex illustrations, export SVG to PNG at 2x scale for clarity.
  - Ensure images are compressed (use TinyPNG or similar) to reduce file size.

#### 14.3 Calculation Efficiency
- **Rule IR-48**: Optimize DAX measures:
  - Use variables to store intermediate results.
  - Avoid iterating over large fact tables when possible; use filtered tables.
  - Leverage relationships instead of LOOKUPVALUE where relationships exist.

### 15. Export and Distribution

#### 15.1 File Size
- **Rule IR-49**: Keep the PBIX file size under 500MB for ease of sharing.
  - Monitor via File → Options and settings → Options → Storage.
  - Reduce by:
    - Removing unnecessary columns in Power Query
    - Aggregating data where possible (e.g., store daily summaries instead of every transaction if acceptable)
    - Using appropriate data types (e.g., Int64 instead of String for IDs)

#### 15.2 Template Usage
- **Rule IR-50**: Start new report pages from the template file to ensure consistency.
  - Update the template as the design system evolves.
  - When updating existing reports, consider copying styled components from the template.

## Validation Checklist

Before considering a page complete, verify:

- [ ] Page size is exactly 1280x720
- [ ] Background color is #0F172A
- [ ] Navigation ribbon is present and functional
- [ ] Header elements are aligned and spaced correctly
- [ ] KPI row has 6 cards (if applicable) with correct spacing and styling
- [ ] All charts are in consistent containers with 20px padding
- [ ] Text uses Segoe UI throughout
- [ ] Font sizes adhere to the typographic scale
- [ ] Colors are from the defined palette
- [ ] Interactive elements have clear hover/selected states (via bookmarks or visual feedback)
- [ ] Tooltips are assigned and styled correctly
- [ ] Cross-filtering and drillthrough work as intended
- [ ] Navigation between pages works via nav ribbon and back buttons
- [ ] No overlapping or misaligned elements (use Snap to Grid to verify)
- [ ] All text meets contrast requirements
- [ ] The page is usable and informative at a glance

## Updating the Design System

- **Rule IR-51**: Propose changes to the design system via the appropriate markdown files in `/design-system`.
- **Rule IR-52**: Version the design system by date or release number in a `CHANGELOG.md` file at the root.
- **Rule IR-53**: When updating tokens or components, audit existing reports for compatibility and provide migration guidance.

## References

- Microsoft Power BI Documentation: https://learn.microsoft.com/power-bi/
- Accessibility in Power BI: https://learn.microsoft.com/power-bi/fundamentals/desktop-accessibility-overview
- Color Contrast Checker: https://webaim.org/resources/contrastchecker/
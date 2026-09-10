# Spacing and Grid System

## Base Principles

Our design system uses an 8-point grid system for consistency and scalability. However, to align with the 4px base token defined in design-tokens.md, we use a 4px grid where all spatial measurements are multiples of 4px. This provides finer control while maintaining consistency.

The 4px grid aligns well with:
- Typography baseline (4px line height increments)
- Icon sizes (typically multiples of 8px, which are also multiples of 4px)
- Common UI elements (buttons, padding, margins)

## Layout Grid

For the Power BI report canvas, we use a column grid to structure content.

### Canvas Size
We standardize on a 16:9 aspect ratio. Two recommended sizes:
- **Option A**: 1280 × 720 pixels (16:9 exactly)
- **Option B**: 1366 × 768 pixels (approximately 16:9)

This specification assumes **Option A: 1280 × 720 pixels** unless otherwise noted. All measurements in this document are based on this canvas.

### Margins
- **Outer Margin**: 24px (6 units) on all sides
- **Inner Margin (Gutter)**: 24px (6 units) between columns and rows

### Columns
- **Number of Columns**: 12
- **Column Width**: Calculated as:
  ```
  (Canvas Width - (2 × Outer Margin) - ((Column Count - 1) × Gutter)) / Column Count
  ```
  For 1280px canvas:
  ```
  (1280 - 48 - (11 × 24)) / 12 = (1280 - 48 - 264) / 12 = 968 / 12 = 80.666px
  ```
  We round to **81px** for practicality, with the understanding that slight adjustments may be needed.

  Actual calculation with 81px columns:
  ```
  Total used = 48 (margins) + (11 × 24) (gutters) + (12 × 81) (columns) = 48 + 264 + 972 = 1284px
  ```
  This exceeds by 4px. Alternate approach: adjust gutters or margins.

  Let's recalculate with fixed outer margin of 24px and aim for integer column width:
  ```
  Desired: (1280 - 48) = 1232px for columns + gutters
  With 12 columns and 11 gutters: 12C + 11G = 1232
  If we set Gutter = 24px: 12C + 264 = 1232 → 12C = 968 → C = 80.666px
  ```
  We'll use **80px** columns and adjust gutter to 24px, then the total becomes:
  ```
  Margins: 48px
  Gutters: 11 × 24 = 264px
  Columns: 12 × 80 = 960px
  Total: 48 + 264 + 960 = 1272px
  ```
  Leaving 8px of slack (4px on each side). We can distribute this as increased outer margin (24+4=28px each side) or leave as whitespace.

  For simplicity, we define:
  - **Outer Margin**: 24px
  - **Gutter**: 24px
  - **Column Width**: 80px
  - **Total Width Used**: 1272px (centered, with 4px left and right whitespace)

  This approach is acceptable as the whitespace is minimal and can be considered part of the margin.

### Rows
We use a vertical rhythm based on the 4px grid. Section spacing is defined in multiples of 4px.

### Component Alignment
- Align components to the column grid starts and ends.
- Allow components to span multiple columns for wider elements (e.g., charts).
- Maintain consistent vertical spacing between elements using the spacing scale.

## Spacing Scale

Refer to `design-tokens.md` for the 4px-based spacing scale (0-12). Common uses:

- **0px (0)**: Hairline borders, tight spacing
- **4px (1)**: Small padding (e.g., inside checkboxes), icon spacing
- **8px (2)**: Default spacing between compact elements, card internal padding
- **12px (3)**: Standard spacing between related elements
- **16px (4)**: Default section spacing, card-to-card spacing
- **20px (5)**: Increased separation
- **24px (6)**: Column gutter, major section spacing
- **32px (8)**: Large section spacing, top-level padding
- **40px (10)**: Major vertical rhythm
- **48px (12)**: Page-level spacing

## Specific Measurements for Power BI Pages

Based on the master layout (to be detailed in master-layout.md):

### Left Navigation Ribbon
- **Width (Collapsed)**: 64px (16 units) - icon only
- **Width (Expanded)**: 240px (60 units) - icon + text labels
- **Background**: Navigation Background (#0B1120)
- **Padding**:
  - Top: 24px (from top edge to first item)
  - Bottom: 24px (from last item to bottom edge)
  - Between items: 16px (vertical spacing)
  - Horizontal: 16px (icon to edge or text)

### Header
- **Height**: 64px (16 units)
- **Background**: Transparent (overlays page background)
- **Content Padding**:
  - Left: 24px (from left edge after nav if expanded, or from 64px mark if collapsed)
  - Right: 24px (from right edge)
  - Vertical: Vertically centered within header
- **Elements**:
  - Page Title: Left-aligned
  - Subtitle/Period: Left-aligned below title or right-aligned
  - Date Slicer: Right-aligned
  - Filter Button: Right-aligned before date slicer
  - Reset Filter Button: Right-aligned before filter button

### Content Area
- **Top**: Below header (0px header height)
- **Bottom**: Above bottom edge (respect outer margin)
- **Left**: Starts at left edge of nav ribbon (0 if collapsed, 240px if expanded)
- **Right**: Page width minus outer margin (24px)

### KPI Row
- **Height**: Determined by KPI card size (see below)
- **Spacing between KPI cards**: 24px (6 units) horizontally
- **Vertical margin above and below**: 24px (6 units) to separate from other sections

### KPI Card Dimensions
- **Width**: 180px (45 units) - allows for 6 cards with gutters: 6×180 + 5×24 = 1080 + 120 = 1200px (fits within 1272px content width with 36px slack)
- **Height**: 90px (22.5 units) - compact but readable
- **Internal Padding**: 16px (4 units) on all sides
- **Border Radius**: 8px (medium)
- **Background**: Card Background (#111827)
- **Border**: 1px solid Border (#243044)

### Chart Containers
- **Background**: Raised Surface (#172033)
- **Border**: 1px solid Border (#243044)
- **Border Radius**: 8px (medium)
- **Internal Padding**: 20px (5 units) on all sides
- **Margin Below**: 24px (6 units) to separate from next element

### Section Headers
- **Height**: 24px (6 units) for text
- **Margin Above**: 32px (8 units) from previous element
- **Margin Below**: 12px (3 units) to content

### Slicers
- **Horizontal Slicer (e.g., date range)**:
  - Height: 40px (10 units)
  - Width: As needed (typically 200-300px)
  - Margin: 12px (3 units) around
- **Vertical Slicer (e.g., checklist)**:
  - Width: 200px (50 units)
  - Margin: 12px (3 units) around

### Buttons
- **Icon Button**:
  - Size: 32px × 32px (8 units)
  - Padding: 8px (2 units) internal
  - Border Radius: 4px (small)
- **Text Button**:
  - Height: 36px (9 units)
  - Padding: Horizontal 16px (4 units), Vertical 8px (2 units)
  - Border Radius: 4px (small)
- **Icon Spacing**: 8px (2 units) between icon and text

## Vertical Rhythm

Maintain a vertical rhythm of 24px (6 units) between major sections (header to KPI row, KPI row to first chart row, between chart rows, etc.). Within sections, use 12px (3 units) for related elements and 6px (2 units) for compact grouping.

## Horizontal Alignment

- **Left-Aligned**: Default for text, navigation, page titles
- **Center-Aligned**: For cards or charts within a column when appropriate
- **Right-Aligned**: For actions (filter buttons, date pickers) in headers
- **Justified**: Rarely used, for tables when space permits

## Responsive Considerations (within fixed canvas)

Power BI reports are not responsive in the traditional sense, but we consider:
- **Collapsible Navigation**: Saves space for more content
- **Tile Alignment**: Use "Snap to Grid" to maintain alignment
- **Container Sizing**: Set explicit width/height for visuals to prevent stretching

## Implementation in Power BI Desktop

1. **Canvas Size**: Set via Page Size → Type: Custom → Width: 1280, Height: 720
2. **Margins**: Use the Selection and Visibility pane to position elements precisely. Enable snap to grid and snap to objects.
3. **Positioning**: Use the Format pane → Position to set exact X,Y coordinates.
4. **Sizing**: Use Format pane → Size to set exact width and height.
5. **Alignment**: Use the alignment tools (Align Left, Center, Distribute Horizontally, etc.) to align multiple objects.
6. **Grouping**: Group related elements (e.g., a KPI card with its title) to move as a unit.
7. **Z-Order**: Use Bring Forward/Send Backward for layering, especially for header over nav.

## Validation

To validate alignment:
- Turn on Snap to Grid and Snap to Objects.
- Use the arrow keys to nudge elements; they should move in 4px increments if snap is enabled.
- Measure distances between elements using temporary shapes or the ruler tool (if available via add-on).

## References

- Baseline Grid: https://css-tricks.com/baseline-grid/
- 8-Point Grid System: https://medium.com/@mylesbraithwaite/why-the-8-point-grid-system-works-in-ui-design-65810e8a8e9
- Power BI Design Guidelines: https://learn.microsoft.com/power-bi/create-reports/desktop-report-sizing
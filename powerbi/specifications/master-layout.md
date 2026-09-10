# Master Layout Specification

This document defines the overall layout structure, grid system, and positioning guidelines for all pages in the Payments Risk & Analytics Power BI report.

## Canvas Size
- **Width**: 1280 pixels
- **Height**: 720 pixels
- **Aspect Ratio**: 16:9

## Grid System
See `design-system/spacing-grid.md` for detailed grid specifications.

### Margins
- **Outer Margin**: 24px (6 units) on all sides
- **Content Area Width**: 1232px (1280 - 2*24) when navigation is collapsed
- **Content Area Width with Expanded Navigation**: 1016px (1280 - 240 - 24) where 240px is expanded nav width

### Columns
- **Column Count**: 12
- **Column Width**: 80px (calculated based on 1232px content width, 24px gutter)
- **Gutter (Column Gap)**: 24px (6 units)
- **Row Height**: Based on 4px grid, typical row heights are multiples of 4px

## Layout Regions

### 1. Navigation Ribbon (Left)
- **Position**: Fixed left edge
- **Width**: 
  - Collapsed: 64px (16 units)
  - Expanded: 240px (60 units)
- **Height**: 100% (720px)
- **Background**: Navigation Background (#0B1120)
- **Z-Index**: Below header content but above page background

### 2. Header (Top)
- **Position**: Top edge, full width
- **Height**: 64px (16 units)
- **Background**: Transparent (allows page background to show through)
- **Content Alignment**:
  - **Vertical**: Centered within 64px height
  - **Horizontal**: 
    - Left-aligned elements start at X = 24px (from left edge) when nav collapsed, or X = 264px (24 + 240) when nav expanded
    - Right-aligned elements end at X = 1256px (1280 - 24) from left edge
- **Elements** (left to right):
  - Page Title
  - Page Subtitle (optional, e.g., date range)
  - Spacer (flexible space)
  - Filter Button (icon)
  - Date Range Slicer
  - Reset Filter Button (icon)

### 3. Content Area
- **Position**: Below header, above bottom edge
- **Width**: 
  - Left boundary: Edge of navigation ribbon (0px if collapsed, 240px if expanded)
  - Right boundary: 1256px (1280 - 24) from left edge
- **Height**: 720 - 64 (header) = 656px
- **Padding**: None; content sits flush to edges but respects margins via positioning

### 4. KPI Row (Optional, directly below header)
- **Top Margin**: 24px below header bottom (Y = 88px from top)
- **Height**: Determined by KPI card size (typically 90px)
- **Horizontal Arrangement**: 
  - KPI Card Width: 150px (see Component Library for details)
  - Gap between cards: 23px
  - Number of cards: Variable, but typically 6 for executive overview
  - Total width: (number × 150) + ((number-1) × 23) ≤ content width
- **Vertical Margins**: 24px above and below the row to separate from other content

### 5. Chart Containers
- **Background**: Raised Surface (#172033)
- **Border**: 1px solid Border (#243044)
- **Border Radius**: 8px
- **Internal Padding**: 20px on all sides
- **Margin Below**: 24px to separate from next element
- **Width**: Variable, typically spans multiple columns
- **Height**: Variable, based on aspect ratio and data density

### 6. Footer (Optional)
- **Position**: Bottom edge, full width
- **Height**: Typically 24-40px
- **Background**: Transparent or same as page background
- **Content**: 
  - Left-aligned: Report generation timestamp or data refresh info
  - Right-aligned: Page number or confidentiality notice
  - Centered: Optional navigation aids (e.g., "View full report")

## Vertical Rhythm
- **Base Unit**: 24px (6 units) for major section spacing
- **Minor Spacing**: 12px (3 units) for related elements
- **Compact Spacing**: 6px (2 units) for tight grouping
- **Consistent Application**: Use spacing scales from `design-system/design-tokens.md`

## Z-Order (Back to Front)
1. Page Background Color (#0F172A)
2. Background SVG (if present, e.g., `/assets/backgrounds/*.svg`)
3. Navigation Ribbon Background
4. Header Background (transparent)
5. Main Content (KPI rows, charts, tables, etc.)
6. Tooltips
7. Modals/Overlays
8. Selection Highlights (e.g., drillthrough cross-filter highlights)

## Responsiveness Notes
Power BI reports are not responsive in the traditional sense, but the layout adapts to navigation state:
- **Navigation Collapsed**: More horizontal space for content (left edge at 0px)
- **Navigation Expanded**: Less horizontal space (left edge at 240px)
- **Design Strategy**: 
  - Create two sets of positions for header elements (for collapsed vs expanded nav) OR
  - Design for expanded nav state and accept larger left margin when collapsed (recommended for simplicity)
- **Vertical Positioning**: Unaffected by navigation state

## Implementation in Power BI Desktop
1. Set page size to 1280x720 (Format → Page size)
2. Apply theme (`powerbi/theme/payments-risk-theme.json`)
3. Enable "Snap to grid" and "Snap to objects" (View tab)
4. Use Selection pane to name and group elements per `naming convention`
5. Position elements using exact X,Y coordinates in Format pane → Position
6. Size elements using exact Width,Height in Format pane → Size
7. Use Alignment tools (Format pane when multiple objects selected) to distribute and align
8. Group related elements that move together (e.g., a KPI card's value, label, and background)
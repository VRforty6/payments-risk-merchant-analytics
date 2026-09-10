# Selection‑Pane Order and Naming Convention

This document defines the naming convention for objects (visuals, shapes, text boxes, images, etc.) in the Power BI Selection pane. Consistent naming improves maintainability, simplifies debugging, and facilitates collaboration.

## Naming Convention
Use the following hierarchical format:
```
[Area]-[Subarea]-[Purpose]-[Instance or Identifier if needed]
```
- **Area**: Broad section of the page (e.g., Header, Nav, Body, Footer, Overlay)
- **Subarea**: More specific location or group within the area (e.g., Title, Ribbon, Item, Card, Chart, Slicer)
- **Purpose**: What the object is or does (e.g., Background, Icon, Label, Value, Button, Visual)
- **Instance/Identifier**: A number, ID, or short descriptor to differentiate similar objects (e.g., 1, 2, A, B, or a specific name like “KPI1”, “Chart-Trend”)

### Rules
1. **Use hyphens** as separators.
2. **Keep names concise but descriptive**.
3. **Use Title Case for readability** (e.g., `Header-Title-PageTitle`), but lowercase is acceptable if it improves clarity (e.g., `nav-background`). Be consistent within the report.
4. **Avoid special characters** other than hyphens.
5. **Do not include spaces** at the beginning or end of the name.
6. **Group related objects** by naming them under a common parent hierarchy, then use the Selection pane’s grouping feature (Ctrl+G) to create a visual group.

## Area Definitions
| Area | Description |
|------|-------------|
| **Page** | The entire canvas (rarely used for individual objects) |
| **Background** | Decorative or structural elements behind all content (e.g., background SVGs, page color) |
| **Nav** | Navigation ribbon (left sidebar) |
| **Header** | Top strip (height 64px) containing title, subtitle, slicers, buttons |
| **Body** | Main content area below the header and above the footer |
| **Footer** | Bottom strip (optional) for timestamps, page numbers, etc. |
| **Overlay** | Temporary surfaces that appear on top (tooltips, modals, alerts, drillthrough highlights) |
| **KPI** | Key Performance Indicator cards |
| **Chart** | Data visualization containers (line, bar, map, etc.) |
| **Slicer** | Filtering controls (dropdown, checklist, date range) |
| **Button** | Interactive elements that trigger an action (navigation, back, reset, etc.) |
| **Text** | Static or dynamic text labels (titles, subtitles, labels, values) |
| **Shape** | Geometric rectangles, circles, lines used for layout or decoration |
| **Image** | Imported PNG, JPEG, or SVG files (icons, logos, illustrations) |
| **Group** | A collection of objects that move together (created via Ctrl+G) |

## Examples by Area

### Background
- `Background-Structural-Horizon` (a horizontal line or gradient)
- `Background-Pattern-Grid` (a subtle grid pattern)
- `Background-Logo-Watermark` (a faint logo in the corner)

### Nav Ribbon
- `Nav-Ribbon-Background` (the rectangle behind the nav items)
- `Nav-Ribbon-Item-Home` (group for the “Home” nav item: includes background, icon, label)
  - `Nav-Ribbon-Item-Home-Background` (item’s background shape)
  - `Nav-Ribbon-Item-Home-Icon` (the icon image or shape)
  - `Nav-Ribbon-Item-Home-Label` (the text label)
- `Nav-Toggle-Button` (button to collapse/expand the nav)

### Header
- `Header-Background` (optional shape behind header content)
- `Header-Title-PageTitle` (the main page title)
- `Header-Subtitle-PeriodLabel` (the dynamic date range subtitle)
- `Header-Slicer-DateRange` (the date range slicer visual)
- `Header-Button-FilterToggle` (the filter icon button)
- `Header-Button-Reset` (the reset filter icon button)

### Body (General)
- `Body-KPIRow-Container` (a group that holds the KPI row)
  - `Body-KPIRow-KPI1` (first KPI card group)
    - `Body-KPIRow-KPI1-Background`
    - `Body-KPIRow-KPI1-Value`
    - `Body-KPIRow-KPI1-Label`
    - `Body-KPIRow-KPI1-Indicator` (optional sparkline or status dot)
  - `Body-KPIRow-KPI2` (second KPI card)
  - … etc.
- `Body-ChartContainer-Trend` (container for the trend chart)
  - `Body-ChartContainer-Trend-Background` (the raised surface shape)
  - `Body-ChartContainer-Trend-Visual` (the actual line chart visual)
  - `Body-ChartContainer-Trend-Title` (text box for “Daily Transaction Volume & Approval Rate”)
- `Body-ChartContainer-DeclineReason` (container for the decline reason bar chart)
- `Body-ChartContainer-PaymentMethod` (container for the payment method stacked column)
- `Body-ChartContainer-Geomap` (container for the geographic heatmap)
- `Body-Slicer-MerchantRisk` (the merchant risk tier checkboxes slicer)
- `Body-Slicer-PaymentMethod` (the payment method dropdown slicer)
- `Body-Slicer-TransactionAmount` (the transaction amount range slider)

### Footer
- `Footer-Text-Timestamp` (text showing last refresh time)
- `Footer-Text-Confidentiality` (confidentiality notice)
- `Footer-Back` (back button if placed in footer)

### Overlay
- `Overlay-Tooltip-Merchant` (the tooltip page merchant-specific, though tooltips are separate pages; this would be for a custom popup)
- `Overlay-Modal-ConfirmDelete` (a confirmation dialog background)
- `Overlay-Alert-DataRefresh` (a banner showing data refresh status)

## Grouping Strategy
- **Logical Groups**: Select all objects that belong together (e.g., all pieces of a KPI card) and press Ctrl+G to create a group.
- **Naming Groups**: After creating a group, rename it in the Selection pane to reflect its purpose (e.g., `Body-KPIRow-KPI1`).
- **Nested Groups**: You can group groups (e.g., group all KPI cards into `Body-KPIRow`), but keep the hierarchy shallow (max 2‑3 levels deep) to avoid complexity.
- **Order in Selection Pane**: The Selection pane lists objects from top to bottom (front to back). To make it easier to find objects, consider arranging the list to match the visual layout (top‑to‑bottom, left‑to‑right) or use naming that sorts alphabetically to group related items.

## Implementation in Power BI Desktop
1. **Enable the Selection pane**: View → Show selection pane.
2. **Name objects immediately**: After inserting a visual, shape, or image, select it and rename it in the Selection pane to follow the convention.
3. **Use the Format pane**: To set properties, but always keep the Selection pane name updated.
4. **Group before naming**: If you plan to group objects, first create the group (Ctrl+G), then name the group, then name the children if needed.
5. **Leverage the search box**: The Selection pane has a search feature; consistent naming makes it easy to find all objects of a type (e.g., type “KPI” to see all KPI‑related objects).
6. **Maintain consistency**: When duplicating an object (Ctrl+C, Ctrl+V), rename the duplicate to avoid conflicts (e.g., copy `Body-KPIRow-KPI1` → rename to `Body-KPIRow-KPI2`).

## Validation Checklist
- [ ] Every visual, shape, text box, and image has a name in the Selection pane that follows the convention.
- [ ] Names are unique (no two objects share the exact same full name).
- [ ] Related objects share a common prefix (e.g., all KPI1 objects start with `Body-KPIRow-KPI1-`).
- [ ] Groups are used and named appropriately.
- [ ] The Selection pane is tidy and easy to navigate (no unnamed objects like “Shape 1”, “Text Box 2”, etc.).
- [ ] Abbreviations are clear and consistent across the report (e.g., “Btn” for button, “Txt” for text, “Img” for image).

## References
- Power BI Selection Pane: https://learn.microsoft.com/power-bi/create-reports/desktop-selection-pane
- Graphic Design Naming Conventions: Adapted from BEM (Block__Element--Modifier) and SUIT CSS methodologies
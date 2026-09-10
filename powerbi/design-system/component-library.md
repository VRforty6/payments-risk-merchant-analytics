# Component Library

## Overview

This document specifies the reusable UI components for the Payments Risk & Analytics Power BI dashboard. Components are designed to be assembled to build the report pages while maintaining visual and interaction consistency.

Components are categorized into:
1. **Containers** (layout structures)
2. **Controls** (interactive elements)
3. **Data Display** (visualizations and informational elements)
4. **Navigation** (navigation aids)
5. **Feedback** (status and messaging)
6. **Overlays** (temporary surfaces)

Each component specification includes:
- **Purpose**: What the component is used for
- **Appearance**: Visual properties (colors, sizing, spacing, states)
- **Behavior**: Interaction and states (if applicable)
- **Power BI Implementation**: How to build it in Power BI Desktop
- **Usage Guidelines**: Dos and don'ts

## Design Tokens Reference

All components should reference values defined in `design-tokens.md` for:
- Colors
- Typography
- Spacing
- Border Radius
- Elevation (shadows)

## 1. Containers

### 1.1 Page Container
**Purpose**: Defines the boundaries of the report page.
- **Properties**:
  - Background: Page Background (#0F172A)
  - Size: Fixed canvas (1280x720px)
  - Padding: Outer Margin (24px) from edge to content area
- **Implementation**: Set via Page Size settings. Background set in theme.
- **Usage**: Always applied; do not modify.

### 1.2 Surface
**Purpose**: Elevated container for grouping content (cards, charts).
- **Variants**:
  - **Default Surface**: Background: Card Background (#111827)
  - **Raised Surface**: Background: Raised Surface (#172033) - used for chart containers to lift them slightly
- **Properties**:
  - Border: 1px solid Border (#243044)
  - Border Radius: 8px (medium)
  - Padding: 
    - Card: 16px (4 units) internal
    - Chart Container: 20px (5 units) internal
  - Shadow: 
    - None (flat) for Card Background
    - Subtle: 0px 2px 4px rgba(0,0,0,0.2) for Raised Surface (if supported by theme visualStyles)
- **States**:
  - Default: As above
  - Hover: Increase shadow intensity slightly (if interactive)
  - Disabled: Opacity 0.6
- **Power BI Implementation**:
  - Use a combination of shapes (rectangle) and visual properties, or rely on the visual's own background/border settings.
  - For cards: Use a Text Box or Card visual with background color set.
  - For charts: Use the visual's background color and border settings.
- **Usage**:
  - Use Card Background for KPI cards and small info panels.
  - Use Raised Surface for chart containers to create visual hierarchy.

### 1.3 Container Variants for Specific Uses
- **KPI Card**: Specific card variant for key metrics (see Controls section for KPI metric display)
- **Chart Wrapper**: Raised Surface with specific padding for visuals
- **Sidebar Panel**: Vertical stack container for navigation or filters
- **Modal Backdrop**: Semi-transparent overlay (not natively supported; simulate with full-page shape if needed for custom popups)

## 2. Controls

### 2.1 Button
**Purpose**: Trigger an action.
- **Variants**:
  - **Primary**: Background: Primary Violet (#7C3AED), Text: Primary Text (#F8FAFC)
  - **Secondary**: Background: Transparent, Border: 1px solid Primary Violet, Text: Primary Violet
  - **Icon Only**: Background: Transparent, Icon Color: Inherit or specified
  - **Danger**: Background: Negative (#EF4444), Text: Primary Text
- **Properties**:
  - Height: 36px (9 units) for text buttons, 32px (8 units) for icon buttons
  - Padding: Horizontal 16px (4 units) for text buttons, 8px (2 units) for icon buttons
  - Border Radius: 4px (small)
  - Font: Segoe UI, SemiBold (600), 12pt
  - Icon Size: 20x20px (5 units) for icon buttons
  - Transition: None (Power BI limitation) but can simulate with hover if using bookmarks
- **States**:
  - Hover: Increase brightness of background by 10% (if interactive via bookmarks)
  - Pressed: Decrease brightness by 10%
  - Disabled: Opacity 0.6, background/greyed out
- **Power BI Implementation**:
  - Use Button visual (if available) or simulate with shapes and text boxes + bookmarks for interaction.
  - For simple navigation, use Button visual from Microsoft AppSource or use shapes with action URLs (for page navigation) or bookmarks.
  - Icon buttons: Use shapes (circle or rounded rect) with an SVG icon overlay, then add action.
- **Usage**:
  - Primary for main actions (e.g., Apply Filter)
  - Secondary for secondary actions (e.g., Reset)
  - Icon only for navigation (e.g., back, filter toggle)
  - Never use for decoration; always have a clear action.

### 2.2 KPI Indicator
**Purpose**: Display a key metric with comparative context (optional).
- **Composition**:
  - **Value**: Large numeric value
  - **Label**: Descriptive text below value
  - **Indicator (Optional)**: Small trend or status indicator (e.g., arrow, sparkline, colored dot)
- **Properties**:
  - **Value Font**: Segoe UI, Bold (700), 24-32pt depending on importance
  - **Label Font**: Segoe UI, Regular (400), 10-12pt
  - **Indicator Size**: 12x12px (3 units) for status dot, variable for sparkline
  - **Spacing**: 
    - Value to Label: 8px (2 units)
    - Label to Indicator: 8px (2 units) if inline
  - **Colors**:
    - Value: Primary Text (#F8FAFC) or Accent color for emphasis
    - Label: Secondary Text (#94A3B8)
    - Indicator: 
      - Positive: Success (#22C55E)
      - Warning: Warning (#F59E0B)
      - Negative: Negative (#EF4444)
      - Neutral: Primary Text
- **Container**: Card Background with padding 16px
- **Power BI Implementation**:
  - Use Card visual for value and label (set via Title and Category fields, or use two separate Cards).
  - Add indicator via:
    - Conditional icon in Card visual (if using newer Card visual)
    - Separate shape (e.g., circle) with conditional color
    - Small line chart for sparkline (hide axes)
- **Usage**:
  - Use for high-level metrics at top of page
  - Avoid overloading with too many KPIs; max 6 in a row
  - Always provide clear label and unit/context

### 2.3 Slicer
**Purpose**: Filter data in the report.
- **Variants**:
  - **Dropdown**: Single select or multi-select combobox
  - **List**: Vertical list of items (checkboxes for multi-select, radio for single)
  - **Slider**: Numeric range selector
  - **Date Range**: Specialized for dates
  - **Button Bar**: Horizontal toggles for mutually exclusive options
- **Properties**:
  - **Font**: Segoe UI, Regular (400), 10-12pt
  - **Text Color**: 
    - Selected Item: Primary Text (#F8FAFC)
    - Unselected Item: Secondary Text (#94A3B8)
    - Background: Item Background (varies by state)
  - **Item Height**: 32px (8 units) for touch-friendly targets
  - **Padding**: Horizontal 12px (3 units), Vertical 6px (1.5 units) - often implicit in control
  - **Border Radius**: 4px (small) for item backgrounds
  - **Dropdown Indicator**: 12px (3 units) down chevron, color Secondary Text
- **States**:
  - Default: As above
  - Hover: Background tint +5% (if interactive)
  - Selected: Background: Accent Blue (#3B82F6) or Primary Violet (#7C3AED) with white text
  - Disabled: Opacity 0.4
- **Power BI Implementation**:
  - Use built-in Slicer visual. Format via:
    - Turn on "Single select" for radio-button behavior
    - Use "Select all" option for multi-select
    - Orientation: Vertical or Horizontal
    - For date slicer: Use relative or absolute options
    - Style: 
      - Background: Transparent or Card Background
      - Toggle color: Accent color
      - Font color: as above
- **Usage**:
  - Place slicers in header (for global filters) or in a collapsible filter pane
  - Limit visible items; use search if many options
  - Clearly label what the slicer filters
  - Ensure sync slicers are used for cross-page consistency where needed

### 2.4 Input Fields (Text, Number)
**Purpose**: Allow user input (less common in reports, but used for parameter entry if needed).
- **Properties**:
  - Height: 36px (9 units)
  - Padding: Horizontal 12px (3 units), Vertical 8px (2 units)
  - Border: 1px solid Border (#243044)
  - Background: Input Background (Card Background #111827 or slightly lighter #1A2435)
  - Border Radius: 4px (small)
  - Font: Segoe UI, Regular (400), 12pt
  - Text Color: Primary Text (#F8FAFC)
  - Placeholder Color: Secondary Text (#94A3B8) at 60% opacity
- **States**:
  - Focus: Border color Primary Violet (#7C3AED), width 2px
  - Error: Border color Negative (#EF4444)
  - Disabled: Opacity 0.6
- **Power BI Implementation**:
  - Not natively available; use external tools like Power Apps for forms, or implement via what-if parameters (which generate a slicer-like control).
  - For simple numeric input, use What-If parameter.
- **Usage**:
  - Rare in reports; prefer slicers for discrete values
  - If used, ensure clear labeling and validation feedback

## 3. Data Display

### 3.1 Card (Metric Display)
**Purpose**: Show a single key value, similar to KPI but often used elsewhere in the page.
- **Differs from KPI Indicator**: Typically lacks trend indicator and may be smaller.
- **Properties**:
  - Value Font: Segoe UI, SemiBold (600), 14-18pt
  - Label Font: (Optional) Segoe UI, Regular (400), 10-12pt if label is inside card
  - Colors: 
    - Value: Primary Text or contextual (Positive, etc.)
    - Label: Secondary Text
  - Container: Card Background, 12px padding (3 units), Border Radius 6px
- **Power BI Implementation**: Use Card visual. Set data label to show category if needed.
- **Usage**: 
  - In tables or alongside charts to show totals
  - Avoid using for primary page KPIs; use KPI Indicator instead

### 3.2 Chart Container
**Purpose**: Frame a data visualization.
- **Properties**:
  - Background: Raised Surface (#172033)
  - Border: 1px solid Border (#243044)
  - Border Radius: 8px (medium)
  - Padding: 20px (5 units) all sides
  - Title Area: 24px height at top (if title is inside container)
- **Content**:
  - Chart Visual: Should fill the inner area
  - Axis Labels: Secondary Text (#94A3B8)
  - Axis Lines: Border color (#243044) at 50% opacity
  - Gridlines: Border color at 20% opacity (or transparent if possible)
  - Data Colors: From theme's dataColors array
  - Legend: Secondary Text, marker size consistent
  - Tooltip: Use custom tooltip page styled per specification
- **States**:
  - Default: As above
  - Loading: Show skeleton placeholder (animated grey bars) - simulate with static placeholder if needed
  - Error: Display error icon and message in center
  - Empty Data: Display illustrative message
- **Power BI Implementation**:
  - Set the visual's background color and add a border via the Format pane (if available).
  - If border not available, place visual inside a shape (rectangle) with desired properties.
  - Title: Use visual's title property or overlay a text box.
  - Ensure consistent padding by manually positioning visual or using alignment guides.
- **Usage**:
  - All charts should be placed in a consistent container to unify appearance
  - Do not remove border or radius unless justified (e.g., full-bleed background chart)

### 3.3 Table
**Purpose**: Display tabular data.
- **Properties**:
  - Header Background: Card Background (#111827)
  - Header Text: Secondary Text (#94A3B8), Bold (600)
  - Row Background: Alternating: 
    - Even: Transparent or Card Background
    - Odd: Raised Surface (#172033) at 5% opacity (or use a subtle stripe)
  - Text: Primary Text (#F8FAFC)
  - Grid Lines: Border color (#243044) at 20% opacity for horizontal lines
  - Column Header Divider: Border color at 50% opacity vertical
  - Border Radius: 6px on outer corners only
  - Overflow: Hidden (hide overflowing text with ellipsis)
- **Interactive States**:
  - Hover Row: Background: Primary Violet (#7C3AED) at 10% opacity
  - Selected Row: Border left: 3px solid Primary Violet
- **Power BI Implementation**:
  - Use Table or Matrix visual.
  - Format:
    - Row headers: Off
    - Column headers: On
    - Values: Don't summarize if already aggregated
    - Grid: Horizontal lines only
    - Background: Transparent (so we can set row colors conditionally via DAX or use built-in alternating rows)
    - Text size: 11pt
  - For conditional row coloring, use conditional formatting on the row background with a DAX measure.
- **Usage**: 
  - For detailed records (e.g., transaction list, merchant list)
  - Avoid for large datasets; enable scrolling
  - Always include row numbers or clear row selection

### 3.4 List
**Purpose**: Display a vertical list of items (similar to table but single column or simple).
- **Properties**:
  - Item Padding: 12px vertical (3 units), 16px horizontal (4 units)
  - Item Background: 
    - Default: Transparent
    - Hover: Primary Violet (#7C3AED) at 5% opacity
    - Selected: Background: Primary Violet at 15% opacity, left border 3px solid Primary Violet
  - Divider: Horizontal line, 1px, Border color at 20% opacity
  - Text: Primary Text, size 12pt
  - Icon: 16x16px (4 units) if leading, color Secondary Text
- **Power BI Implementation**:
  - Use a Table with single column and hide column header.
  - Or use a Card list with multiple cards (less efficient).
  - Best: Use a custom visual or build with buttons (not recommended for long lists).
- **Usage**: 
  - For simple lists (e.g., filter options, legend items)
  - Consider using a slicer for interactive lists

### 3.5 Tooltip
**Purpose**: Show contextual information on hover.
- **Properties**:
  - Background: Card Background (#111827)
  - Border: 1px solid Border (#243044)
  - Border Radius: 6px
  - Padding: 12px (3 units) all sides
  - Shadow: 0px 4px 12px rgba(0,0,0,0.15) (if supported)
  - Width: Max 300px (75 units), height auto
  - Text: Primary Text, size 11pt
  - Icon: 16x16px, color Secondary Text
  - Divider: 1px solid Border at 20% opacity, margin 8px vertical
- **Content Layout**:
  - Title: Bold, 12pt, margin bottom 4px
  - Body: Regular, 11pt
  - Metrics: Label (Secondary Text) + Value (Primary Text) on same line, space-between
- **Power BI Implementation**:
  - Create a Tooltip page (View -> Tooltip page)
  - Set page size: Tooltip (320x240 is default, but we can customize)
  - Design using shapes, text boxes, and images
  - Ensure no interactive elements (tooltips should not be clickable)
  - Assign to visual via visual's Tooltip field
- **Usage**: 
  - Assign to all charts and key data points for detail-on-demand
  - Keep concise; avoid large tables in tooltips
  - Follow the tooltip-specification.md for detailed guidance

## 4. Navigation

### 4.1 Nav Ribbon
**Purpose**: Primary navigation between report pages.
- **Location**: Left vertical strip
- **Variants**:
  - **Collapsed**: Icon only, width 64px (16 units)
  - **Expanded**: Icon + Text label, width 240px (60 units)
- **Properties**:
  - Background: Navigation Background (#0B1120)
  - Divider: 1px solid Border (#243044) between items (optional)
  - Item Height: 48px (12 units) for touch target
  - Icon Size: 20x20px (5 units)
  - Icon Margin: Horizontal 12px (3 units) from left edge, 12px between icon and text
  - Text: Segoe UI, Medium (500), 12pt
  - Text Color: 
    - Icon Only: Secondary Text (#94A3B8)
    - Icon + Text, Normal: Secondary Text
    - Icon + Text, Active: Primary Text (#F8FAFC)
    - Icon + Text, Hover: Primary Text (in both states)
  - Selected Indicator: 
    - Optional: 4px width bar on left, color Primary Violet (#7C3AED)
    - Or: Change icon/text color as above
  - Logo Area: Top 64px (16 units) of nav, full width
- **States**:
  - Default: As above
  - Hover: Background: Nav Hover (#13182A) - slight lift
  - Selected: As defined
  - Disabled: Opacity 0.4
- **Power BI Implementation**:
  - Use Bookmarks and Buttons or Shapes for each nav item.
  - Group: 
    - Background rectangle (size: nav width x item height)
    - Icon (image or shape)
    - Text label (text box)
  - Set each group to have:
    - No fill (transparent)
    - On select: Change fill color (for hover/selected states) via bookmarks
    - Add action: Page navigation
  - For collapsed/expanded toggle: Use a button that changes the width of the nav container and visibility of text labels via bookmarks.
  - Alternative: Use custom navigation menu visual from AppSource if it meets specs.
- **Usage**:
  - Always present; consistent across all pages
  - Order: Logo at top, then pages in logical order, then utility buttons (e.g., help, settings) at bottom
  - Limit to 5-7 primary items; use submenus if needed (though avoid deep nesting in reports)

### 4.2 Breadcrumb
**Purpose**: Show hierarchical location (less common in flat report structure).
- **Properties**:
  - Font: Segoe UI, Regular (400), 10pt
  - Separator: ">" or "/", size 10pt, color Secondary Text
  - Link Color: Primary Text for current, Secondary Text for ancestors
  - Hover: Underline or color change to Primary Violet
  - Margin: 8px vertical (2 units) from surrounding content
- **Power BI Implementation**:
  - Use a Text box with manually entered separators and links (via bookmarks for each segment).
  - Or use a custom visual.
- **Usage**: 
  - Only if using hierarchical drillthrough pages beyond one level
  - For our flat structure with one drillthrough level, not typically needed

### 4.3 Back Button
**Purpose**: Return to previous view or state.
- **Properties**:
  - Type: Icon button
  - Icon: Chevron left (20x20px)
  - Size: 32x32px (8 units)
  - Background: Transparent
  - Icon Color: Primary Text (#F8FAFC)
  - Hover Background: Primary Violet at 10% opacity
- **Power BI Implementation**:
  - Shape (circle or rounded rect) with transparency
  - Overlay SVG icon
  - Set action: Back (via bookmark "Back" or previous page)
- **Usage**:
  - Place in header of drillthrough pages
  - Always label with tooltip "Go back"
  - Ensure consistent placement (top-left of content area, after nav if collapsed)

## 5. Feedback

### 5.1 Alert / Banner
**Purpose**: Show system status or message.
- **Variants**:
  - **Info**: Background: Info (#06B6D4) at 10% opacity, Border: 1px solid Info, Text: Info
  - **Success**: Background: Success (#22C55E) at 10% opacity, Border: 1px solid Success, Text: Success
  - **Warning**: Background: Warning (#F59E0B) at 10% opacity, Border: 1px solid Warning, Text: Warning
  - **Error**: Background: Negative (#EF4444) at 10% opacity, Border: 1px solid Error, Text: Error
- **Properties**:
  - Padding: 12px (3 units) all sides
  - Border Radius: 6px
  - Font: Segoe UI, Regular (400), 12pt
  - Icon: 16x16px (4 units) leading, margin right 8px (2 units)
  - Max Width: 100% of container
  - Dense Variant: Reduce padding to 8px vertical, 12px horizontal for inline use
- **States**:
  - Dismissible: Show close icon (X) in top corner, 20x20px, color Text at 60% opacity
  - Animation: Slide-in/fade-out (simulate with appearance/disappearance via bookmarks if needed)
- **Power BI Implementation**:
  - Use a combination of shapes (background) and text box/icon group.
  - For dismissibility, use bookmarks to hide the group.
  - Place at top of page (below header) or inline with relevant content.
- **Usage**:
  - Use sparingly for transient messages
  - Avoid blocking critical information
  - Ensure accessibility: provide alternative way to dismiss (e.g., timeout)

### 5.2 Loading State
**Purpose**: Indicate data is being retrieved.
- **Properties**:
  - Type: Skeleton loader or spinner
  - Spinner Size: 24px (6 units) diameter
  - Spinner Color: Primary Violet (#7C3AED)
  - Skeleton Height: 16px (4 units) for lines, varies for text
  - Skeleton Background: Background (#111827) at 30% opacity
  - Skeleton Accent: Background at 50% opacity
- **Power BI Implementation**:
  - For entire report: Use a full-page shape with animation (limited) or accept default loading behavior.
  - For specific visuals: Create a placeholder group of shapes that mimic the layout.
  - Best practice: Rely on Power BI's inherent loading indicators and supplement with a custom message if delay is expected.
- **Usage**:
  - Show when query time > 1 second
  - Message: "Loading data..." or similar

### 5.3 Empty State
**Purpose**: Show when no data matches filters.
- **Properties**:
  - Illustration: Optional, 128x128px (32 units) max
  - Title: SemiBold (600), 16pt, Primary Text
  - Body: Regular (400), 12pt, Secondary Text
  - Action Button: Primary Button (if actionable)
  - Text Align: Center
  - Padding: 24px (6 units) all sides
- **Power BI Implementation**:
  - Use a group of shapes, text, and button (with bookmarks for button action).
  - Set visibility based on a measure: `IF(COUNTROWS(FactTransactions)=0, TRUE(), FALSE())`
- **Usage**:
  - Always provide a clear message and next step (if applicable)
  - Avoid leaving blank area

## 6. Overlays

### 6.1 Modal / Dialog
**Purpose**: Temporary UI for focused task or critical message.
- **Properties**:
  - Background: Overlay (rgba(0,0,0,0.5)) - dims background
  - Container: 
    - Width: 400px (100 units) max, max-height: 80% of viewport
    - Background: Card Background (#111827)
    - Border Radius: 8px
    - Padding: 24px (6 units) all sides
    - Shadow: 0px 8px 24px rgba(0,0,0,0.2)
  - Header: 
    - Title: SemiBold (600), 18pt, Primary Text
    - Divider: 1px solid Border at 20% opacity, margin 16px vertical
  - Body: 
    - Text: Regular (400), 12-14pt, Primary Text
    - Spacing: 16px (4 units) between sections
  - Footer: 
    - Buttons: Right-aligned, spacing 12px (3 units) between
  - Close Button (optional): Top-right, 24x24px icon, color Secondary Text at 60% opacity
- **States**:
  - Open: Fade-in and scale-up (simulate via appearance)
  - Close: Fade-out and scale-down
- **Power BI Implementation**:
  - True modals are not natively supported. Use bookmarks to show/hide a group that covers the canvas.
  - Approach:
    1. Create a group: 
       - Full-page rectangle: fill black at 50% opacity
       - Centered rectangle: dialog container
    2. Use a bookmark to toggle visibility of this group.
    3. Place interactive elements (buttons) inside with actions to hide the group.
  - Ensure underlying page is not interactable by covering it with the overlay (the black rectangle).
- **Usage**:
  - Use only for critical interruptions (e.g., unsaved changes warning)
  - Prefer inline validation and non-blocking patterns where possible
  - Ensure escape key behavior (if possible via bookmarks) or clear close button

### 6.2 Tooltip (already covered in 3.5)
**Note**: Tooltips are a type of overlay but covered separately due to their prevalence and specific spec.

## 7. Icons and Illustrations

### 7.1 Icon Style
- **Stroke Width**: 2px (consistent)
- **Corner Radius**: 2px on rounded corners (if applicable)
- **Style**: Outline (stroke) with optional fill for semantic meaning (e.g., success icon filled green)
- **Size**: 
  - Small: 16x16px (4 units)
  - Medium: 20x20px (5 units) - nav icons, button icons
  - Large: 24x24px (6 units) - header actions
- **Color**: 
  - Default: Secondary Text (#94A3B8)
  - Active/Selected: Primary Text (#F8FAFC) or Semantic color (e.g., success icon green)
  - Disabled: Opacity 0.4
- **Consistency**: Use the same icon set throughout (we will create custom SVGs)

### 7.2 Illustration Style
- **Use Sparingly**: Only for empty states or welcome screens
- **Style**: 
  - Line art with single accent color (Primary Violet #7C3AED)
  - Stroke width: 2px
  - No fill, or flat fill with opacity
  - Perspective: Isometric or flat perspective
- **Implementation**: Use SVG images added via Image visual or static resource.

## Power BI Specific Implementation Notes

### General
1. **Performance**: Avoid excessive use of shapes and images; they can slow down rendering.
2. **Layering**: Use Selection pane to manage z-order and naming.
3. **Consistency**: Copy formatting using the format painter or by duplicating configured objects.
4. **Naming**: Use clear names in Selection pane (e.g., "Header - Title", "Nav - Home Button") for maintainability.
5. **Alignment**: Use Align and Distribute tools in the Format pane when multiple objects are selected.
6. **Grouping**: Group related objects that move together (e.g., a KPI card's value, label, and indicator).

### Limitations and Workarounds
- **True Hover Effects**: Limited to visuals that support them (charts, slicers). For shapes, use bookmarks to simulate hover (complex).
- **Custom Fonts**: Segoe UI is generally available on Windows; ensure it's embedded if publishing to service (usually is).
- **SVG as Shapes**: Power BI does not directly support SVG as a shape; use PNG or convert SVG to shape via external tool (not ideal). Alternative: Use Image visual and link to the SVG file (requires the file to be accessible; better to embed as base64? Not supported). For distribution, we may need to use PNG exports of SVGs, but provide SVGs for editing.
  - **Solution**: Store SVGs in the repository and instruct the developer to convert them to PNG or use a custom visual that supports SVG (like HTML viewer) - but for simplicity, we'll assume the developer can use the SVG as an image if the environment allows, or we provide PNG fallbacks.
  - Given the instructions to create editable SVG files, we'll provide SVGs and note that they may need to be converted or used via an image visual.

### Ensuring Consistency
- Create a template .pbix with all core components pre-built and styled.
- Use the Selection pane to lock master copies.
- Duplicate from master instances rather than recreating.

## Component Specifications Summary Table

| Component | States | Key Props | Power BI Approach |
|-----------|--------|-----------|-------------------|
| Page Container | Default | Background, Margin | Page Settings |
| Surface | Default, Hover, Disabled | bg, border, radius, padding, shadow | Shapes + visual bg/border |
| Button | Default, Hover, Pressed, Disabled | bg, text, border, radius, size, icon | Shape + text + icon + bookmarks |
| KPI Indicator | Default | value font, label font, indicator color | Card visual + conditional shape + text + conditional elements |
| Slicer | Default, Hover, Selected, Disabled | bg, text, selected bg, item height | Slicer visual format |
| Chart Container | Default, Loading, Error, Empty | bg, border, radius, padding, title | Shape container + visual |
| Table | Default, Hover Row, Selected Row | header bg, row bg, text, grid lines | Table/Matrix visual + conditional formatting |
| Tooltip | Default | bg, border, radius, padding, shadow, text size | Tooltip page |
| Nav Ribbon | Default, Hover, Selected, Disabled | bg, icon, text, selected color, divider | Group of shapes + bookmarks |
| Alert | Default, Dismissible | bg, border, radius, padding, icon, text | Shape group + conditional visibility |
| Modal | Open, Closed | overlay bg, container bg, radius, padding, shadow | Overlay group + bookmarks |

## References

- Atlassian Design System: https://design.atlassian.com/
- Microsoft Fluent UI: https://microsoft.github.io/fluentui/
- Power BI Design Guidelines: https://learn.microsoft.com/power-bi/create-reports/desktop-service-design
- Data Visualization Catalogue: https://datavizcatalogue.com/
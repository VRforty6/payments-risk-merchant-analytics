# Merchant Risk Analysis Specification

## Purpose
Examine merchant‑level risk distribution and thresholds to identify high‑risk merchants, monitor risk trends, and evaluate exposure to refund and chargeback risks.

## Page Layout
Follow the Master Layout Specification with:
- KPI row (4 cards) below header
- Left‑aligned vertical slicer pane (optional) for filters
- Three visual regions: donut chart, scatter plot, and small‑multiples line chart
- Footer optional

## Components

### KPI Row (Top Row)
| # | KPI | Measure | Format | Label |
|---|-----|---------|--------|-------|
| 1 | Active Merchants | `[Active Merchants]` | Integer | “Active Merchants” |
| 2 | High Risk Merchants | `[High Risk Merchants]` | Integer | “High Risk Merchants” |
| 3 | Merchant Risk Tier Index | `[Merchant Risk Tier Index]` | Decimal 1 | “Risk Tier Index” |
| 4 | Approval Rate (Merchant Avg) | `[Approval Rate]` | Percentage (2 dp) | “Approval Rate” |

**Card Styling**: Same as Executive Overview KPI cards.

### Visual 1 – Merchant Risk Tier Distribution (Donut Chart)
- **Title**: “Merchant Count by Risk Tier”
- **Type**: Donut chart
- **Legend**: `DimMerchant[RiskTier]` (Low, Medium, High)
- **Values**: Count of `DimMerchant[MerchantKey]` (distinct)
- **Colors**: 
  - Low: `#22C55E` (Positive)
  - Medium: `#F59E0B` (Warning)
  - High: `#EF4444` (Negative)
- **Details**: Show percentage and value
- **Tooltip**: Show Risk Tier, Merchant Count, and percentage of total
- **Slicer Interaction**: Date slicer (if showing trends over time) and Merchant Category slicer filter this visual
- **Cross‑Filtering**: 
  - Clicking a slice filters other visuals to that risk tier
- **Drillthrough**: 
  - From a slice → Drillthrough to Transaction Diagnostics page (passing the selected `DimMerchant[RiskTier]`)
- **Position**: Left third of the visual area (columns 1‑4 in a 12‑column grid)

### Visual 2 – Refund & Chargeback Ratio vs Threshold (Scatter Plot)
- **Title**: “Refund & Chargeback Ratio per Merchant”
- **Type**: Scatter chart
- **X-Axis**: `[Refund Ratio]` (format: Percentage 2 dp)
- **Y-Axis**: `[Chargeback Ratio]` (format: Percentage 2 dp)
- **Details**: `DimMerchant[MerchantDisplayName]`
- **Color Saturation**: `[Merchant Risk Tier Index]` (gradient from `#22C55E` (low) to `#EF4444` (high))
- **Size**: `[Total Transactions]` (log scale recommended)
- **Constant Lines**: 
  - X = Merchant Refund Threshold (0.02) – dashed line, color `#F59E0B`
  - Y = Merchant Chargeback Threshold (0.01) – dashed line, color `#F59E0B`
- **Tooltip**: Show Merchant Name, Refund Ratio, Chargeback Ratio, Total Transactions, Active? (Yes/No based on having transactions in period)
- **Slicer Interaction**: Date range, Merchant Category, and Payment Method slicers filter this visual
- **Cross‑Filtering**: 
  - Clicking a point filters other visuals to that merchant
- **Drillthrough**: 
  - From a point → Drillthrough to Merchant Drillthrough page (passing `DimMerchant[MerchantKey]`)
- **Position**: Middle third of the visual area (columns 5‑8)

### Visual 3 – Merchant Trend (Line Chart, Small Multiples)
- **Title**: “Daily Approval Rate Trend per Merchant (Top 5 by Volume)”
- **Type**: Line chart
- **X-Axis**: `DimDate[DateDate]`
- **Y-Axis**: `[Approval Rate]` (calculated as measure)
- **Legend**: `DimMerchant[MerchantDisplayName]` (limited to top 5 by `Total Transactions` via visual‑level filter)
- **Show data labels**: Off
- **Tooltip**: Show Merchant Name, Date, Approval Rate, Transaction Value
- **Slicer Interaction**: Date range slicer filters this visual; Merchant Risk Tier and Category slicers also apply
- **Cross‑Filtering**: 
  - Clicking a line highlights that merchant and filters other visuals to that merchant
  - Other visuals can filter this visual (e.g., selecting a date range filters the trend lines)
- **Drillthrough**: 
  - From a point on a line → Drillthrough to Merchant Drillthrough page (passing `DimMerchant[MerchantKey]` and `DimDate[DateDate]` if supported)
- **Position**: Right third of the visual area (columns 9‑12)

## Filters (Page Level)
- **Date Slicer**: Relative (default “Last 60 days”), placed in header or left sidebar
- **Merchant Risk Tier**: Checkboxes (Low, Medium, High), multi‑select, default all
- **Merchant Category**: Dropdown (from `DimMerchant[MerchantCategory]`), single or multi‑select
- **Payment Method**: Dropdown (optional, if relevant to risk analysis)
- **Note**: Use sync slicers for cross‑page consistency where applicable

## Drillthrough Interactions
- **From Visual 1 (Donut)**: Selecting a risk tier slice → Drillthrough to Transaction Diagnostics page, filtering to that risk tier
- **From Visual 2 (Scatter)**: Selecting a point → Drillthrough to Merchant Drillthrough page, filtering to that merchant
- **From Visual 3 (Line Chart)**: Selecting a point → Drillthrough to Merchant Drillthrough page, filtering to that merchant and optionally the date

## Tooltip Page
- Assign a tooltip page to Visual 2 (Scatter) and Visual 3 (Line) that shows:
  - Merchant ID, Name, Category, Risk Tier
  - KPI cards: Total Transactions, Approval Rate, Refund %, Chargeback %, Avg Tx Value
  - Mini bar chart of daily tx volume (last 14 days)
- Name the tooltip page: “Merchant Detail Tooltip”
- Size: Tooltip (320 × 240)
- Design per `specifications/tooltip-specification.md`

## Conditional Formatting
- **Scatter point color**: As described (risk score gradient)
- **Donut slice colors**: As defined above
- **KPI Cards**: 
  - Approval Rate KPI: Green/Amber/Red thresholds (≥0.95, 0.90‑0.94, <0.90) using Positive/Warning/Negative colors
  - Merchant Risk Tier Index: Could use a similar scale if desired (e.g., ≤1.5 Low, 1.5‑2.5 Medium, >2.5 High) but typically left as raw score

## Cross‑Filtering Behavior
- Enable bidirectional filtering between the donut chart and scatter plot where logical (e.g., selecting a risk tier highlights merchants of that tier in the scatter)
- Between the line chart and other visuals, filtering is typically from the line chart to others (click a merchant line to see its risk profile) and from others to the line chart (select a merchant in scatter to see its trend)

## Accessibility
- Ensure color combinations meet contrast ratios (verify scatter plot colors against background)
- Provide clear legends and tooltips
- Avoid relying solely on color for the scatter plot; size and position also convey information

## Performance Considerations
- The scatter plot may become heavy with many merchants; consider aggregating to weekly or monthly if real‑time per‑merchant detail is not required
- The line chart is limited to top 5 merchants, which controls cardinality

## Build Steps (Summary)
1. Apply theme and set page size
2. Ensure required measures exist (refer to `dax/dax-measures.md`)
3. Build KPI row with four Card visuals
4. Create Donut chart for risk tier distribution
5. Create Scatter plot with dual encoding (color and size)
6. Create Line chart with legend limited to top 5 merchants by volume
7. Add slicers to header or left sidebar and configure sync
8. Set up cross‑filtering and drillthrough as specified
9. Apply conditional formatting to KPI cards and scatter plot
10. Assign tooltip panels to scatter and line charts
11. Test interactions and visual hierarchy
12. Validate layout against the grid using Snap to grid
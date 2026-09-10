# Executive Overview Specification

## Purpose
High--level health snapshot of the payments ecosystem-- of the payments health---## Purpose
The purpose-executive overview of the Executive Overview page is to provide a single‑glance snapshot of the overall health and performance of the payments ecosystem, focusing on volume, value, approval rates, and processing revenue.

## Page Layout
Follow the Master Layout Specification with:
- KPI row (6 cards) directly below the header
- Three visual regions below the KPI row: two charts on the left (spanning 6 columns each in a 12‑column grid) and one chart on the right (spanning the remaining 6 columns), or an alternative layout as specified below
- Footer optional

## Components

### KPI Row (Top Row)
| # | KPI | Measure | Display Units | Label |
|---|-----|---------|---------------|-------|
| 1 | Total Transactions | `[Total Transactions]` | None | “Total Transactions” |
| 2 | Approval Rate | `[Approval Rate]` | Percentage (2 dp) | “Approval Rate”Approval Rate” |
| 3 | Transaction Value | `[Transaction Value]` | Millions (M) | “Transaction Value” |
| 4 | Processing Revenue | `[Processing Revenue]` | Thousands (K) | “Processing Revenue” | 
| 5 | Refund Ratio | `[Refund Ratio]` | Percentage (2 dp) | “Refund Ratio” |
| 6 | Chargeback Ratio | `[Chargeback Ratio]` | Percentage (2 dp) | “Chargeback Ratio” |

**Card Styling** (see Component Library: KPI Indicator):
- Background: Card Background (`#111827`)
- Border: 1px solid Border (`#243044`)
- Border Radius: 8px
- Padding: 16px internal
- Value Font: Segoe UI, Bold (700), size 24‑28pt, color: Primary Text (`#F8FAFC`) or Accent for emphasis
- Label Font: Segoe UI, Regular (400), size 10‑12pt, color: Secondary Text (`#94A3B8`)
- Optional Indicator: None for these KPIs (trend indicators can be added via small sparklines if desired, but not required)

### Visual 1 – Transaction Trend (Line Chart)
- **Title**: “Daily Transaction Volume & Approval Rate”
- **Type**: Line chart with dual axis
- **Left Axis (Primary)**: Transaction Value (sum of `FactTransactions[TransactionAmount]`)
  - Color: Accent Blue (`#3B82F6`)
  - Line: Solid
- **Right Axis (Secondary)**: Approval Rate (calculated as `[Approved Transactions] / [Total Transactions]`)
  - Color: Positive (`#22C55E`)
  - Line: Solid, dashed is acceptable for distinction
- **X-Axis**: `DimDate[DateDate]` (continuous, date hierarchy)
- **Legend**: Show (two series: “Transaction Value”, “Approval Rate”)
- **Data Labels**: Off
- **Gridlines**:
  - Vertical: None (or very light at 10% opacity)
  - Horizontal: Left axis: 20% opacity Border color; Right axis: 20% opacity Border color
- **Tooltip**: Show Transaction Value (formatted as currency), Approval Rate (percentage), and Total Transactions (count)
- **Slicer Interaction**: Date range slicer (see Filters below) filters this visual
- **Cross‑Filtering**: 
  - Clicking a point on the line filters other visuals to that date
  - Other visuals can filter this visual (e.g., selecting a merchant filters the trend to that merchant)
- **Drillthrough**: 
  - From a data point → Drillthrough to Transaction Diagnostics page (passing `DimDate[DateDate]`)
- **Position**:
  - Option A (2‑column grid): Occupies left 6 columns (Columns 1‑6) of the grid, starting after left margin and gutter
  - Option B (full‑width): Spans full content width above Visual 2 and 3, with Visual 2 and 3 side‑by‑side below
  - Refer to the layout grid in Master Layout Specification for exact X,Y based on chosen option

### Visual 2 – Approval vs Decline by Region (Stacked Column Chart)
- **Title**: “Approval/Decline Split by Region”
- **Type**: Stacked column chart
- **X-Axis**: `DimGeography[Region]`
- **Y-Axis**: Count of `FactTransactions` (or Sum of Transaction Value – specify which; count is preferred for split)
- **Legend**: `DimTransactionStatus[IsApproved]` mapped to “Approved” / “Declined”
  - Approved Color: Positive (`#22C55E`)
  - Declined Color: Negative (`#EF4444`)
- **Sort**: Descending by total height (Total Transactions per region)
- **Data Labels**: Show as percentage of stack (optional) or total count
- **Tooltip**: Show Region, Approved Count, Declined Count, Total Count, Approval Rate (for the region)
- **Slicer Interaction**: Date range and Merchant Risk Tier slicers filter this visual
- **Cross‑Filtering**: 
  - Clicking a column filters other visuals to that region
  - Other visuals can filter this visual (e.g., selecting a date range filters the stacked columns)
- **Drillthrough**: 
  - From a column segment → Drillthrough to Transaction Diagnostics page (passing the selected `DimGeography[Region]`)
- **Position**:
  - If using Option A above: Occupies right 6 columns (Columns 7‑12), top half of the lower section
  - If using Option B: Bottom‑left quadrant

### Visual 3 – Top 10 Merchants by Transaction Value (Bar Chart)
- **Title**: “Top 10 Merchants – Transaction Value”
- **Type**: Horizontal bar chart
- **Y-Axis**: `DimMerchant[MerchantDisplayName]` (display name)
- **X-Axis**: Sum of `FactTransactions[TransactionAmount]`
- **Bar Color**: Single color, e.g., Indigo (`#4F46E5`) or use gradient by value (light to dark Indigo)
- **Sort**: Descending by Transaction Value, limited to top 10 via visual‑level filter (Top N)
- **Data Labels**: Show value in Millions (M) on the end of each bar
- **Tooltip**: Show Merchant Name, Transaction Value (formatted), Transaction Count, Approval Rate
- **Slicer Interaction**: Date range, Merchant Risk Tier, Payment Method slicers filter this visual
- **Cross‑Filtering**:
  - Clicking a bar filters other visuals to that merchant (via `DimMerchant[MerchantKey]`)
  - Other visuals can filter this visual (e.g., selecting a region filters the top‑10 list to merchants in that region)
- **Drillthrough**: 
  - From a bar → Drillthrough to Merchant Drillthrough page (passing `DimMerchant[MerchantKey]`)
- **Position**:
  - If using Option A above: Occupies right 6 columns (Columns 7‑12), bottom half of the lower section
  - If using Option B: Bottom‑right quadrant

## Filters (Page Level)
- **Relative Date Slicer** (horizontal or dropdown, placed in header):
  - Default: “Last 30 days”
  - Options: “Last 7 days”, “Last 30 days”, “Last 90 days”, “Year to date”, “All time”
  - Type: Relative date slicer (allows dynamic rolling windows)
- **Merchant Risk Tier** (checkboxes, placed in header or left sidebar if preferred):
  - Options: Low, Medium, High
  - Multi‑select enabled
  - Default: All selected
- **Payment Method** (dropdown, placed in header):
  - Single select (or multi‑select if deemed useful)
  - Options: All distinct values from `DimPaymentMethod[PaymentMethod]`
  - Default: “All” (no selection)
- **Note**: All slicers should sync across pages where applicable (use Sync Slicers feature)

## Drillthrough Interactions
- **From Visual 1 (Trend Chart)**:
  - Selecting a date point → Drillthrough to Transaction Diagnostics page, filtering to that date
- **From Visual 2 (Stacked Column)**:
  - Selecting a column segment → Drillthrough to Transaction Diagnostics page, filtering to that region
- **From Visual 3 (Top‑10 Merchants Bar)**:
  - Selecting a bar → Drillthrough to Merchant Drillthrough page, filtering to that merchant

## Tooltip Page
- Assign a tooltip page to Visual 3 (Top‑10 Merchants) that shows:
  - Merchant Name
  - Total Transactions, Approval Rate, Refund Ratio, Chargeback Ratio
  - Mini sparkline of daily transaction value (last 30 days)
- Name the tooltip page: “Merchant Tooltip”
- Size: Tooltip (320 × 240)
- Design per `specifications/tooltip-specification.md`

## Conditional Formatting
- **Approval Rate KPI Card**:
  - Green (≥ 0.95): Use Positive color (`#22C55E`)
  - Amber (0.90‑0.94): Use Warning color (`#F59E0B`)
  - Red (< 0.90): Use Negative color (`#EF4444`)
  - Apply via Font Color or Background Color conditional formatting on the value
- **Transaction Value Line** (in Visual 1):
  - Color by value: Gradient from `#3B82F6` (low) to `#7C3AED` (high)
  - Implement via the “Color by value” option in the line visual’s data colors

## Cross‑Filtering Behavior
- Enable bidirectional cross‑filtering between visuals where it makes sense (e.g., between the trend chart and the regional split) unless it causes performance ambiguity.
- For visuals that could produce many‑to‑many relationships (e.g., merchant to date), consider single direction from the fact table to dimensions.

## Accessibility
- Ensure all text meets contrast ratios (see `implementation-rules.md` IR-42)
- Provide clear alt text for images via the Title field in visual properties
- Avoid using color alone to convey information; always include labels or patterns

## Performance Considerations
- Limit the number of data points in the trend chart by aggregating to daily granularity (already at day level via `DimDate[DateDate]`)
- Use summarization where appropriate (e.g., do not display raw transaction IDs in visuals)
- Test refresh performance with the full dataset

## Build Steps (Summary)
1. Apply theme applied, page size set
2. Import required tables and ensure relationships are active
3. Create measures if not already present (refer to `dax/dax-measures.md`)
4. Build the KPI row using Card visuals, arrange in a row with equal spacing
5. Build Visual 1 as a Line chart with dual axis, set colors and tooltips
6. Build Visual 2 as a Stacked column chart, set colors, sorting, and tooltips
7. Build Visual 3 as a Bar chart, set sorting, data labels, tooltips, and Top N filter
8. Add slicers to the header (or left sidebar) and sync across pages
9. Configure cross‑filtering and drillthrough as specified
10. Add conditional formatting to KPI cards and line chart
11. Assign tooltip page to Visual 3
12. Test interactivity and visual hierarchy
13. Validate against the master layout grid using Snap to grid
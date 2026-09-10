# Merchant Drillthrough Specification

## Purpose
Show all relevant metrics for a selected merchant (passed from other pages via drillthrough) to enable deep‑dive analysis of a specific merchant’s performance, risk profile, and transaction patterns.

## Page Type
- **Drillthrough page**: Automatically filters to the selected merchant based on the field(s) passed in the drillthrough configuration.
- **Title**: “Merchant Detail – ” & SELECTEDVALUE(DimMerchant[MerchantDisplayName]) (or similar dynamic title)

## Driftrough Configuration
- **Target Page**: This page
- **Drillthrough Fields**: 
  - Primary: `DimMerchant[MerchantKey]` (integer key)
  - Optional (for display or additional filtering): `DimMerchant[MerchantDisplayName]`, `DimMerchant[RiskTier]`, `DimGeography[Region]` (if passed from a geographic visual)
- **Setting**: In the Merchant Drillthrough page properties, add `DimMerchant[MerchantKey]` to the Drillthrough filters well.
- **Keep all filters**: Enable this option so that slicers and filters from the source page are retained (where applicable) to provide context.

## Page Layout
Follow the Master Layout Specification with:
- Two‑column layout: left column (≈30% width) for KPIs, right column (≈70% width) for visuals
- Header (optional) may show the merchant name and a back button
- No KPI row at the top; instead, KPIs are in the left column
- Footer optional

## Components

### Left Column (KPI Column)
- **Width**: Approximately 380px (3‑4 columns in a 12‑column grid, depending on gutter)
- **Padding**: 20px internal (to match chart container padding)
- **Background**: Card Background (`#111827`) or transparent; use a container shape if desired
- **Border Radius**: 8px
- **Margin**: 24px from top, bottom, and right (to separate from right column)

#### KPI List (Vertical Stack)
Display the following KPIs as individual cards (use the KPI Indicator component from the Component Library, but without trend indicators unless desired). Each KPI should be a separate card with a label and value.

| # | KPI | Measure | Format | Label | Conditional Formatting (if any) |
|---|-----|---------|--------|-------|---------------------------------|
| 1 | Total Transactions | `[Total Transactions]` | Integer | “Total Tx” | None |
| 2 | Approved Transactions | `[Approved Transactions]` | Integer | “Approved Tx” | None |
| 3 | Declined Transactions | `[Declined Transactions]` | Integer | “Declined Tx” | None |
| 4 | Transaction Value | `[Transaction Value]` | Currency (2 dp) | “Tx Value” | None |
| 5 | Approval Rate | `[Approval Rate]` | Percentage (2 dp) | “Approval Rate” | Red (<0.90), Amber (0.90‑0.94), Green (≥0.95) |
| 6 | Refund Ratio | `[Refund Ratio]` | Percentage (2 dp) | “Refund Ratio” | Red if > Refund Threshold (e.g., 0.02) |
| 7 | Chargeback Ratio | `[Chargeback Ratio]` | Percentage (2 dp) | “Chargeback Ratio” | Red if > Chargeback Threshold (e.g., 0.01) |
| 8 | Average Transaction Value | `[Average Transaction Value]` | Currency (2 dp) | “Avg Tx Value” | None |
| 9 | Active Days | Distinct count of dates with transactions for the merchant | Integer | “Active Days” | None |
|10 | Last Transaction Date | `[Last Transaction Date]` | Date | “Last Tx Date” | None |

**Styling for KPI Cards in Column**:
- Use a consistent card design: 
  - Background: Card Background (`#111827`)
  - Border: 1px solid Border (`#243044`)
  - Border Radius: 8px
  - Padding: 12px internal (slightly less than chart container padding to fit more in column)
  - Margin Bottom: 12px between cards (vertical spacing)
- **Value Font**: Segoe UI, SemiBold (600), size 14‑16pt, color: Primary Text (`#F8FAFC`) or apply conditional formatting as above
- **Label Font**: Segoe UI, Regular (400), size 10‑12pt, color: Secondary Text (`#94A3B8`)
- **Alternative**: Use a multi‑line Card visual that shows label and value together (requires custom design) or use two separate text boxes per KPI grouped together.

### Right Column (Visual Column)
- **Width**: Remaining width (approximately 860px)
- **Padding**: 20px internal
- **Background**: Card Background (`#111827`) or transparent
- **Border Radius**: 8px
- **Margin**: 24px from top, bottom, and left

#### Visual 1 – Daily Transaction Trend (Line Chart)
- **Title**: “Daily Transaction Volume”
- **Type**: Line chart
- **X‑Axis**: `DimDate[DateDate]` (continuous)
- **Y‑Axis (Left)**: Sum of `FactTransactions[TransactionAmount]` (Transaction Value)
  - Line Color: Accent Blue (`#3B82F6`)
- **Y‑Axis (Right)**: Approval Rate (calculated as `[Approved Transactions] / [Total Transactions]`)
  - Line Color: Positive (`#22C55E`)
- **Legend**: Show both series
- **Tooltip**: Show Date, Transaction Value (formatted), Approval Rate (percentage), and Transaction Count
- **Slicer Interaction**: Date range slicer (if added to page) filters this visual; note that the drillthrough context already fixes the merchant, so date slicer allows temporal analysis within the merchant’s data
- **Cross‑Filtering**: 
  - Since this is a drillthrough page, cross‑filtering to other pages is possible but less common; typically, we allow filtering within the page (e.g., date slicer) and let the visuals respond to each other
  - Enable bidirectional filtering between the line chart and other visuals on this page if desired (e.g., selecting a point in the line chart filters the pie chart below to that date)
- **Drillthrough Out**: 
  - From a data point → Drillthrough to Transaction Diagnostics page (passing `DimDate[DateDate]` and `DimMerchant[MerchantKey]` to see transaction details for that day and merchant)
- **Position**: Top half of the right column (occupies ~60% of vertical space)

#### Visual 2 – Payment Method Mix (Donut Chart)
- **Title**: “Payment Method Usage”
- **Type**: Donut chart
- **Legend**: `DimPaymentMethod[PaymentMethod]`
- **Values**: Count of `FactTransactions` (or Sum of Transaction Amount – count is more common for mix)
- **Colors**: Use the theme’s `dataColors` in order
- **Tooltip**: Show Payment Method, Count, and Percentage of total
- **Slicer Interaction**: Date range slicer filters this visual
- **Clockwise**: Starting at top (12 o’clock) is conventional
- **Center Hole Size**: 50% (standard donut)
- **Data Labels**: Show percentage on each slice (optional) or rely on tooltip
- **Drillthrough Out**: 
  - From a slice → Drillthrough to Transaction Diagnostics page (passing the selected `PaymentMethod` and `DimMerchant[MerchantKey]` for that method’s transactions)
- **Position**: Bottom‑left quadrant of the right column (if Visual 1 is top half)

#### Visual 3 – Geographic Distribution (Map)
- **Title**: “Transaction Locations”
- **Type**: Map (bubble map)
- **Location**: `DimGeography[City]` (or `Country` if city not available; prefer city for dispersion)
- **Values**: 
  - Size: Sum of `FactTransactions[TransactionAmount]` (bubble size)
  - Color: Approval status (two colors)
    - Approved: Positive (`#22C55E`)
    - Declined: Negative (`#EF4444`)
- **Tooltip**: Show City, Transaction Count, Transaction Value, Approval Rate
- **Slicer Interaction**: Date range slicer filters this visual
- **Drillthrough Out**: 
  - From a bubble → Drillthrough to Transaction Diagnostics page (passing the selected `DimGeography[City]` and `DimMerchant[MerchantKey]` for transactions in that location)
- **Position**: Bottom‑right quadrant of the right column

### Footer (Optional)
- **Back Button**: 
  - Place in the top‑left corner of the page (or in the header) to return to the previous page
  - Use the Back button icon from `/assets/controls/back.svg`
  - Set action: “Back” (Power BI automatically generates a back bookmark when drillthrough is used)
  - Tooltip: “Go back to previous view”
- **Page Number / Timestamp**: 
  - Optional: Show “Page 1 of 1” or last refresh time

## Filters (Page Level)
- **Date Range Slicer**: 
  - Optional: Allow the analyst to change the date range while staying within the merchant context
  - Default: “Last 90 days” or “All time”
  - Type: Relative date or dropdown
  - Position: Top‑right of the page (above the visual column) or in a header area
- **Note**: Since this is a drillthrough page, the primary filter is the merchant. Additional slicers should be clearly scoped to “within this merchant” to avoid confusion.

## Tooltip Page
- Re‑use the “Transaction Tooltip” from the Transaction Diagnostics page (or create a variant) that shows:
  - Transaction ID, Timestamp, Amount, Currency
  - Merchant Name (though fixed on this page, still useful for context)
  - Customer ID
  - Approval status, Decline Reason (if any)
  - Refund & Chargeback flags & amounts
- Name: “Transaction Tooltip”
- Size: Tooltip (320 × 240)
- Design per `specifications/tooltip-specification.md`

## Conditional Formatting
- **Approval Rate KPI**: 
  - Red (<0.90), Amber (0.90‑0.94), Green (≥0.95) applied to the value or background
- **Refund Ratio and Chargeback Ratio KPIs**: 
  - Red if value exceeds the respective threshold (Threshold measures: `[Merchant Refund Threshold]` and `[Merchant Chargeback Threshold]`), else Green
- **Map Color**: As described (approved vs declined)

## Cross‑Filtering Behavior
- Within the page:
  - Enable bidirectional filtering between the line chart and the donut chart/map if desired (e.g., selecting a date range via the line chart’s interaction filters the other visuals to that date)
  - Between the donut chart and the map: selecting a payment method filters the map to show only transactions of that method (color/size adjust)
  - Between the map and the donut chart: selecting a region filters the donut chart to show payment method mix for that region
- **Drillthrough Out**: As described, link to deeper transaction‑level diagnostics

## Accessibility
- Ensure all KPI values are readable (sufficient contrast)
- Map colors should be distinguishable (blue for approved, red for declined is common and generally accessible)
- Provide textual equivalents via tooltips for color‑coded information
- Ensure the north‑south layout respects reading order (left to right, top to bottom)

## Performance Considerations
- As a drillthrough page, the query context is reduced to a single merchant, which should improve performance
- Avoid visuals that require heavy computations per merchant (e.g., complex row‑by‑row calculations)
- Use aggregations at the day level for the line chart to keep the number of data points manageable (max ~365 points per year)

## Build Steps (Summary)
1. Create a new page and set its Type to “Drillthrough” in the Page properties.
2. Add `DimMerchant[MerchantKey]` to the Drillthrough filters well.
3. Enable “Keep all filters” if desired.
4. Set the page title via a measure or text box: `"Merchant Detail – " & SELECTEDVALUE(DimMerchant[MerchantDisplayName])`
5. Design the two‑column layout using guides or the grid.
6. Build the left column: create a vertical stack of KPI cards (use Card visuals or text boxes in shapes) with the specified labels and measures.
7. Apply conditional formatting to the relevant KPIs (Approval Rate, Refund Ratio, Chargeback Ratio).
8. Build the right column:
   - Top: Line chart with dual axis (Transaction Value and Approval Rate)
   - Bottom‑left: Donut chart for payment method mix
   - Bottom‑right: Bubble map for geographic distribution (color by approval status)
9. Add a date range slicer to the header or top‑right if desired.
10. Set up interactions:
    - Within the page: enable cross‑filtering between visuals as described (e.g., line chart ↔ donut chart, line chart ↔ map, donut chart ↔ map)
    - Drillthrough out: from each visual to the Transaction Diagnostics page, passing the relevant context (date, payment method, location) along with the maintained merchant context
11. Add a back button in the header (top‑left) with action set to “Back”.
12. Assign the “Transaction Tooltip” to the line chart, donut chart, and map visuals.
13. Test the drillthrough from source pages (e.g., Executive Overview → Merchant Drillthrough by clicking a merchant in the Top‑10 visual) to ensure the correct merchant is passed and the page updates.
14. Validate the layout against the grid using Snap to grid and check alignment.
15. Review for accessibility and performance.
# Transaction Diagnostics Specification

## Purpose
Deep‑dive into transaction‑level attributes, decline reasons, payment methods, geography, and anomaly detection to understand transaction outcomes and identify issues.

## Page Layout
Follow the Master Layout Specification with:
- KPI row (4 cards) below header
- Left‑aligned vertical slicer pane (optional) for filters
- Three visual regions: decline reason bar chart, payment method stacked column chart, and geographic heatmap (map)
- Footer optional

## Components

### KPI Row (Top Row)
| # | KPI | Measure | Format | Label |
|---|-----|---------|--------|-------|
| 1 | Declined Transactions | `[Declined Transactions]` | Integer | “Declined Transactions” |
| 2 | Refund Transactions | `[Refund Transactions]` | Integer | “Refund Transactions” |
| 3 | Chargeback Transactions | `[Chargeback Transactions]` | Integer | “Chargeback Transactions” |
| 4 | Average Transaction Value | `[Average Transaction Value]` | Currency (2 dp) | “Avg Tx Value” |

**Card Styling**: 
- Decline KPI: Use Negative color (`#EF4444`) for value to emphasize
- Refund and Chargeback KPIs: Use Positive color (`#22C55E`) for value
- Avg Tx Value: Use Accent color (`#3B82F6`) or Primary Text

### Visual 1 – Decline Reason Distribution (Bar Chart)
- **Title**: “Decline Reason Breakdown”
- **Type**: Bar chart (horizontal)
- **X‑Axis**: Count of `FactTransactions` (or Transaction Value – choose based on insight; count is more common for reasons)
- **Y‑Axis**: `FactTransactions[DeclineReason]` (sorted descending by count, exclude blanks)
- **Colors**: Single color series, use conditional formatting by count: gradient from `#F59E0B` (low) to `#EF4444` (high) OR default theme color (`#3B82F6`) with data label showing count
- **Tooltip**: Show Decline Reason, Count of Transactions, and Percentage of total declines
- **Sort Order**: Descending by count (so most frequent reason at top)
- **Data Labels**: Show value (count) on bars
- **Slicer Interaction**: Date range, Merchant Risk Tier, Payment Method, Transaction Amount range slicers filter this visual
- **Cross‑Filtering**: 
  - Clicking a bar filters other visuals to transactions with that decline reason
- **Drillthrough**: 
  - From a bar → Drillthrough to Transaction Diagnostics page (self‑filter) passing the specific `DeclineReason` to show time series or details for that reason
  - Alternative: Drillthrough to a dedicated “Decline Reason Detail” page if exists, but per spec we drill to same page filtered
- **Position**: Left third of visual area (columns 1‑4)

### Visual 2 – Payment Method Usage (100% Stacked Column Chart)
- **Title**: “Payment Method Mix by Approval Status”
- **Type**: 100% stacked column chart
- **X‑Axis**: `DimDate[DateDate]` (use Year > Month hierarchy for monthly granularity)
- **Y‑Axis**: Percent of transactions (0‑100%)
- **Legend**: `DimPaymentMethod[PaymentMethod]` (each payment method as a segment)
- **Values**: Count of `FactTransactions` (normalized to 100% per column)
- **Colors**: Use theme’s `dataColors` in order for each payment method (consistent across visuals)
- **Tooltip**: Show Month, Payment Method, Percentage, and Count of Transactions
- **Slicer Interaction**: Date range (though X‑axis is date, slicer can zoom in), Merchant Risk Tier, and Transaction Amount range sliders filter this visual
- **Cross‑Filtering**: 
  - Clicking a segment filters other visuals to that payment method and time period
- **Drillthrough**: 
  - From a column segment → Drillthrough to Transaction Diagnostics page filtered to that payment method and time period
  - Alternatively, drillthrough to a Payment Method detail page if exists
- **Position**: Middle third of visual area (columns 5‑8)

### Visual 3 – Geographic Heatmap (Map)
- **Title**: “Transaction Value by Country”
- **Type**: Map (filled map)
- **Location**: `DimGeography[MarketDisplayName]`
- **Values**: Sum of `FactTransactions[TransactionAmount]`
- **Color Saturation**: Gradient from `#3B82F6` (low) to `#7C3AED` (high) – using the theme’s blue/violet progression
- **Tooltip**: Show Country, Total Tx Value, Tx Count, Approval Rate
- **Slicer Interaction**: Date range, Merchant Risk Tier, and Payment Method slicers filter this visual
- **Cross‑Filtering**: 
  - Clicking a country filters other visuals to transactions from that country
- **Drillthrough**: 
  - From a country → Drillthrough to Merchant Drillthrough page (or Geography drilldown if available) passing the selected `DimGeography[MarketDisplayName]` or `GeographyKey`
- **Position**: Right third of visual area (columns 9‑12)

## Filters (Page Level)
Place in header or left vertical sidebar:
- **Date Slicer**: Relative (default “Last 90 days”), type: Relative date or dropdown
- **Merchant Risk Tier**: Checkboxes (Low, Medium, High)
- **Payment Method**: Dropdown (from `DimPaymentMethod[PaymentMethod]`)
- **Transaction Amount Range**: Slider (min to max of `FactTransactions[TransactionAmount]` in current context)
- **Note**: Use sync slicers for cross‑page consistency

## Drillthrough Interactions
- **From Visual 1 (Decline Reason)**: Selecting a bar → Drillthrough to this same page (Transaction Diagnostics) filtered to that specific `DeclineReason` (to see its time series or details)
- **From Visual 2 (Payment Method)**: Selecting a stack segment → Drillthrough to this page filtered to that `PaymentMethod` and the time period (month) of the column
- **From Visual 3 (Map)**: Selecting a country → Drillthrough to Merchant Drillthrough page (to see merchants in that country) OR to a Geographic drilldown page if exists

## Tooltip Page
- Assign a tooltip page to all three visuals that shows:
  - Transaction ID, Timestamp, Amount, Currency
  - Merchant Name, Customer ID
  - Approval status, Decline Reason (if any)
  - Refund & Chargeback flags & amounts
- Name the tooltip page: “Transaction Tooltip”
- Size: Tooltip (320 × 240)
- Design per `specifications/tooltip-specification.md`

## Conditional Formatting
- **Decline Reason Bar Chart**: 
  - Bar color by count: gradient from `#F59E0B` (low) to `#EF4444` (high) (or use a single color with data labels)
  - Alternative: Use three‐tone color scale (low/medium/high) if desired
- **Payment Method Stacked Column**: Use distinct colors per method from the theme’s `dataColors` array
- **Map Color Scale**: Sequential blue‑to‑violet as described

## Cross‑Filtering Behavior
- Enable bidirectional filtering where it makes sense (e.g., between the decline reason chart and the map: selecting a reason shows where those declines happened geographically)
- Between the payment method chart and the map: selecting a payment method shows its geographic distribution
- Map to charts: selecting a country filters the other visuals to that country

## Accessibility
- Ensure map colors are distinguishable for color‑blind users (consider using a color‑blind safe palette or add patterns—but maps in Power BI may not support patterns; rely on tooltips for exact values)
- Decrease reliance on color alone: include data labels or tooltips for exact values
- Ensure text in visuals meets contrast ratios

## Performance Considerations
- The map visual can be slow with many geography points; limit to country level (as specified) for better performance
- Decline reason chart: if there are many distinct reasons, consider grouping less frequent reasons into “Other”
- Payment method chart: limit to top N methods if the list is long

## Build Steps (Summary)
1. Apply theme and set page size
2. Build KPI row with four Card visuals (apply conditional formatting to values as described)
3. Create Horizontal Bar chart for decline reasons, set sorting, colors, and tooltips
4. Create 100% Stacked Column chart for payment method mix, set axis, legend, colors, and tooltips
5. Create Filled Map for geographic distribution, set location, values, color scale, and tooltips
6. Add slicers to header or left sidebar and configure sync
7. Set up cross‑filtering and drillthrough as specified
8. Apply conditional formatting to decline reason bars and map
9. Assign tooltip panels to all three visuals
10. Test interactions and visual hierarchy
11. Validate layout against the grid using Snap to grid
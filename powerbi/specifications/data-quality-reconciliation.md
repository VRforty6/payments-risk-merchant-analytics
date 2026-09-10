# Data Quality & Reconciliation Specification

## Purpose
Validate that source, staging, fact, and aggregates reconcile; surface any anomalies or data‑quality issues to ensure trust in the reported numbers.

## Page Layout
Follow the Master Layout Specification with:
- KPI row (4 cards) below header
- Left‑aligned vertical slicer pane (optional) for filters
- Two visual regions: reconciliation matrix and anomaly bar chart
- Footer optional

## Components

### KPI Row (Top Row)
| # | KPI | Measure / Note | Format | Label |
|---|-----|----------------|--------|-------|
| 1 | Staging Row Count | Measure that counts rows in the source staging table (e.g., `StagingRowCount` from a helper table or calculated via DAX using a reference table) | Integer | “Staging Rows” |
| 2 | Fact Row Count | `[Total Transactions]` | Integer | “Fact Rows” |
| 3 | Row Count Difference | `[Staging Row Count] - [Total Transactions]` | Integer | “Difference” |
| 4 | Data‑Quality Pass/Fail | `IF([Row Count Difference] = 0, "PASS", "FAIL")` | Text | “DQ Status” |

**Card Styling**:
- Staging Row Count and Fact Row Count: Use Primary Text (`#F8FAFC`) for values
- Row Count Difference: 
  - Green (`#22C55E`) if zero
  - Red (`#EF4444`) if non‑zero
- DQ Status: 
  - Green text and background if PASS
  - Red text and background if FAIL
  - Use conditional formatting on the card background or font color

> **Note**: The “Staging Row Count” measure may require a helper table imported via Power Query (e.g., a single‑row table with the staging count) or a direct query to a view. For the purpose of this specification, assume a measure `[Staging Row Count]` exists that returns the count of rows in the staging layer for the fact table.

### Visual 1 – Reconciliation Table (Matrix)
- **Title**: “Reconciliation Summary”
- **Type**: Matrix (or Table if hierarchical)
- **Rows**: 
  - Entity: Values from a helper table (e.g., `StagingStats[TableName]` with rows such as “Countries”, “Merchants”, “Customers”, “Transactions”)
  - Alternative: Use a disconnected table with hardcoded row names if no such table exists
- **Columns**: 
  - “Source Rows”
  - “Fact Rows”
  - “Difference”
- **Values**: 
  - Source Rows: `LOOKUPVALUE(StagingStats[RowCount], StagingStats[TableName], ...)` (or measure that returns the source count for that entity)
  - Fact Rows: 
    - For Transactions: `[Total Transactions]`
    - For Others: Use appropriate fact table counts (e.g., `[Active Merchants]` for Merchants, `[Distinct Customers]` for Customers, `[Distinct Countries]` for Countries) – these measures should exist or be created
  - Difference: `[Source Rows] - [Fact Rows]`
- **Conditional Formatting**:
  - Difference column: 
    - Background color: Green (`#22C55E`) if 0, Red (`#EF4444`) if not 0
    - Font color: White on colored background for contrast (adjust as needed)
  - Alternatively, use data bars or font color only
- **Tooltip**: Show exact numbers for Source, Fact, and Difference
- **Slicer Interaction**: Date slicer (if the reconciliation is time‑bound, e.g., monthly) filters this visual
- **Cross‑Filtering**: 
  - Selecting a row highlights that entity; other visuals can filter to show details for that entity (e.g., selecting “Transactions” filters the anomaly chart to transaction‑level anomalies)
- **Drillthrough**: 
  - From a row → Drillthrough to Transaction Diagnostics page (or a specific anomaly page) filtered to that entity (if applicable)
- **Position**: Left half of the visual area (columns 1‑6)

### Visual 2 – Anomaly Count by Type (Bar Chart)
- **Title**: “Anomaly Count by Type”
- **Type**: Bar chart (vertical)
- **X‑Axis**: Anomaly Type (from a helper table or calculated list, e.g.):
  - Refund on Declined
  - Chargeback on Declined
  - Refund > Transaction Amount
  - Chargeback > Transaction Amount
  - Approved with Decline Reason
  - Declined without Reason
  - (Add any other relevant anomaly types from data quality checks)
- **Y‑Axis**: Count of anomalies (use measures that flag each anomaly type)
- **Colors**: 
  - Use sequential or diverging palette based on severity:
    - Low (e.g., minor formatting issue): `#F59E0B` (Warning)
    - Medium (e.g., refund > amount): `#EF4444` (Negative)
    - High (e.g., chargeback on declined): `#EF4444` (Negative) – same as medium if only two levels
    - Alternatively, assign specific colors per type for clarity
- **Tooltip**: Show Anomaly Type, Count, and brief description
- **Sort Order**: Descending by count (so most frequent anomalies on top)
- **Data Labels**: Show count on bars
- **Slicer Interaction**: Date slicer (to filter time‑bound anomalies) filters this visual
- **Cross‑Filtering**: 
  - Selecting an anomaly type filters other visuals to transactions of that type (e.g., selecting “Refund on Declined” shows those transactions in the transaction‑level detail visual if present)
- **Drillthrough**: 
  - From a bar → Drillthrough to Transaction Diagnostics page filtered to the selected anomaly type (to see the underlying transactions)
- **Position**: Right half of the visual area (columns 7‑12)

## Filters (Page Level)
- **Date Slicer**: 
  - If reconciliation is performed per period (e.g., daily or monthly), include a date slicer
  - Default: “Last 30 days” or “Current month”
  - Type: Relative date or dropdown
- **Note**: Some anomalies may be time‑independent (e.g., schema mismatches); in such cases, the date slicer may have no effect and should be disabled or hidden for those metrics

## Drillthrough Interactions
- **From Visual 1 (Matrix)**: 
  - Selecting a row (e.g., “Transactions”) → Drillthrough to Transaction Diagnostics page (to see transaction‑level details for reconciliation differences)
  - Selecting a row for “Merchants” → Drillthrough to Merchant Drillthrough page
- **From Visual 2 (Anomaly Bar)**: 
  - Selecting an anomaly type → Drillthrough to Transaction Diagnostics page filtered to that anomaly type (to examine the underlying transactions)

## Tooltip Page
- For the matrix, a tooltip may show the exact Source, Fact, and Difference values.
- For the anomaly bar chart, the tooltip can show:
  - Anomaly Type
  - Count
  - Description (e.g., “Refunds found on transactions that were declined”)
  - Example values or typical impact
- If a dedicated tooltip page is desired, create one per visual or use a generic one.
- Name the tooltip page: “Reconciliation Tooltip” or “Anomaly Tooltip”
- Size: Tooltip (320 × 240)
- Design per `specifications/tooltip-specification.md`

## Conditional Formatting
- **Matrix Difference Cell**: As described above (background or font color based on zero vs non‑zero)
- **Anomaly Bar Chart**: 
  - Color by severity if applicable (e.g., gradient from yellow to red) OR use a single color with the understanding that all anomalies require investigation
  - Alternative: Use three discrete colors for low/medium/high severity if defined

## Cross‑Filtering Behavior
- Between the matrix and the anomaly chart: selecting an entity in the matrix (e.g., “Transactions”) filters the anomaly chart to show only anomalies related to that entity (if the anomaly types are entity‑specific)
- From the anomaly chart to the matrix: selecting an anomaly type does not filter the matrix (as it summarizes totals per type) but could highlight the relevant row if the matrix includes a breakdown by anomaly type (not in current design)
- Consider adding a drillthrough from the anomaly chart to a detail page rather than filtering the matrix

## Accessibility
- Ensure the matrix has clear headers and sufficient contrast
- Use patterns or text labels in addition to color for the difference column (e.g., prefix with “+” or “‑” and use color as supplementary)
- Verify that tooltip text is readable and meets contrast standards

## Performance Considerations
- The matrix relies on lookup measures; ensure these are efficient (avoid row‑by‑row processing)
- If the reconciliation requires scanning large fact tables, consider pre‑aggregating in the model or using query reduction techniques
- The anomaly chart should use pre‑calculated measures to avoid expensive row‑by‑row checks in the visual

## Build Steps (Summary)
1. Apply theme and set page size
2. Create or ensure existence of helper tables for:
   - Staging statistics (if not present, import a table that mirrors the staging row counts per entity)
   - Anomaly type list (if not present, create a table with the anomaly types described)
3. Build KPI row with four Card visuals, applying conditional formatting to the difference and status cards
4. Build Matrix visual for reconciliation summary, setting up rows, columns, and values as described
5. Build Bar chart for anomaly counts, setting up axes, values, colors, and sorting
6. Add date slicer (if applicable) to header or left sidebar
7. Set up cross‑filtering and drillthrough as specified
8. Apply conditional formatting to matrix difference cells and anomaly bars
9. Create tooltip pages for matrix and anomaly chart (or use existing tooltip infrastructure)
10. Assign tooltips to the visuals
11. Test interactions: selecting a row in the matrix should filter the anomaly chart (if applicable) and enable drillthrough; selecting an anomaly bar should filter details
12. Validate layout against the grid using Snap to grid
# Power BI Dashboard Build Guide – Payments Risk & Merchant Analytics

**Data Source:** SQL Server database `PaymentsRiskAnalytics` – import the following tables (dw schema) as-is:
- FactTransactions
- DimDate
- DimMerchant
- DimCustomer  
- DimGeography
- DimPaymentMethod
- DimTransactionStatus

**Theme:** Apply the JSON theme file `powerbi/theme/payments-risk-theme.json` (Background #0F172A, Card background #111827, Primary violet #7C3AED, Indigo #4F46E5, Accent blue #3B82F6, Text #F8FAFC, Secondary text #94A3B8, Positive #22C55E, Negative #EF4444, Warning #F59E0B).

**General Page Settings**
- Page size: 16:9 (Standard)
- Tile alignment: Snap to grid
- Title font: Segoe UI, 14pt, White (#F8FAFC)
- Background color: #0F172A

---

## 1. Executive Overview

**Purpose:** High‑level health of the payments ecosystem at a glance.

| Item | Details |
|------|---------|
| **KPI Cards (top row, 4 cards)** | 1. **Total Transactions** – value = `[Total Transactions]`, display units: None, label: “Total Transactions”. <br>2. **Approval Rate** – value = `[Approval Rate]`, format: Percentage (2 dp), label: “Approval Rate”. <br>3. **Transaction Value** – value = `[Transaction Value]`, display units: Millions (M), label: “Transaction Value”. <br>4. **Processing Revenue** – value = `[Processing Revenue]`, display units: Thousands (K), label: “Processing Revenue”. |
| **Card background** | #111827, border: 1px solid #1F2937, text color: #F8FAFC, value color: #7C3AED (primary). |
| **Visual 1 – Transaction Trend (Line chart)** | - **Visual type:** Line chart <br> - **Title:** “Daily Transaction Volume & Approval Rate” <br> - **Axis:** DimDate[DateDate] (continuous) <br> - **Values:** <br>   &nbsp;&nbsp;• Transaction Value (line, color #3B82F6) <br>   &nbsp;&nbsp;• Approval Rate (line, secondary axis, color #22C55E) <br> - **Legend:** Show (Transaction Value, Approval Rate) <br> - **Slicer:** Date range (Relative date hierarchy (Relative last 30 days, Last month, Custom) placed at top‑right. <br> - **Tooltip:** Show Transaction Value, Approval Rate, Total Transactions. |
| **Visual 2 – Approval vs Decline by Region (Stacked column)** | - **Visual type:** Stacked column chart <br> - **Title:** “Approval/Decline Split by Region” <br> - **Axis:** DimGeography[Region] <br> - **Legend:** DimTransactionStatus[IsApproved] (mapped to Approved/Declined) <br> - **Values:** Count of FactTransactions (or Transaction Value) <br> - **Sort:** By total descending. |
| **Visual 3 – Top 10 Merchants by Transaction Value (Bar chart)** | - **Visual type:** Bar chart (horizontal) <br> - **Title:** “Top 10 Merchants – Transaction Value” <br> - **Axis:** Merchant value (Transaction Value) <br> - **Legend:** None <br> - **Values:** <br>   &nbsp;&nbsp;• Merchant Name (DimMerchant[MerchantDisplayName]) on Y‑axis <br>   &nbsp;&nbsp;• Transaction Value (sum) on X‑axis <br> - **Sort:** Descending by Transaction Value, limit to top 10 via visual‑level filter. <br> - **Data label:** Show value (M). |
| **Filters (page level)** | - Relative Date slicer (default: Last 30 days) <br> - Merchant Risk Tier (checkbox) – allow filtering by Low/Medium/High <br> - Payment Method (dropdown) |
| **Drillthrough** | - From **Transaction Value** column in the Top‑10 Merchants visual → Drillthrough page **Merchant Drillthrough** (see section 5) passing DimMerchant[MerchantKey]. <br> - From **Region** axis in the stacked column → Drillthrough to **Transaction Diagnostics** (see section 3) passing DimGeography[Region]. |
| **Tooltip page** | Create a tooltip page named “Merchant Tooltip” (size: Tooltip, 320 x 240) containing: <br>   • Merchant Name <br>   • Total Transactions, Approval Rate, Refund Ratio, Chargeback Ratio <br>   • Small sparkline of daily transaction value (last 30 days). <br>   Assign this tooltip to the Top‑10 Merchants bar chart. |
| **Conditional formatting** | - Approval Rate KPI card: Green if ≥ 0.95, Amber if 0.90‑0.95, Red if < 0.90 (using the Positive/Warning/Negative colors). <br> - Transaction Value line: Color by value (gradient #3B82F6 → #7C3AED). |

---

## 2. Merchant Risk Analysis

**Purpose:** Examine merchant‑level risk distribution and thresholds.

| Item | Details |
|------|---------|
| **KPI Cards (top row, 4 cards)** | 1. **Active Merchants** – `[Active Merchants]` <br>2. **High Risk Merchants** – `[High Risk Merchants]` <br>3. **Merchant Risk Tier Index** – `[Merchant Risk Tier Index]` (format: Decimal 1) <br>4. **Approval Rate (Merchant Avg)** – `[Approval Rate]` (same measure, but context is per merchant) |
| **Card background** | #111827, border: 1px solid #1F2937, text: #F8FAFC, value: #7C3AED. |
| **Visual 1 – Merchant Risk Tier Distribution (Donut chart)** | - **Visual type:** Donut chart <br> - **Title:** “Merchant Count by Risk Tier” <br> - **Legend:** DimMerchant[RiskTier] (Low, Medium, High) <br> - **Values:** Count of DimMerchant[MerchantKey] (distinct) <br> - **Show details:** On (percentage + value). |
| **Visual 2 – Refund & Chargeback Ratio vs Threshold (Scatter plot)** | - **Visual type:** Scatter chart <br> - **Title:** “Refund & Chargeback Ratio per Merchant” <br> - **X‑axis:** `[Refund Ratio]` (format: Percentage 2 dp) <br> - **Y‑axis:** `[Chargeback Ratio]` (format: Percentage 2 dp) <br> - **Details:** DimMerchant[MerchantDisplayName] <br> - **Color saturation:** `[Merchant Risk Tier Index]` (gradient from #22C55E (low) to #EF4444 (high)). <br> - **Size:** `[Total Transactions]` (log scale) <br> - **Constant lines:** <br>   &nbsp;&nbsp;• X = Merchant Refund Threshold (0.02) – dashed line, color #F59E0B <br>   &nbsp;&nbsp;• Y = Merchant Chargeback Threshold (0.01) – dashed line, color #F59E0B <br> - **Tooltip:** Show Merchant Name, Refund Ratio, Chargeback Ratio, Total Transactions, Active? |
| **Visual 3 – Merchant Trend (Line chart, small multiples)** | - **Visual type:** Line chart <br> - **Title:** “Daily Approval Rate Trend per Merchant (Top 5 by Volume)” <br> - **Axis:** DimDate[DateDate] <br> - **Legend:** DimMerchant[MerchantDisplayName] (limit to top 5 by Total Transactions via visual‑level filter) <br> - **Values:** Approval Rate (calc via measure) <br> - **Show data labels:** Off. |
| **Slicers (page level, left side)** | - Merchant Risk Tier (checkbox) <br> - Merchant Category (dropdown) <br> - Date range (Relative last 60 days) |
| **Filters (page level)** | - Exclude Unknown merchant (DimMerchant[MerchantKey] <> 0) <br> - Exclude transactions with TransactionAmount = 0 (if any) |
| **Drillthrough** | - From each point in the scatter plot → Drillthrough page **Merchant Drillthrough** (section 5) passing DimMerchant[MerchantKey] <br> - From the Donut chart slice → Drillthrough to **Transaction Diagnostics** passing DimMerchant[RiskTier] |
| **Tooltip page** | Create a tooltip page “Merchant Detail Tooltip” (size: Tooltip) containing: <br>   • Merchant ID, Name, Category, Risk Tier <br>   • KPI cards: Total Tx, Approval Rate, Refund %, Chargeback %, Avg Tx Value <br>   • Mini bar chart of daily tx volume (last 14 days). Assign to scatter plot and donut visual. |
| **Conditional formatting** | - Scatter point color: as described (risk score gradient). <br> - Donut slice colors: Low = #22C55E, Medium = #F59E0B, High = #EF4444. |

---

## 3. Transaction Diagnostics

**Purpose:** Deep‑dive into transaction‑level attributes, decline reasons, payment methods, etc.

| Item | Details |
|------|---------|
| **KPI Cards (top row, 4 cards)** | 1. **Declined Transactions** – `[Declined Transactions]` <br>2. **Refund Transactions** – `[Refund Transactions]` <br>3. **Chargeback Transactions** – `[Chargeback Transactions]` <br>4. **Average Transaction Value** – `[Average Transaction Value]` |
| **Card background** | #111827, border: 1px solid #1F2937, text: #F8FAFC, value: #EF4444 (negative) for declines, #22C55E for refunds/chargebacks (positive), #7C3AED for avg value. |
| **Visual 1 – Decline Reason Distribution (Funnel or stacked bar)** | - **Visual type:** Stacked bar chart <br> - **Title:** “Decline Reason Breakdown” <br> - **Axis:** Decline Reason (FactTransactions[DeclineReason]) – exclude blanks <br> - **Legend:** None <br> - **Values:** Count of FactTransactions (or Transaction Value) <br> - **Sort:** Descending by count. |
| **Visual 2 – Payment Method Usage (100% stacked column)** | - **Visual type:** 100% stacked column chart <br> - **Title:** “Payment Method Mix by Approval Status” <br> - **Axis:** DimDate[DateDate] (monthly) – use a hierarchy Year > Month <br> - **Legend:** DimPaymentMethod[PaymentMethod] <br> - **Values:** Count of FactTransactions (normalized to 100%). |
| **Visual 3 – Geographic Heatmap (Map)** | - **Visual type:** Map (filled map) <br> - **Title:** “Transaction Value by Country” <br> - **Location:** DimGeography[MarketDisplayName] <br> - **Values:** Sum of FactTransactions[TransactionAmount] <br> - **Color saturation:** Gradient #3B82F6 (low) → #7C3AED (high) <br> - **Tooltip:** Show Country, Total Tx Value, Tx Count, Approval Rate. |
| **Slicers (page level, top)** | - Date range (Relative last 90 days) <br> - Merchant Risk Tier (checkbox) <br> - Transaction Amount range (slider) |
| **Filters (page level)** | - Exclude Unknown geography (DimGeography[GeographyKey] = 0) <br> - Exclude Unknown payment method (DimPaymentMethod[PaymentMethodKey] = 0) |
| **Drillthrough** | - From any point on the map → Drillthrough page **Merchant Drillthrough** passing DimGeography[MarketDisplayName] (or GeographyKey) to show merchants in that country. <br> - From Decline Reason bar → Drillthrough to **Transaction Diagnostics** passing the specific DeclineReason (to see time series). |
| **Tooltip page** | Create a tooltip page “Transaction Tooltip” (size: Tooltip) containing: <br>   • Transaction ID, Timestamp, Amount, Currency <br>   • Merchant Name, Customer ID <br>   • Approval status, Decline Reason (if any) <br>   • Refund & Chargeback flags & amounts. <br> Assign to map and stacked bar visuals. |
| **Conditional formatting** | - Decline Reason bar: color by count (gradient #EF4444 → #F59E0B). <br> - Payment method stacked column: use default theme colors. |

---

## 4. Data Quality and Reconciliation

**Purpose:** Validate that source, staging, fact, and aggregates reconcile; surface any anomalies.

| Item | Details |
|------|---------|
| **KPI Cards (top row, 4 cards)** | 1. **Staging Row Count** – (calculated via a measure that queries the source? Not available in model; instead use a **calculated table** or **SQL view** – for simplicity, we’ll add a **measure** that counts rows in a helper table `StagingRowCount` imported as a single‑row table. For this guide assume we have a table `StagingStats` with columns: TableName, RowCount. <br>   Show `[Staging Row Count]` (value from StagingStats where TableName='Transactions') <br>2. **Fact Row Count** – `[Total Transactions]` <br>3. **Row Count Difference** – `[Staging Row Count] - [Total Transactions]` (should be 0) <br>4. **Data‑Quality Pass/Fail** – KPI: `IF([Row Count Difference]=0, "PASS", "FAIL")` |
| **Card background** | #111827, border: 1px solid #1F2937, text: #F8FAFC, value: #22C55E for pass, #EF4444 for fail. |
| **Visual 1 – Reconciliation Table (Matrix)** | - **Visual type:** Matrix <br> - **Title:** “Reconciliation Summary” <br> - **Rows:** StagingStats[TableName] (values: Countries, Merchants, Customers, Transactions) <br> - **Columns:** “Source Rows”, “Fact Rows”, “Difference” <br> - **Values:** <br>   &nbsp;&nbsp;• Source Rows = LOOKUPVALUE(StagingStats[RowCount], StagingStats[TableName], ...) <br>   &nbsp;&nbsp;• Fact Rows = CALCULATE([Total Transactions], TREATAS({StagingStats[TableName]}, FactTransactions[??])) – not directly mappable; instead we will import a separate fact table per entity (e.g., FactMerchantDaily, FactCustomer). Since the scope is limited, we note that this page would be built using **imported views** from SQL (e.g., `rpt.vw_transaction_summary` and staging counts) – but for the purpose of the guide we instruct the developer to create a **calculated table** using Power Query that unions staging and fact counts. <br>   For brevity, we state: *Create a calculated table “Reconciliation” with columns: Entity, SourceCount, FactCount, Diff* using DAX or Power Query, then display it as a matrix. |
| **Visual 2 – Anomaly Count by Type (Bar chart)** | - **Visual type:** Bar chart <br> - **Title:** “Anomaly Count by Type” <br> - **Axis:** Anomaly Type (from a helper table that flags: Refund on Declined, Chargeback on Declined, Refund > Txn Amt, Chargeback > Txn Amt, Approved with Decline Reason, Declined without Reason) <br> - **Values:** Count of anomalies (use measures from validation queries). |
| **Slicers (page level)** | - Date range (to filter time‑bound anomalies) |
| **Filters (page level)** | - Only show anomalies where count > 0 |
| **Drillthrough** | - From any anomaly bar → Drillthrough to **Transaction Diagnostics** filtered to those transactions (passing anomaly type). |
| **Tooltip page** | Create a tooltip page “Anomaly Detail Tooltip” listing sample transaction IDs and details. Assign to the bar chart. |
| **Conditional formatting** | - Difference column: Green if 0, Red otherwise (using Data bar or font color). <br> - Anomaly bar: color by severity (Warning = #F59E0B for minor, Negative = #EF4444 for critical). |

---

## 5. Merchant Drillthrough

**Purpose:** Show all relevant metrics for a selected merchant (passed from other pages).

| Item | Details |
|------|---------|
| **Page Type:** Drillthrough page (allow multiple incoming fields: MerchantKey, MerchantName, RiskTier, Region, etc.). |
| **Title:** “Merchant Detail – ” & SELECTEDVALUE(DimMerchant[MerchantDisplayName]) |
| **Layout:** Two‑column layout (left: KPI column, right: visual column). |
| **KPI Cards (left column, stacked)** | 1. **Total Transactions** – `[Total Transactions]` <br>2. **Approved Transactions** – `[Approved Transactions]` <br>3. **Declined Transactions** – `[Declined Transactions]` <br>4. **Transaction Value** – `[Transaction Value]` <br>5. **Approval Rate** – `[Approval Rate]` <br>6. **Refund Ratio** – `[Refund Ratio]` <br>7. **Chargeback Ratio** – `[Chargeback Ratio]` <br>8. **Average Transaction Value** – `[Average Transaction Value]` <br>9. **Active Days** – Distinct count of dates with transactions <br>10. **Last Transaction Date** – `[Last Transaction Date]` |
| **Card background** | #111827, border: 1px solid #1F2937, text: #F8FAFC, value: #7C3AED. |
| **Visual 1 – Daily Transaction Trend (Line chart)** | - **Visual type:** Line chart <br> - **Title:** “Daily Transaction Volume” <br> - **Axis:** DimDate[DateDate] <br> - **Values:** Transaction Value (line, #3B82F6) <br> - **Secondary axis:** Approval Rate (line, #22C55E) <br> - **Legend:** Show both. |
| **Visual 2 – Payment Method Mix (Donut chart)** | - **Visual type:** Donut chart <br> - **Title:** “Payment Method Usage” <br> - **Legend:** DimPaymentMethod[PaymentMethod] <br> - **Values:** Count of FactTransactions. |
| **Visual 3 – Geographic Distribution (Map)** | - **Visual type:** Map (bubble) <br> - **Title:** “Transaction Locations” <br> - **Location:** DimGeography[City] (or Country if city not available) <br> - **Size:** Sum of Transaction Amount <br> - **Color:** Approval status (color: #22C55E for approved, #EF4444 for declined) <br> - **Tooltip:** Show City, Tx Count, Tx Value, Approval %. |
| **Visual 4 – Decline Reason Breakdown (Bar chart)** | - **Visual type:** Bar chart <br> - **Title:** “Decline Reasons (if any)” <br> - **Axis:** FactTransactions[DeclineReason] (exclude blanks) <br> - **Values:** Count of FactTransactions. |
| **Slicers (page level)** | - Date range (Relative last 60 days, default) <br> - Transaction Amount range (optional) |
| **Filters (page level)** | - Automatically filters to the selected merchant via incoming field(s). |
| **Tooltip page** | Re‑use the generic “Transaction Tooltip” from section 3 (or create a small one showing Merchant‑level aggregates). Assign to visuals as needed. |
| **Conditional formatting** | - KPI cards: Approval Rate – Green/Amber/Red as per earlier thresholds. <br> - Map bubbles: Approved = #22C55E, Declined = #EF4444. |

---

## General Instructions for Building the Dashboard Quickly

1. **Import Data**  
   - In Power BI Desktop → Get Data → SQL Server → Server: `VRFORTY6` (or your instance) → Database: `PaymentsRiskAnalytics` → Select the six dw tables and FactTransactions.  
   - Ensure relationships are auto‑detected; verify keys as listed above. Mark inactive relationships if any; set cross filter direction to Single (both) where appropriate.  
   - Import any helper tables you create for thresholds or reconciliation via Enter Data or Power Query.

2. **Apply Theme**  
   - View → Themes → Browse for theme file → select `powerbi/theme/payments-risk-theme.json`.

3. **Create Measures**  
   - New Table → Enter Data → name it `Measures` (single column dummy) → then New Measure for each DAX expression in `powerbi/dax/dax-measures.md`.  
   - Alternatively, create measures directly on the FactTransactions table (right‑click → New measure).  

4. **Build Pages**  
   - Follow the layout tables above. Insert visuals, assign fields from the field pane, and set the exact values/axes/legends as specified.  

5. **Set Up Slicers & Filters**  
   - Add slicer visuals, bind to the appropriate dimension columns, and select the indicated slicer type (dropdown, checkbox, date hierarchy, slider).  
   - Use the Format pane to make slicers single‑select where needed, and enable “Select all” for multi‑select.

6. **Configure Drillthrough**  
   - On the target drillthrough page (e.g., Merchant Drillthrough), go to Page → Drag the incoming field (MerchantKey) into the Drillthrough filters well.  
   - On source visuals, right‑click → Drillthrough → choose the target page.  

7. **Assign Tooltip Pages**  
   - Design a tooltip page (size: Tooltip) → fill with desired visuals/KPIs → then on the source visual, under the Tooltip field, select the tooltip page name.  

8. **Conditional Formatting**  
   - For each visual/measure that requires it, use the Format pane → Data colors → Conditional formatting → Rules based on field or measure. Use the exact hex colors from the design spec.  

9. **Validate**  
   - Switch to Focus mode on each visual to ensure values are as expected.  
   - Use the DAX measure definitions to spot‑check numbers against known totals (e.g., total rows = 75,000).  
   - Confirm that slicers and filters propagate correctly across pages.  

10. **Publish**  
    - Once satisfied, publish to Power BI Service (or keep as .pbix for distribution).  

--- 

**End of guide**.  

All JSON and DAX files have been created and are ready for use.
# Tooltip Specification

This document defines the design and content guidelines for custom tooltip pages in the Power BI report. Tooltips provide contextual detail-on-demand when users hover over data points in visuals, enhancing insight without cluttering the main view.

## Purpose
- Show detailed information about a specific data point (e.g., a transaction, merchant, or time period)
- Keep report pages clean by moving secondary information to tooltips
- Provide a consistent look and feel that matches the report’s design system

## General Tooltip Properties
- **Page Size**: Set to “Tooltip” (default 320 × 240 pixels) or a custom size that fits the content (maximum recommended: 400 × 400)
- **Background**: Card Background (`#111827`)
- **Border**: 1px solid Border (`#243044`)
- **Border Radius**: 6px
- **Padding**: 12px on all sides (inside the border)
- **Shadow**: 0px 4px 12px rgba(0,0,0,0.15) (if supported via shape effects; otherwise accept flat)
- **Layout**: Vertical stack, clear visual hierarchy, ample white space (using the 4px grid)

## Content Hierarchy
Organize tooltip information in the following order (most to least important):
1. **Title** (optional): Identifies the context (e.g., “Merchant: Acme Corp”)
2. **Primary Identifiers**: Key IDs or names (e.g., Transaction ID, Date)
3. **Key Metrics**: The main values the user needs to see (e.g., Amount, Approval Status)
4. **Secondary Details**: Additional context (e.g., Merchant Info, Customer Info)
5. **Flags & Indicators**: Status indicators (e.g., Refunded, Chargeback)
6. **Small Visuals** (optional): Sparkline, mini bar, or icon array if space permits

## Text Styles
- **Title**: 
  - Font: Segoe UI, SemiBold (600)
  - Size: 12pt
  - Color: Primary Text (`#F8FAFC`)
  - Margin Bottom: 4px (1 unit)
- **Labels**: 
  - Font: Segoe UI, Regular (400)
  - Size: 11pt
  - Color: Secondary Text (`#94A3B8`)
- **Values**: 
  - Font: Segoe UI, SemiBold (600) or Regular)) or Bold (700) for emphasis
  - Size: 11pt
  - Color: Primary Text (`#F8FAFC`)
- **Units & Formatting**: 
  - Currency: Prefix with appropriate symbol (e.g., `$`, `€`) or use format string
  - Percentages: Show with “%” suffix, 1 or 2 decimal places as appropriate
  - Dates: Format as `MMM D, YYYY` or `D MMM YYYY` for brevity
  - Integers: No decimal places

## Layout Patterns
### 1. Label‑Value Pairs (Most Common)
```
[Label:]      [Value]
```
- Use a monospaced alignment or two‑column table effect:
  - Left-align labels in a column (~120px width)
  - Left-align values in a second column (remaining width)
  - Optional: Right-align values for numeric columns to facilitate scanning
- Add 8px (2 units) vertical spacing between rows
- Use a 1px solid border at 20% opacity (`#243044` at 0.2) as a row separator if desired (optional)

### 2. Sectioned Tooltip
For more complex tooltips, divide into sections with a subtle divider:
- Section Header: Bold, 11pt, Primary Text, margin 6px top, 2px bottom
- Divider: 1px solid `#243044` at 10% opacity, margin 4px vertical
- Then list items as label‑value pairs

### 3. With Icon
- Place an 16 × 16px icon to the left of a label‑value pair
- Icon color: Secondary Text (`#94A3B8`) or semantic color if meaningful (e.g., red for warning)
- Space between icon and label: 8px (2 units)

### 4. Mini Sparkline or Bar
- If including a small trend chart (e.g., daily value over last 7 days):
  - Height: 20‑24px (5‑6 units)
  - Width: Tooltip width minus padding (approx 276px)
  - Margins: 12px top, 12px bottom
  - Axis: Hide axes, gridlines, and labels; rely on the shape of the line
  - Line Color: Accent Blue (`#3B82F6`) or Primary Violet (`#7C3AED`)
  - Point Size: 2px radius if showing points
  - Background: Transparent or Card Background at 10% opacity

## Specific Tooltip Instances

### 1. Merchant Tooltip (Assigned to Executive Overview → Top‑10 Merchants bar chart)
**Purpose**: Show merchant‑level KPIs and a mini trend.
**Content**:
- Title: “Merchant: [MerchantDisplayName]”
- List:
  - Merchant ID: [MerchantKey]
  - Total Transactions: [Total Transactions] (integer)
  - Approval Rate: [Approval Rate] (percentage)
  - Refund Ratio: [Refund Ratio] (percentage)
  - Chargeback Ratio: [Chargeback Ratio] (percentage)
  - Average Transaction Value: [Average Transaction Value] (currency)
- Sparkline: Daily Transaction Value (last 30 days)
  - Type: Line chart, no axes
  - Line Color: #3B82F6
  - Height: 20px

### 2. Transaction Tooltip (Assigned to Transaction Diagnostics visuals)
**Purpose**: Show full transaction details.
**Content**:
- No title (or “Transaction Details”)
- List:
  - Transaction ID: [TransactionID]
  - Timestamp: [TransactionTimestamp] (format: MMM D, YYYY h:mm TT)
  - Amount: [TransactionAmount] (currency)
  - Currency: [CurrencyCode] (if multi‑currency)
  - Merchant: [MerchantDisplayName]
  - Customer: [CustomerID]
  - Approval Status: [If Approved then “Approved” else “Declined”]
  - Decline Reason: [DeclineReason] (if blank, show “N/A”)
  - Refunded: [Yes/No] (based on RefundFlag or RefundAmount > 0)
  - Refund Amount: [RefundAmount] (if > 0)
  - Chargeback: [Yes/No] (based on ChargebackFlag or ChargebackAmount > 0)
  - Chargeback Amount: [ChargebackAmount] (if > 0)
- Optional: Small bar showing refund and chargeback amounts relative to transaction amount (if space permits)

### 3. Geography Tooltip (Assigned to Map visuals)
**Purpose**: Show location‑specific aggregates.
**Content**:
- Title: “[CityName], [MarketDisplayName]” (or just country if city not used)
- List:
  - Transaction Count: [Count of Transactions] (integer)
  - Total Value: [Sum of TransactionAmount] (currency)
  - Approval Rate: [Approval Rate] (percentage)
- Optional: Mini bar of daily trend (last 14 days)

### 4. Decline Reason Tooltip (Assigned to Decline Reason bar chart)
**Purpose**: Show details for a specific decline reason.
**Content**:
- Title: “Decline Reason: [DeclineReason]”
- List:
  - Count: [Count of Transactions with this reason] (integer)
  - Percentage of Total Declines: [Percentage] (percentage)
  - Total Value: [Sum of TransactionAmount for these transactions] (currency)
  - Example Transaction IDs: [List of up to 3 IDs] (if space permits)

### 5. Anomaly Tooltip (Assigned to Anomaly bar chart in Data Quality page)
**Purpose**: Explain an anomaly type and show its frequency.
**Content**:
- Title: “[AnomalyType]”
- List:
  - Count: [Number of occurrences] (integer)
  - Description: [Brief explanation of what this anomaly means]
  - Example Criteria: [The rule that defines this anomaly, e.g., “Refund amount > Transaction amount”]
  - Impact: [Brief note on potential impact, e.g., “May indicate data entry error or fraudulent refund”]

## Implementation Steps

### A. Create the Tooltip Page
1. In Power BI Desktop, insert a new page.
2. In the Fields pane, rename the page to the desired tooltip name (e.g., “Merchant Tooltip”).
3. With the page selected, in the Visualizations pane, change the Type to “Tooltip”.
4. Set the canvas size to 320 × 240 (or custom) via the Format pane → Page size → Type: Custom.
5. Design the layout using shapes, text boxes, and images (SVG/PNG) as needed.

### B. Add Content
1. Drag the relevant fields into the tooltip page (they will not auto‑bind; you must manually set text).
2. For each piece of information:
   - Insert a Text box
   - In the formula bar, enter the measure or field reference (e.g., `SELECTEDVALUE('FactTransactions'[TransactionAmount])`)
   - Format the text using the toolbar (font, size, color)
   - For conditional text (e.g., “Yes/No”), use a SWITCH or IF measure and display its result
3. Arrange the elements according to the layout patterns above.
4. Apply background color, border, border radius, and padding via the Format pane → Shape (if using a shape as background) or by setting the page background and adding a border via a rectangle shape.

### C. Assign the Tooltip to a Visual
1. Select the visual (chart, card, etc.) that should show the tooltip.
2. In the Visualizations pane, go to the Fields section.
3. Drag the desired fields (the ones used in the tooltip) to the **Tooltips** well.
   - Note: The values in the tooltip are driven by the fields dragged here, but the actual layout is defined on the tooltip page.
   - You must include at least one field in the Tooltips well for the tooltip to appear.
4. (Optional) To improve performance, limit the number of fields in the Tooltips well to only those actually used in the tooltip layout.

### D. Test the Tooltip
1. Enter Preview mode.
2. Hover over a data point in the parent visual.
3. Verify that the tooltip appears at the cursor location (or slightly offset).
4. Check that all values display correctly and are formatted as expected.
5. Ensure the tooltip does not flicker or disappear prematurely (avoid placing interactive elements inside).

### E. Performance Considerations
- Keep tooltip pages lightweight: avoid complex visuals or large images.
- Do not include slicers or other interactive elements in tooltips (they are not interactive by design).
- Limit the number of chart elements (e.g., sparklines should have few points).

## Accessibility
- Ensure text contrast meets WCAG 2.1 AA (use Primary Text on Card Background: 12.6:1 ✓)
- Provide meaningful information; do not rely solely on color to convey status
- If the tooltip contains a lot of information, consider whether it should be a drillthrough page instead

## References
- Power BI Tooltips Documentation: https://learn.microsoft.com/power-bi/create-reports/desktop-tooltips
- Design System Colors: see `design-system/design-tokens.md`
- Text Styles: see `design-system/typography.md`
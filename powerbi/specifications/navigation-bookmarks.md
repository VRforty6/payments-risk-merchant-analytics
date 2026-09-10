# Navigation Bookmarks Specification

This document defines the bookmark strategy for navigating between pages in the Payments Risk & Analytics Power BI report, including the navigation ribbon (collapsible sidebar) and contextual navigation (e.g., back button, drillthrough sync).

## Overview
Power BI Bookmarks capture the state of a report page, including filters, slicers, visual selections, and object visibility. We use bookmarks to:
- Implement a collapsible navigation ribbon with state (collapsed/expanded)
- Remember the last selected nav item (highlight the active page)
- Enable a reliable “Back” mechanism for drillthrough pages
- Optionally preserve slicer states when navigating between pages (if desired)

## Bookmark Naming Convention
Use the following format for all bookmarks:
```
[PageName]-[State]-[Variant if needed]
```
Examples:
- `Executive Overview-Default`
- `Executive Overview-NavExpanded`
- `Merchant Drillthrough-Default`
- `Back-Overview` (for a back button that returns to the overview)

## Required Bookmarks

### 1. Page View Bookmarks
Create one bookmark for each report page that sets:
- The active page (via the Page Navigator or hidden page selection)
- The navigation ribbon item for that page set to “Selected” state
- All other navigation ribbon items set to “Default” state
- The navigation ribbon collapsed or expanded based on user preference (see below)

| Page | Bookmark Name | Purpose |
|------|---------------|---------|
| Executive Overview | `Executive Overview-Default` | Show the overview page with nav in default state (usually collapsed) |
| Merchant Risk Analysis | `Merchant Risk Analysis-Default` | Show the merchant risk page |
| Transaction Diagnostics | `Transaction Diagnostics-Default` | Show the transaction diagnostics page |
| Data Quality & Reconciliation | `Data Quality & Reconciliation-Default` | Show the data quality page |
| Merchant Drillthrough | `Merchant Driftthrough-Default` | Show the merchant drillstep page (note: this is a drillthrough page; its state is largely driven by the drillthrough context, but we can still set the nav highlight) |

### 2. Navigation Ribbon State Bookmarks
To handle the collapsible nav, we create two additional bookmarks that toggle the ribbon width and the visibility of text labels.

| Bookmark Name | Purpose |
|---------------|---------|
| `Nav-Collapsed` | Set navigation ribbon to 64px width, hide text labels, show only icons |
| `Nav-Expanded` | Set navigation ribbon to 240px width, show icons and text labels |

These bookmarks modify:
- Width of the nav background rectangle
- Visibility property of the text label elements in each nav item group
- (Optional) Adjust the left margin/page offset of header and content if designing for two layouts

### 3. Nav Item Selection Bookmarks (Alternative Approach)
If not using the page bookmarks to set nav states, we can create separate bookmarks for each nav item state. However, the recommended approach is to include the nav state within each page’s default bookmark.

#### Example: Setting Nav State in Page Bookmark
When creating the `Executive Overview-Default` bookmark:
1. Navigate to the Executive Overview page.
2. Ensure the navigation ribbon is in the desired default state (e.g., collapsed).
3. Ensure the “Executive Overview” nav item is highlighted (selected state).
4. Capture the bookmark.

Repeat for each page.

### 4. Back Button Bookmark
Power BI automatically generates a bookmark for the “Back” action when a drillthrough page is used. However, for explicit back buttons (e.g., on a drillthrough page to return to the calling page), we can rely on the built‑in behavior.

If a custom back button is needed (e.g., to return to a specific page regardless of drillthrough history), create a bookmark that:
- Navigates to the target page
- Sets the nav highlight appropriately
- Sets the nav ribbon to the desired collapsed/expanded state

Example:
- `Back-To-Overview`: Navigates to Executive Overview page, sets nav highlight to “Executive Overview”, sets nav to collapsed.

### 5. Slicer State Preservation (Optional)
If you want slicer selections to persist when navigating between pages (e.g., a date range chosen on the overview stays selected when you go to merchant risk), include the slicer state in the page bookmarks.

**Procedure**:
1. Set the desired slicer state (e.g., date slicer to “Last 60 days”)
2. Navigate to the target page
3. Update the nav highlight and ribbon state as needed
4. Create/update the bookmark for that page

This ensures that when you go from Overview → Merchant Risk, the date range remains as set.

If you do **not** want slicer states to persist (each page starts with its default slicer state), then do not include the slicer state in the bookmark; leave the slicer set to its default when creating the bookmark.

### Implementation Steps

#### A. Create the Navigation Ribbon
1. Build the navigation ribbon as a group of items (each item: background shape, icon, text label).
2. Set initial state (e.g., collapsed: width 64px, text labels hidden).
3. Name all elements in the Selection pane using the convention from `specifications/selection-pane-order.md`.

#### B. Build Each Report Page
1. Arrange the page according to its specification.
2. Set any default slicer states you want to be the baseline for that page.

#### C. Create Page Bookmarks
For each page:
1. Navigate to the page.
2. Ensure the ribbon is in the desired default state (consult UX decision: collapsed by default?).
3. Ensure the correct nav item is highlighted.
4. If preserving slicer state, set the slicers as desired for cross‑page consistency.
5. Open the Bookmarks pane, click “Add”, and rename the bookmark to `[PageName]-Default`.
6. Update the bookmark (right‑click → Update) whenever the page layout or default state changes.

#### D. Create Nav Toggle Bookmarks (Optional)
If you want a button to toggle the nav collapsed/expanded state:
1. Create two bookmarks: `Nav-Collapsed` and `Nav-Expanded`.
   - For `Nav-Collapsed`: set nav width to 64px, hide all text labels.
   - For `Nav-Expanded`: set nav width to 240px, show all text labels.
2. Assign these bookmarks to a toggle button (e.g., a hamburger icon) using the “Bookmark” action type.
   - Note: A single button cannot toggle between two states with built‑in bookmarks; you need to use a button that cycles states via custom logic or use two separate buttons (one for collapse, one for expand). Alternatively, use a bookmark that toggles a hidden bookmark page with JavaScript‑like behavior (not native). In practice, many designers use two separate buttons or accept that the button only goes to one state and the user must use another button to reverse.
   - Simpler: Provide a button that always sets the nav to expanded (or collapsed) and rely on the user to click again to return to the default state via the page’s default bookmark (if the nav state is part of the page bookmark). This requires two bookmarks per page: one for collapsed, one for expanded.

#### E. Assign Bookmarks to Navigation Items
For each nav item (icon/group) in the ribbon:
1. Set its action to “Bookmark”.
2. Choose the corresponding page’s default bookmark (e.g., the “Home” icon goes to `Executive Overview-Default`).
3. Set tooltip to the page name.

#### F. Test
1. Click each nav item: verify it goes to the correct page and highlights the correct nav item.
2. Test the nav toggle button (if implemented): verify it expands/collapses the ribbon and updates the visibility of text labels.
3. If preserving slicer state: set a slicer on one page, navigate to another, verify the slicer retains its setting; navigate back, verify it’s still set.
4. Test the back button on drillthrough pages: verify it returns to the correct previous state.

## Advanced: Synchronized Nav State Across Pages
If you want the nav ribbon to retain its collapsed/expanded state as the user navigates (i.e., clicking a nav item does not reset the ribbon to a default), then do **not** include the nav width and label visibility in the page bookmarks. Instead:
- Create a separate set of bookmarks that only control the nav state (`Nav-Collapsed`, `Nav-Expanded`) and assign them to a toggle button.
- The page bookmarks only set the page and nav highlight.
- This way, the nav state persists until the user toggles it.

Choose one of the two approaches:
**A. Nav State Tied to Page** (simple): Each page bookmark includes the desired nav state for that page. Nav state changes when you change pages.
**B. Nav State Independent** (advanced): Nav state is controlled by a separate toggle and persists across page changes.

For most reports, **Option A** is sufficient and easier to implement.

## References
- Power BI Bookmarks Documentation: https://learn.microsoft.com/power-bi/create-reports/desktop-bookmarks
- Selection Pane and Naming: see `specifications/selection-pane-order.md`
# Customer Behavior & Marketing Campaign Analysis

End-to-end marketing analytics project: SQL → Python → Power BI, built on a 2,240-customer retail loyalty dataset, to answer one core question — **which customers actually respond to marketing, and what drives their spending?**

## Overview

The dataset represents loyalty-club customers of a boutique wine & specialty-food retailer: demographics (age, income, marital status, household composition), purchase history across product categories and channels (web, store, catalog, deals), and response history to five past marketing campaigns.

The goal wasn't just to describe the data — it was to answer questions a marketing team would actually ask: *who should we target, through which channel, and what's it worth to reach them?*

## Tools

- **SQL Server** — customer segmentation queries, revenue breakdowns by demographic and behavioral group
- **Python** (Pandas, Matplotlib, Seaborn, Plotly) — exploratory analysis, visualization, written insights per chart
- **Power BI** — a 21-page interactive report with its own navigation menu, structured around six explicit research questions (customer profile, household segmentation, consumer behavior, income segmentation, catalog & age analysis, household-type analysis), using treemaps, heatmaps, 100%-stacked charts, and KPI cards throughout

## Key Findings

- **Campaign exposure is the single strongest driver of spend.** Customers who were exposed to at least one campaign spend **2.5x more on average** than customers who weren't — despite making up only ~27% of the customer base, exposed customers account for a disproportionate share of total revenue.
- **Exposure also changes *how* people buy.** Campaign-exposed customers buy more through catalog and online channels; non-exposed (organic) customers lean on discounts and physical stores — they're price-driven because they aren't aware of the campaigns in the first place.
- **Married customers are the most stable, highest-value segment** — highest spend and most consistent behavior. Singles and widowed customers show lower, more dispersed spending, flagging an underserved segment worth targeting.
- **Income and product mix move in opposite directions.** High-income customers drive most revenue, but lower-income customers over-index on gold/jewelry products relative to their income — a conspicuous-consumption pattern with real targeting implications.
- **No-kids households are the core customer base**: over half of all customers, 74% of total revenue, and the heaviest spenders on wine and meat — a household segment with more disposable income and fewer competing expenses.
- **Age 69–79 customers spend the most per person**, even though they don't generate the most total revenue — a small, high-value segment that's easy to overlook by looking at total revenue alone.

## Repository Contents

| File | Description |
|---|---|
| `customer-analysis.sql` | SQL Server queries: segmentation by marital status, income tier, age group, household type, and campaign-response category |
| `customer-analysis.ipynb` | Python notebook: full exploratory analysis, visualizations, and written insights for each finding |
| `customer-analysis.pbit` | Power BI template: 21-page interactive report, organized around six research questions, with a navigation menu and dedicated dashboards per segmentation angle |

## Skills Demonstrated

SQL (CTEs, window functions, conditional aggregation) · Python (Pandas, data visualization) · Power BI · customer segmentation · campaign response analysis · marketing analytics

# Architecture Overview

## High-Level Architecture

The Payments Risk & Merchant Analytics portfolio project follows a layered architecture:

1. **Data Generation Layer** (Python)
   - Synthetic data generation using Faker, NumPy, Pandas
   - Configurable parameters and probability distributions
   - Validation using Great Expectations
   - Output: Raw CSV files stored in `data/raw/`

2. **Storage & Processing Layer** (SQL Server)
   - Staging schema: Raw data landing zone
   - Dimensional schema: Star schema for analytical queries
   - ETL pipelines: T-SQL stored procedures for data transformation and loading
   - Data quality checks: Audit tables and constraints
   - Reporting views: Pre-aggregated and filtered views for Power BI

3. **Semantic Model Layer** (Power BI)
   - Import mode model connecting to SQL Server views
   - DAX measures for KPIs and calculated columns
   - Row-level security (if required)
   - Custom themes and visualizations

4. **Presentation Layer** (Power BI)
   - Interactive reports across 5 pages:
     1. Executive Overview
     2. Merchant Risk Analysis
     3. Transaction Diagnostics
     4. Data Quality and Reconciliation
     5. Merchant Transaction Drillthrough
   - GitHub for version control, documentation, and presentation

## Key Architectural Decisions

### Schema Separation
- **Staging Schema**: Contains raw tables that mirror the CSV file structure exactly. Used for initial data loading and validation.
- **Dimensional Schema**: Implements a star schema with:
  - Fact table: `FactTransactions` (grain: one row per payment transaction attempt)
  - Dimension tables: `DimDate`, `DimMerchant`, `DimCustomer`, `DimGeography`, `DimPaymentMethod`, `DimTransactionStatus`
  - Additional tables: `FactMerchantDailyPerformance` (or equivalent reporting view), `AuditDataQuality`, `RejectedTransactions`
- This separation allows for:
  - Clear separation of concerns between raw ingestion and optimized analytics
  - Ability to rerun ETL from raw data without regenerating source files
  - Independent optimization of staging (for load) vs dimensional (for query) schemas

### Data Flow
1. Python generator creates synthetic CSV files in `data/raw/`
2. SQL ETL processes:
   - Load raw data into staging tables
   - Validate and cleanse data
   - Insert into dimensional model
   - Log data quality issues to `AuditDataQuality`
   - Route invalid records to `RejectedTransactions`
3. Power BI connects directly to SQL Server views (or imported model) for reporting
4. All artifacts (code, SQL, documentation) versioned in GitHub

## Technology Choices

- **Python**: Chosen for its rich ecosystem in synthetic data generation (Faker), data manipulation (Pandas), and validation (Great Expectations)
- **SQL Server**: Selected as a robust, industry-standard relational database with strong analytical capabilities
- **Power BI**: Chosen for its powerful DAX language, integration with SQL Server, and enterprise-ready reporting features
- **GitHub**: Used for version control, issue tracking, and project presentation

## Assumptions

### Data Volumes: 10010

We are not in our implementation is database layer: we have no change.

Note: This architecture avoids any claims of being a production payment processing system. it is purely an analytics portfolio project.
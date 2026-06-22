# SQL Data Warehouse & ELT Pipeline Project

Data Warehouse project using SQL, ELT, data modeling, and analytics to transform raw data into meaningful business insights.

## Project Overview
This project demonstrates the end-to-end design and implementation of a centralized enterprise Data Warehouse using Microsoft SQL Server. The primary goal was to ingest, clean, and model disorganized raw transactional data originating from two disparate source systems (CRM and ERP) into a consolidated, business-ready Star Schema. 

By establishing a structured Medallion Architecture, this pipeline transforms raw, noisy data into high-integrity analytical views capable of powering BI dashboards and executive decision-making.

## Data Warehouse Architecture
The project utilizes a three-layer data warehouse architecture to ensure data cleanliness, traceability, and high performance.

- **Bronze Layer (Raw Ingestion):** Direct, 1:1 ingestion of raw data from source systems (CRM & ERP) without modifications.
- **Silver Layer (Cleaned & Standardized):** The heavy-lifting ETL layer. Data types are standardized, trailing spaces are removed, missing keys are filled, historical date overlaps are fixed, and duplicated records are completely resolved.
- **Gold Layer (Presentation Layer):** A dimensional model (Star Schema) exposed via views optimized for fast user queries, BI reporting, and business analytics.

## Key Engineering Features & Solutions Implemented

### 1. Robust Data Quality & Profiling Framework
Before loading data into the Silver layer, a comprehensive data profiling suite was built to isolate system anomalies. Key checks included testing primary key integrity, isolating string irregularities, mapping inconsistent category boundaries, and auditing logical math errors.

### 2. Advanced ETL & Data Standardization
- **Deduplication:** Utilized window functions (`ROW_NUMBER() OVER (PARTITION BY... )`) to gracefully discard duplicate entries and preserve only the latest operational entity state.
- **Key Reconciliation:** Dynamically stripped disparate system-specific prefixes (e.g., removing the 'NAS' prefix and string hyphens from ERP customer IDs) to guarantee flawless cross-system relationships back to CRM master records.
- **Business Logic & Math Corrections:** Re-computed corrupted transaction metrics inside the fact tables where Sales != Qty * Price, and backward-derived unit pricing where master values were zero or null.
- **Dynamically Fixing Overlapping Dates:** Resolved a chronic data entry bug where a product's end date preceded its start date by writing dynamic look-ahead expressions (`LEAD() OVER (...) - 1`) to accurately timeline product versions.

### 3. Production-Grade Pipeline Control
The Silver ETL pipeline is fully encapsulated within automated Stored Procedures featuring:
- Robust `TRY...CATCH` Error Handling blocks to securely log execution exceptions.
- Comprehensive performance profiling variables tracking the exact duration of each table's transformation load cycle as well as total batch time.

## Dimensional Data Model (Gold Star Schema)
The final presentation layer exposes a user-friendly Star Schema optimized for high-performance BI tool integration.

- **Fact Table:** `gold.fast_sales` – Operational sales revenue lines, unit quantities, and absolute pricing.
- **Dimension Tables:**
- `gold.dim_customer` – Master unified customer profiles including cleaned demographics, location data, and geographical mapping.
- `gold.dim_product` – Active inventory profiles with isolated categories, subcategories, and unit costs.

## Tech Stack & Skills Demonstrated
- **Database Engine:** Microsoft SQL Server (T-SQL)
- **Architecture:** Medallion Data Pipeline Design (Bronze -> Silver -> Gold)
- **Modeling:** Dimensional Modeling (Star Schema, Fact & Dimension Designs)
- **Advanced SQL:** Window Functions (ROW_NUMBER, LEAD), Dynamic Expressions (COALESCE, NULLIF), Conditional Transforms (CASE WHEN), Execution Scripting (TRY...CATCH, Performance Profiling Timers).

## How to Run the Project
1. Clone the repository to your local machine.
2. Execute the scripts in sequence to build the environment:
- `01_create_bronze_tables.sql`
- `02_load_silver.sql`
- `03_create_gold_views.sql`
3. Execute the operational pipeline procedure to transform and populate your warehouse:
```sql
EXEC silver.load_data;

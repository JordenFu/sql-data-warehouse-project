# Data Warehouse and Analytics Project

This project demonstrates a data warehousing and analytics solution, spanning the development of a data warehouse to the generation of insights. This is my first hands-on data warehouse project. It highlights industry practices in data engineering and analytics.

## Project Overview

This project involves:
1. **Data Architecture**: Designing a modern data warehouse using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**:  Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics and Reporting**: Creating SQL-based reports for basic and advanced insights.

This repository is my first SQL end-to-end project to showcase expertise in:
* SQL Development
* Data Architect
* Data Engineering
* ETL Pipeline Developer
* Data Modeling
* Data Analytics

---

## Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.  

---

## Data Architecture

The data architecture for this project follows Medallion Architecture Bronze, Silver, and Gold layers:

![Data Architecture](docs//DW_figure.png)

1. **Bronze Layer**:
Stores raw data ingested directly from source systems without transformation. Data is loaded from CSV files into a SQL Server database in its original format.

2. **Silver Layer**:
Responsible for data cleansing, standardization, and normalization. This layer refines raw data to ensure consistency, quality, and suitability for downstream processing.

3. **Gold Layer**:
Contains business-ready, curated datasets modeled using a star schema. This layer is optimized for reporting, analytics, and consumption by BI tools.

---

## Data Flow

This diagram illustrates data provenance and inter-schema relationships across the Bronze, Silver, and Gold schemas—covering lineage, dependencies, and referential links.

![Data Flow](docs//data_flow.png)

---

## Data Mart

**Star Schema:** This diagram presents the business-ready data mart where `gold.fact_sales` stores transactional measures (e.g., `sales_amount`, `quantity`, `price`) and references `gold.dim_customers` and `gold.dim_products` through **surrogate keys** (`customer_key`, `product_key`). The star design clarifies table relationships, standardizes join paths, and simplifies analytics. Analysts can aggregate facts by any dimension (customer, product, category, time), quickly identify essential columns, and run consistent, performant queries for downstream reporting and ad-hoc analysis.

![Data Mart](docs//data_mart.png)

---

## Important Links:

This project is based on and adapted from the work of **DataWithBaraa**.  
Special thanks to the following original sources:

- GitHub Repository by DataWithBaraa:
  https://github.com/DataWithBaraa/sql-data-warehouse-project

- YouTube Tutorial by DataWithBaraa:
  https://www.youtube.com/@DataWithBaraa

All credit for the foundational architecture and concepts goes to the original author.

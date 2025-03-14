# Amazon-Sale-Report-Project (E-commerce)

Overview
This project analyzes e-commerce order data to uncover key business insights. We explore sales performance, shipping trends, and customer behavior, using Excel, SQL, Power BI, and Python.

## 📊 Dataset
- **Source:** Provided dataset
- **Size:** 74,538 rows, 23 columns
- **Main Columns:**

Example:
  - `Order ID`: Unique identifier for each order  
  - `Date`: Order date  
  - `Sales Channel`: Online or Offline sales  
  - `Amount`: Revenue from each order  
  - `Courier Status`: Whether the order was delivered on time

My Columns:

  - `index` : 
  - `Order ID` : Unique identifier for each order
  - `Date` : Date when the order is placed (Format: MM/DD/YYYY)
  - `Status` : Status of order since it was placed
  - `Fulfilment` : 
  - `Sales Channel` : 
  - `ship-service-level` : 
  - `Style` : 
  - `SKU` : 
  - `Category` : 
  - `Size` : 
  - `ASIN` : 
  - `Courier Status` : 
  - `Qty` : 
  - `currency` : 
  - `Amount` : 
  - `ship_city` : 
  - `ship-state` : 
  - `ship-postal-code` : 
  - `ship-country` : 
  - `promotion-ids` : 
  - `B2B` : 
  - `fulfilled-by` : 


## 📌 Process
### ✅ **Phase 1: Data Cleaning**
- Handled missing values & duplicates in SQL  
- Standardized column names  
- Fixed incorrect date formats  

### ✅ **Phase 2: Exploratory Data Analysis**
- Top-selling product categories  
- Sales trends over time  
- Most common shipping destinations  

**Power BI Dashboard:**
![Sales Dashboard](images/dashboard_screenshots.png)
- Connected to database in MySQL
- Transform data: Select correct data format & type (Add geographical data categories to columns: ship_country,ship_postal_code)
- Add calculated columns "ship_location" (combining ship_state, ship_country) using DAX formula & assigned "Place" category for consistent mapping
- Added Map
- Added Line graph
- Added Slicer
- Added Pie Chart for ship_status


**Excel Analysis:**
![Pivot Table Insights](images/Excel_Analysis.png)


### ✅ **Phase 3: Advanced Analysis (DAX & SQL)**

**SQL:**
- Wrote query to find Month over Month Total Sales using CTEs and Window Functions (LAG())


## 📈 Key Insights
- 💰 **Top-Selling Category:** Electronics  
- 🚚 **Most Used Courier:** DHL  
- 🌍 **Top Market:** US & Germany  

## 💾 How to Use
1. Download `dashboards.pbix` to explore the Power BI visualizations  
2. Open `analysis.xlsx` to see Excel pivot tables  

---

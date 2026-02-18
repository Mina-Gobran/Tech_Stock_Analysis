# Tech Stock Performance Analysis (2023-2025)

![Dashboard Preview](images/Tech_stock_Dashboard.gif)

**A complete data pipeline analyzing 3 years of stock performance across 7 major tech companies.**

---

## Quick Links
[Overview](#overview) • [Key Findings](#key-findings) • [Tech Stack](#tech-stack) • [How I Built This](#how-i-built-this) • [What I Learned](#what-i-learned)

---

## Overview

This project explores stock market trends for Apple, Microsoft, Google, Amazon, Nvidia, Meta, and Tesla from 2023 to 2025. I built an end-to-end analytics solution: collecting data via API, storing it in PostgreSQL, analyzing it with SQL, and visualizing insights in Power BI.

**Why this project?** I wanted to understand which tech stocks performed best during this period and what patterns could inform investment decisions. More importantly, I wanted to demonstrate my ability to handle real-world data from acquisition to visualization. (still learning more)

You can find the Power BI file here: [Teck_stock_viz](Tech_stock_viz.pbix)

### What's Inside
- 5,257 records of daily stock data
- Automated Python data collection
- PostgreSQL database with custom analytics tables
- 10+ interactive Power BI visualizations
- SQL queries for volatility analysis, moving averages, and performance metrics

---

## Key Findings

### Best Performers
1.   **NVDA dominated** with **+319.1%** growth from 2023-2025 far outpacing competitors.
2.   **META** came in second at **+156.4%** growth despite having the lowest trading volume, suggesting high-conviction buying.
3.   **AMZN** - Strong performer at **+78.6%**

### Risk Profile
1. **TSLA** proved most volatile on a percentage basis (2.22% average daily swing).
2.  while **AAPL** and **MSFT** offered the most stability. **NVDA** balanced high returns with moderate risk, making it the strongest risk-adjusted performer.

### Timing Matters
Trading volume peaked on Fridays across 5 out of 7 stocks. Q4 (October-December) consistently showed the strongest returns. April 9, 2025 stood out as an unusual day with 7 stocks posting their best single-day gains simultaneously.

### Volume Trends
Despite rising prices, overall trading volume declined steadily:
- **2023**: 203.4 billion shares
- **2024**: 159.5 billion shares  
- **2025**: 122.5 billion shares

This suggests consolidation as fewer shares changed hands while prices climbed.

---

## Tech Stack

**Data Collection**
- Python (pandas, yfinance) - API integration and data preprocessing
- Jupyter Notebook - Interactive development

**Database & Analysis**  
- PostgreSQL - Data storage with 5,200+ records
- SQL - Window functions, CTEs, complex aggregations
- pgAdmin - Database management

**Visualization**
- Power BI - Interactive dashboards
- DAX - Custom calculations

**Development**
- VS Code - SQL query development
- Git/GitHub - Version control
- Anaconda - Python environment

---

## How I Built This

### Step 1: Data Collection

I used Python's yfinance library to pull historical stock data from Yahoo Finance. The script loops through each stock ticker, downloads price and volume data, then combines everything into a single dataset.

```python
import yfinance as yf
import pandas as pd

stocks = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'NVDA', 'META', 'TSLA']
stock_data = {}

for stock in stocks:
    ticker = yf.Ticker(stock)
    df = ticker.history(start='2023-01-01', end='2025-12-31')
    df['Symbol'] = stock
    stock_data[stock] = df

combined_df = pd.concat(stock_data.values(), ignore_index=True)
combined_df.to_csv('tech_stocks_2023_2025.csv', index=False)
```

### Step 2: Database Setup

I loaded the CSV into PostgreSQL and created a cleaned analysis table. This involved type conversions, calculating daily metrics, and adding time dimensions for easier querying.

```sql
CREATE TABLE stock_analysis AS
SELECT 
    "Symbol",
    "Date"::date as trade_date,
    ROUND("Close"::numeric, 2) as close_price,
    ROUND((("Close" - "Open") / "Open" * 100)::numeric, 2) as daily_return_pct,
    EXTRACT(YEAR FROM "Date"::date) as year,
    EXTRACT(MONTH FROM "Date"::date) as month,
    TO_CHAR("Date"::date, 'Month') as month_name
FROM stock_prices
WHERE "Close" IS NOT NULL AND "Volume" > 0;
```

### Step 3: Advanced Metrics

I created a second table with moving averages and volatility calculations using SQL window functions. These help smooth out daily noise and identify trends.

```sql
CREATE TABLE stock_metrics AS
SELECT 
    *,
    -- 7-day moving average
    ROUND(AVG(close_price) OVER (
        PARTITION BY "Symbol" 
        ORDER BY trade_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )::numeric, 2) as ma_7day,
    
    -- 30-day moving average  
    ROUND(AVG(close_price) OVER (
        PARTITION BY "Symbol" 
        ORDER BY trade_date 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    )::numeric, 2) as ma_30day,
    
    -- Volatility (7-day standard deviation)
    ROUND(STDDEV(close_price) OVER (
        PARTITION BY "Symbol" 
        ORDER BY trade_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )::numeric, 2) as volatility_7day
FROM stock_analysis;
```

### Step 4: Analysis Queries

I wrote SQL queries to answer specific business questions:
- Which stock had the best overall performance?
- How did monthly patterns differ across stocks?
- What days saw the biggest gains or losses?
- How did year-over-year trends compare?

Example - finding the most volatile stocks:

```sql
SELECT 
    "Symbol",
    ROUND(STDDEV(close_price)::numeric, 2) as price_std_dev,
    ROUND(AVG(daily_range)::numeric, 2) as avg_daily_range,
    ROUND(AVG(ABS(daily_return_pct))::numeric, 2) as avg_abs_daily_return,
    ROUND(MAX(ABS(daily_return_pct))::numeric, 2) as max_daily_swing
FROM stock_metrics
GROUP BY "Symbol"
ORDER BY price_std_dev DESC;
```

**Result:** TSLA showed the highest percentage volatility (21.14% max daily swing), while META had the largest absolute price swings ($12.25 avg daily range).

### Step 5: Power BI Dashboard

I connected Power BI to my PostgreSQL database and built 10 visualizations:
- Line chart showing price trends over time
- Scatter plot for risk vs. return analysis
- Bar charts comparing year-over-year performance
- Heatmap of trading volume by month
- Table of top 10 best trading days

The dashboard includes slicers for filtering by year, quarter, and stock symbol, making it interactive and easy to explore.

---

## What I Learned

**Technical Skills**
- Working with financial APIs and time-series data
- Using SQL window functions for moving averages and running calculations
- Building normalized databases and optimizing query performance
- Creating interactive dashboards that non-technical users can understand

**Business Insights**
- High growth doesn't always mean high risk (see NVDA)
- Trading volume patterns can reveal investor sentiment
- Seasonal trends exist even in volatile tech stocks
- Price stability varies dramatically even among similar companies

**Challenges Solved**
- Handling date inconsistencies across different stock tickers
- Deciding between storing calculated metrics vs. computing on-the-fly
- Balancing dashboard detail with usability
- Making technical analysis accessible to non-finance audiences

---

## Dashboard Highlights

### Main Price Trends
![Stock Trends](images/Tech_stock_Dashboard.gif)
Multi-line chart showing all 7 stocks over the 3-year period. NVDA's dramatic rise is immediately visible.

### Key Visualizations
| Visual | Purpose |
|--------|---------|
| **Stock Price Trends** | Compare performance across all stocks over time |
| **Risk vs Reward Scatter** | Identify which stocks offered best risk-adjusted returns |
| **Year-over-Year Bars** | See how each stock performed in 2023, 2024, 2025 |
| **Volume Heatmap** | Spot patterns in trading activity by month |
| **Top 10 Days Table** | Highlight the biggest single-day gains |

---

## Project Files

```
Tech-Stock-Analysis/
│
├── notebooks/
│   └─ stock_data_collection.ipynb    # Python data acquisition
│
├── sql/
├── ├── 1.Stock_Analysis_Data_inspection
│   ├── 2.Stock_Analysis_Data_Cleaning.sql              # Create cleaned tables
│   ├── 3.Stock_Analysis_Calulated_etrics_calculation.sql        # Moving averages, volatility
├── ├── 4.Exploratory_Analysis.sql
│   └── analysis_queries.sql           # Business question queries
│
├── data/
│   └── tech_stocks_2023_2025.csv (along with other json from queries I turned into csv)     # Raw data from API
│
├── images/
│   └── Tech_stock_Dashboard.gif      # Dashboard preview
│
└── README.md                          # This file
```

---

## How to Reproduce

**Prerequisites:**
- Python 3.x with pandas and yfinance
- PostgreSQL 14+
- Power BI Desktop

**Steps:**
1. Clone this repository
2. Run `Tech_stock_analysis.py` to download data
3. Execute SQL scripts in order (cleaning → metrics → analysis)
4. Open Power BI and connect to your PostgreSQL database
5. Import the dashboard file or recreate using the screenshots

---

## Skills Demonstrated

**Technical**
- Python automation and API integration
- SQL (window functions, CTEs, complex joins)
- Database design and optimization
- Power BI dashboard development
- Data cleaning and validation

**Analytical**
- Financial metrics (volatility, returns, moving averages)
- Time-series analysis
- Risk assessment
- Pattern recognition
- Data-driven storytelling

**Business**
- Translating technical analysis into actionable insights
- Understanding investor behavior through volume analysis
- Identifying market trends and seasonal patterns
- Creating stakeholder-ready visualizations

---

## Future Enhancements


If I continue this project after I finalize taking my Advanced Google Data Analytics certificate on Coursera, I'd like to:
- Add real-time data updates via scheduled Python scripts
- Include sector comparison (tech vs. other industries)
- Build predictive models for short-term price movements
- Add correlation analysis between stocks
- Create automated alerts for unusual trading patterns

---

## Contact

**Mina Gobran**  
📧 Minamaher009@gmail.com  
💼 [LinkedIn](https://www.linkedin.com/in/mina-gobran-02793029b/)  
📂 [Portfolio](https://github.com/Mina-Gobran/Mina_Data_Analyst_Portfolio)

---

*Built as part of my data analytics portfolio. Feedback welcome!*
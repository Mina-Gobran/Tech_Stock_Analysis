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

### Performance Winners

1. NVDA absolutely crushed it with **+1,211% growth**, going from $14.30 to $187.54. At its peak, it hit $207.03 for a **+1,353%** gain. To put that in perspective: a $10,000 investment in early 2023 would be worth $131,000 by the end of the analysis period.

2. META came in second at **+438%** (from $123.87 to $665.95), which is interesting because it had the lowest trading volume at just 18.1M shares per day. Lower volume but massive growth usually points to strong institutional confidence—big players making calculated moves rather than a lot of retail noise.

3. Even the worst performer, MSFT, still doubled your money with **+108% growth**. When your "loser" still gives you 2x returns over three years, you know it was a strong bull market for tech.

### Risk vs. Reward

1. NVDA wasn't just the winner in returns—it also had the best risk-adjusted performance. Growing 1,211% with a standard deviation of only 53.81 is impressive. Compare that to META's 438% growth with a 179.96 std dev, and NVDA starts looking like the smarter bet.

2. META turned out to be the riskiest stock with a $179.96 standard deviation and a potential 23.28% loss in a single day. TSLA wasn't far behind at 22.69% max daily swing—these are the stocks that keep you up at night.

3. On the flip side, AAPL was the safe choice with the lowest volatility (34.33 std dev) while still delivering solid **122%** returns. If you're risk-averse but still want good gains, AAPL proved you could have both.

### April 9, 2025: What Happened?

This date stood out immediately in the data. Four stocks posted their best (or near-best) single-day gains all on the same day:

- TSLA: +22.69% (literally its best day in the entire dataset)
- NVDA: +18.72%
- AAPL: +15.33%
- META: +14.76%

Something major moved the whole market that day. My guess? Fed announcement, breakthrough AI news, or some major regulatory change. This is exactly the kind of anomaly that deserves a deeper dive with news correlation to figure out what actually triggered it.

Interestingly, the worst day was January 27, 2025, when NVDA dropped -16.97%. Understanding both the best and worst days could reveal patterns in how these stocks react to external events.

### The Volume Decline Pattern

Here's something that caught my attention: while stock prices were climbing across the board, trading volume dropped by **40%** from 203.4 billion shares in 2023 down to 122.5 billion in 2025.

This usually means one of three things:
- Big institutional players are accumulating shares (fewer trades, bigger positions)
- Retail investors are sitting out at these higher price levels
- Supply is tightening as long-term holders refuse to sell

Why does this matter? When volume drops while prices rise, you're running out of new buyers. It's often a warning sign that a correction might be coming. Not always, but it's something to watch.

### Trading Patterns

- Fridays consistently saw the highest volume across most stocks (5 out of 7). This makes sense when you think about it—options expire weekly, traders don't want to hold positions over the weekend, and a lot of institutional rebalancing happens end-of-week.

- The other pattern that jumped out was Q4 performance. October through December showed the strongest returns year after year, backing up the whole "Santa Claus rally" thing even in volatile tech stocks.

### NVDA's Liquidity Advantage

- NVDA's daily volume averaged 357.5M shares—that's 3.2x more than TSLA, 6.3x more than AAPL, and almost 20x more than META. 

- This matters more than you might think. High liquidity means institutional investors can move in and out of large positions without moving the price too much. It's one reason why big money might prefer NVDA over some of the other high-growth stocks.

### Growth vs. Volume: An Unexpected Pattern

1. When I compared growth rates to trading volumes, I found something interesting: the highest-growth stocks (NVDA and META) didn't necessarily have the highest volumes. In fact, META had the lowest volume of the group.

2. This suggests the growth wasn't driven by retail hype and FOMO(Fear of missing out) buying (which usually shows up as massive volume spikes). Instead, it looks like professional investors identified these opportunities early and accumulated positions steadily before the broader market caught on.

3. Different smart money strategies for different stocks, which tells you the big players weren't just blindly buying everything tech—they had conviction in specific names for specific reasons.

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
-- Querying the Overall Stock performance
SELECT 
    "Symbol",
    ROUND(MIN(close_price)::numeric, 2) as lowest_price,
    ROUND(MAX(close_price)::numeric, 2) as highest_price,
    ROUND(AVG(close_price)::numeric, 2) as avg_price,
    ROUND(((MAX(close_price) - MIN(close_price)) / MIN(close_price) * 100)::numeric, 2) as price_growth_pct,
    ROUND(AVG(volume)::numeric, 0) as avg_daily_volume
FROM stock_metrics
GROUP BY "Symbol"
ORDER BY price_growth_pct DESC;
/*
1. NVDA’s Peerless Growth and Liquidity

NVDA is the undisputed leader in both growth and trading activity. It achieved a staggering 1,352.84% price growth, while simultaneously being the most liquid stock with an average daily volume of over 357 million shares. This combination of massive price appreciation and high volume indicates intense and sustained market demand.
2. META: High Value with "Low" Volume

Despite having the second-highest growth rate (536.81%) and the highest average price (478.06), META has the lowest average daily volume in the group (only ≈18 million shares). This suggests that META’s price movement is driven by high-conviction trades or a tighter supply of shares compared to "high-turnover" stocks like NVDA or TSLA.
3. Tesla’s Significant Price Swing

TSLA shows a very high level of historical volatility relative to its price. Its price range (the difference between its lowest and highest price) is roughly 1.42 times its average price. This confirms that while it has grown significantly (353.17%), it remains one of the most erratic stocks for investors to hold in terms of price stability.
4. The Stability of AAPL and MSFT

AAPL and MSFT act as the "stabilizers" of the tech sector. They have the lowest price growth (132.37% and 149.20% respectively) and the lowest range ratios (around 0.80). These stocks provide more predictable, steady returns compared to the hyper-growth and high-volatility nature of NVDA, META, or TSLA.
*/

-- Checking for monthly average price by stock
SELECT 
    "Symbol",
    year,
    month,
    month_name,
    ROUND(AVG(close_price)::numeric, 2) as avg_monthly_price,
    ROUND(SUM(volume)::numeric, 0) as total_monthly_volume,
    COUNT(*) as trading_days
FROM stock_metrics
GROUP BY "Symbol", year, month, month_name
ORDER BY "Symbol", year, month;
/*
1. Strong "Year-End" Price Rally

There is a clear seasonal trend where stock prices tend to peak toward the end of the year. December has the highest average monthly price across all symbols and years ($301.55), followed by November and October. Conversely, April represents the lowest average price point ($215.92), suggesting a broad "buy in spring, sell in winter" pattern in this dataset.
2. NVDA’s Volume Dominance in 2023

The single highest trading volume month for any stock occurred with NVDA in August 2023, with a staggering 13.6 billion shares traded. Interestingly, its average price that month was only $45.22. This indicates a massive period of accumulation or retail interest early in its growth cycle before it reached its higher price levels in 2024 and 2025.
3. Collective Peak Performance in 2025

While the overall market trended upward into late 2025, individual stocks hit their "all-time high" monthly averages at different times:

    META peaked earliest in August 2025 ($760.83).

    MSFT and NVDA peaked in October 2025.

    AAPL, GOOGL, and TSLA reached their highest monthly averages in December 2025. This suggests that while the tech sector was generally strong, the specific momentum shifted from social media (Meta) and chips (NVDA) toward consumer tech and EVs by the end of the year.
*/

-- Which stocks are most volatile (risky)?
SELECT 
    "Symbol",
    ROUND(STDDEV(close_price)::numeric, 2) as price_std_dev,
    ROUND(AVG(daily_range)::numeric, 2) as avg_daily_range,
    ROUND(AVG(ABS(daily_return_pct))::numeric, 2) as avg_abs_daily_return, -- Calculates the average size of the daily move.
    ROUND(MAX(ABS(daily_return_pct))::numeric, 2) as max_daily_swing -- Finds the single largest move (up or down). This helps identify the stock's "worst-case" or "best-case" scenario.
FROM stock_metrics
GROUP BY "Symbol"
ORDER BY price_std_dev DESC;
/*
1. META Experiences the Largest Price Swings

META stands out as the riskiest in terms of absolute price movement. It has the highest price standard deviation (179.96) and the largest average daily range ($12.25). This indicates that its share price fluctuates across a much wider dollar range on any given day compared to the other stocks in the list.
2. TSLA is the Leader in Percentage Volatility

While META moves more in total dollars, TSLA is the most volatile on a percentage basis. It has the highest average absolute daily return (2.22%) and the most extreme maximum daily swing (21.14%). This means that for an investor, Tesla carries the highest risk of significant percentage gains or losses in a single trading session.
3. AAPL and MSFT are the "Anchors" of Stability

Compared to their peers, AAPL and MSFT represent the lower end of the risk spectrum.

    AAPL has the lowest price standard deviation (34.33), meaning its price stays most consistent relative to its average.

    MSFT has the lowest average daily return (0.89%), suggesting it is less prone to the erratic percentage spikes seen in stocks like NVDA or TSLA.
*/

-- Top 20 best performing days
SELECT 
    "Symbol",
    trade_date,
    close_price,
    daily_return_pct,
    volume
FROM stock_metrics
WHERE daily_return_pct IS NOT NULL -- High Percentage = Best Performing Day
ORDER BY daily_return_pct DESC
LIMIT 20;
/*
Single Best Day: TSLA recorded the highest single-day return in the entire dataset, surging by 21.14% on April 9, 2025.

Market-Wide Surge (April 9, 2025): This specific date was a massive outlier for the tech sector. 7 of the top 20 best performance days occurred on this day alone, with stocks like AAPL, NVDA, META, AMZN, MSFT, and GOOGL all posting their best gains simultaneously.

TSLA’s High Upside Frequency: TSLA dominates the "Best Days" list, appearing 10 times out of the top 20 entries. This suggests that while other stocks are more stable, Tesla is the most likely to have explosive, high-percentage gain days.
*/

-- Top 20 worst performing days
SELECT 
    "Symbol",
    trade_date,
    close_price,
    daily_return_pct,
    volume
FROM stock_metrics
WHERE daily_return_pct IS NOT NULL
ORDER BY daily_return_pct ASC
LIMIT 20;
/*
Single Worst Day: TSLA also holds the record for the sharpest decline, dropping 12.03% on March 10, 2025.

NVDA’s Frequent Pullbacks: While Tesla had the single worst day, NVDA appeared most frequently on the "Worst 20" list with 9 entries. This indicates that NVDA experienced more frequent sharp corrections than its peers during this timeframe.

Extreme Volatility Week: There is evidence of extreme "see-saw" volatility in April 2025. April 8, 2025, saw 4 of the worst 20 performance days, immediately followed by the record-breaking "best day" for the market on April 9. This suggests a period of intense market uncertainty and rapid price swings.
*/

-- Comparing 2023 vs 2024 vs 2025 performances
SELECT 
    "Symbol",
    year,
    ROUND(AVG(close_price)::numeric, 2) as avg_yearly_price,
    ROUND(MIN(close_price)::numeric, 2) as yearly_low,
    ROUND(MAX(close_price)::numeric, 2) as yearly_high,
    ROUND(SUM(volume)::numeric, 0) as total_yearly_volume
FROM stock_metrics
GROUP BY "Symbol", year
ORDER BY "Symbol", year;
/*
1. NVDA’s Extraordinary Growth

NVDA is the standout performer in this dataset, showing an explosive increase in its average yearly price. Between 2023 and 2025, its price grew by approximately 320.77%. While it started with the lowest average price among the group in 2023, its rapid appreciation highlights its massive market momentum during this period.
2. META’s Price Dominance and Strong Recovery

META exhibited the second-highest growth rate at 157.47%. By 2025, it reached the highest average yearly price in the group at $668.43. This suggests a period of significant value creation or a strong recovery from previous years, positioning it as the "most expensive" stock per share in this list by 2025.
3. Consistent Decline in Trading Volume

A notable macro-trend across all these tech giants is the steady decline in total yearly trading volume.

2023: ≈203.4 Billion

2024: ≈159.5 Billion

2025: ≈122.5 Billion This trend indicates that while prices were generally rising, the frequency of shares being traded significantly slowed down over the three-year period.

4. High Volatility in Tesla (TSLA)

TSLA demonstrated the highest price instability, particularly in 2024. Its "volatility ratio" (the gap between yearly high and low relative to average price) hit 1.46 in 2024. This means the price swing for Tesla that year was nearly 1.5 times its average price, making it the most volatile stock among the "Magnificent Seven" in this data.
5. Google's (GOOGL) 2025 Price Spike

While most stocks showed steady upward trends, GOOGL experienced a massive price range in 2025. Its yearly high of $323.23 compared to its low of $144.30 resulted in a volatility ratio of 0.85, nearly double its volatility from the previous year (0.40). This suggests 2025 was a year of major price discovery or significant news events for Alphabet.
*/

-- Which days of the week have highest volume?
SELECT 
    "Symbol",
    day_of_week,
    ROUND(AVG(volume)::numeric, 0) as avg_volume,
    COUNT(*) as occurrences
FROM stock_metrics
GROUP BY "Symbol", day_of_week
ORDER BY "Symbol", avg_volume DESC;
/*
5 out of the 7 stocks had the highest average volume Fridays,
This Suggests that trading activity tends to pick up towards the end of the week.
*/


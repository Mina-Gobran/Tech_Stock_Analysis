/* Adding moving averages (for trend analysis)
 Moving Averages are techniques of technical analysis,
which smooth out price data to bring out trends in prices,
through the calculation of the mean of the prices over a specified period.
*/
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
    
    /* Volatility (7-day standard deviation) Volatility measures the rate and magnitude of price fluctuations,
     indicating the risk and uncertainty of an asset
     in the market. A higher volatility suggests greater price swings, while a lower volatility indicates more stable prices.*/
    ROUND(STDDEV(close_price) OVER (
        PARTITION BY "Symbol" 
        ORDER BY trade_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )::numeric, 2) as volatility_7day

FROM stock_analysis
ORDER BY "Symbol", trade_date;


-- Verifying the new table with moving averages and volatility
SELECT * FROM stock_metrics 
WHERE "Symbol" = 'AAPL' 
ORDER BY trade_date DESC 
LIMIT 20;
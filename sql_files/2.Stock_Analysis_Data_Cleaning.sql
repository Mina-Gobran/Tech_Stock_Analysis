-- Creating a cleaned analysis table
DROP TABLE IF EXISTS stock_analysis;

CREATE TABLE stock_analysis AS
SELECT 
    "Symbol",
    "Date"::date as trade_date,
    -- Round prices to 2 decimal places
    ROUND("Open"::numeric, 2) as open_price,
    ROUND("High"::numeric, 2) as high_price,
    ROUND("Low"::numeric, 2) as low_price,
    ROUND("Close"::numeric, 2) as close_price,
    "Volume"::bigint as volume,
    
    -- Calculating daily metrics
    ROUND(("High" - "Low")::numeric, 2) as daily_range,
    ROUND((("Close" - "Open") / "Open" * 100)::numeric, 2) as daily_return_pct,
    
    -- Adding time dimensions
    EXTRACT(YEAR FROM "Date"::date) as year,
    EXTRACT(MONTH FROM "Date"::date) as month,
    TO_CHAR("Date"::date, 'Month') as month_name,
    EXTRACT(QUARTER FROM "Date"::date) as quarter,
    TO_CHAR("Date"::date, 'Day') as day_of_week
    
FROM stock_prices
WHERE "Close" IS NOT NULL 
  AND "Open" IS NOT NULL
  AND "Volume" > 0;

-- Verifying the new table
SELECT * FROM stock_analysis LIMIT 10;

-- 1. Checking total records
SELECT COUNT(*) as total_records FROM stock_prices;

-- 2. Checking date range
SELECT 
    MIN("Date") as earliest_date,
    MAX("Date") as latest_date
FROM stock_prices;

-- 3. Check for missing values
SELECT 
    COUNT(*) - COUNT("Open") as missing_open,
    COUNT(*) - COUNT("High") as missing_high,
    COUNT(*) - COUNT("Low") as missing_low,
    COUNT(*) - COUNT("Close") as missing_close,
    COUNT(*) - COUNT("Volume") as missing_volume
FROM stock_prices;

-- 4. Check the stocks included
SELECT 
    "Symbol",
    COUNT(*) as record_count,
    MIN("Date") as first_date,
    MAX("Date") as last_date
FROM stock_prices
GROUP BY "Symbol"
ORDER BY "Symbol";

-- 5. Sample data preview
SELECT 
    "Symbol",
    "Date",
    ROUND("Open"::numeric, 2) as open_price, -- rounding to 2 decimal places
    ROUND("High"::numeric, 2) as high_price,
    ROUND("Low"::numeric, 2) as low_price,
    ROUND("Close"::numeric, 2) as close_price,
    "Volume"
FROM stock_prices
ORDER BY "Date" DESC, "Symbol"
LIMIT 20;
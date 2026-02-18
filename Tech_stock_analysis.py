# Installing packages to collect data
!pip install yfinance pandas sqlalchemy psycopg2-binary openpyxl
import yfinance as yf
import pandas as pd
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

print("Libraries imported successfully!")
# Tech stocks to analyze
stocks = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'NVDA', 'META', 'TSLA']

# Date range
start_date = '2023-01-01'
end_date = '2025-12-31'

print(f"Analyzing {len(stocks)} stocks from {start_date} to {end_date}")
# Download data for all stocks
print("Downloading stock data...")

stock_data = {}

for stock in stocks:
    print(f"Downloading {stock}...", end=" ")
    try:
        ticker = yf.Ticker(stock)
        df = ticker.history(start=start_date, end=end_date)
        df['Symbol'] = stock  # Add symbol column
        df['Date'] = df.index  # Make date a column
        df.reset_index(drop=True, inplace=True)
        stock_data[stock] = df
        print("✓")
    except Exception as e:
        print(f"✗ Error: {e}")

print(f"\nSuccessfully downloaded {len(stock_data)} stocks!")
# Combine all stock data into one dataframe
combined_df = pd.concat(stock_data.values(), ignore_index=True)

print(f"Total records: {len(combined_df):,}")
print(f"\nFirst few rows:")
combined_df.head()
# Check for missing values
print("Missing values per column:")
print(combined_df.isnull().sum())

print(f"\nDate range: {combined_df['Date'].min()} to {combined_df['Date'].max()}")
print(f"Stocks included: {combined_df['Symbol'].unique()}")
# Summary statistics by stock
summary = combined_df.groupby('Symbol').agg({
    'Close': ['min', 'max', 'mean'],
    'Volume': 'mean'
}).round(2)

summary.columns = ['Min Price', 'Max Price', 'Avg Price', 'Avg Volume']
print("Stock Summary Statistics:")
summary
# Save the data
filename = 'tech_stocks_2023_2025.csv'
combined_df.to_csv(filename, index=False)

print(f"✓ Data saved to: {filename}")
print(f"File size: {len(combined_df):,} rows × {len(combined_df.columns)} columns")
from sqlalchemy import create_engine
import pandas as pd

# password
password = '****' # My actual password covered it

# Connection string
connection_string = f'postgresql://postgres:{password}@localhost:5432/stock_analysis'

try:
    # Create engine
    engine = create_engine(connection_string)
    
    # Test connection
    connection = engine.connect()
    print("✓ Successfully connected to PostgreSQL!")
    connection.close()
    
    # Load the CSV data
    combined_df = pd.read_csv('tech_stocks_2023_2025.csv')
    print(f"✓ CSV loaded: {len(combined_df):,} rows")
    
    # Load to PostgreSQL
    print("Loading data to PostgreSQL...")
    combined_df.to_sql('stock_prices', engine, if_exists='replace', index=False)
    
    print("✓ SUCCESS! Data loaded to PostgreSQL!")
    print(f"   Database: stock_analysis")
    print(f"   Table: stock_prices")
    print(f"   Rows: {len(combined_df):,}")
    
except Exception as e:
    print(f"❌ Error: {e}")
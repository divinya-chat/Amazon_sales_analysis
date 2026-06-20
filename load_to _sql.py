import pandas as pd 
from sqlalchemy import create_engine
 
# ============================================================
# CONNECTION SETTINGS — update these to match your PostgreSQL setup
# ============================================================
DB_USER = 'postgres'
DB_PASSWORD = '8089'   # the password you set during PostgreSQL install
DB_HOST = 'localhost'
DB_PORT = '5432'
DB_NAME = 'amazon sales'  # create this database in pgAdmin first
 
# ============================================================
# LOAD CLEANED DATA
# ============================================================
df = pd.read_csv('new amazon_sales_cleaned.csv')
 
# Parse date column so it loads as a proper Postgres DATE type
df['date'] = pd.to_datetime(df['date'], errors='coerce')
 
print(f"Loaded {len(df)} rows, {len(df.columns)} columns from CSV")
print(df.dtypes)
 
# ============================================================
# PUSH TO POSTGRESQL
# ============================================================
engine = create_engine(f'postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}')
 
df.to_sql(
    'amazon',     # table name in Postgres
    engine,
    if_exists='replace',  # drop and recreate table each time this runs
    index=False,
    chunksize=5000        # insert in batches, faster for large datasets
)
 
print(f"\nLoaded {len(df)} rows into Postgres table 'amazon sales' (database: {DB_NAME})")
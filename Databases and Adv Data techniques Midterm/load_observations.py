import pandas as pd
import mysql.connector

CSV_FILE = "observations.csv"

conn = mysql.connector.connect(
    host="127.0.0.1",
    port=3306,
    user="root",
    password="17T58n99",
    database="electricity_db"
)
cur = conn.cursor()

df = pd.read_csv(CSV_FILE)
df["series_name"] = df["series_name"].astype(str).str.strip()

# Ensure years exist
years = sorted(df["year"].unique().tolist())
cur.executemany("INSERT IGNORE INTO dim_year (year) VALUES (%s)", [(int(y),) for y in years])

# Ensure series exist (in case you didn't preinsert all)
series = sorted(df["series_name"].unique().tolist())
cur.executemany("INSERT IGNORE INTO dim_series (series_name) VALUES (%s)", [(s,) for s in series])

# Maps
cur.execute("SELECT year, year_id FROM dim_year")
year_map = {int(y): int(yid) for (y, yid) in cur.fetchall()}

cur.execute("SELECT series_name, series_id FROM dim_series")
series_map = {name: int(sid) for (name, sid) in cur.fetchall()}

cur.execute("SELECT unit_id FROM dim_unit WHERE unit_symbol='GWh' LIMIT 1")
unit_id = int(cur.fetchone()[0])

cur.execute("SELECT source_id FROM dim_source LIMIT 1")
source_id = int(cur.fetchone()[0])

insert_sql = """
INSERT INTO fact_observation (series_id, year_id, unit_id, source_id, value)
VALUES (%s, %s, %s, %s, %s)
ON DUPLICATE KEY UPDATE value = VALUES(value);
"""

rows = []
for _, r in df.iterrows():
    rows.append((
        series_map[r["series_name"]],
        year_map[int(r["year"])],
        unit_id,
        source_id,
        float(r["value"])
    ))

cur.executemany(insert_sql, rows)
conn.commit()
print(f"Inserted/updated {len(rows)} observations into fact_observation")

cur.close()
conn.close()

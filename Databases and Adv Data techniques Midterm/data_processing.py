import pandas as pd

# CONFIG
INPUT_CSV = "ElectricityGenerationAndConsumptionAnnual.csv"
OUTPUT_CSV = "observations.csv"


MIN_YEAR = 2015


df = pd.read_csv(INPUT_CSV, encoding="utf-8-sig")

# Clean column headers (removes leading/trailing spaces)
df.columns = [str(c).strip() for c in df.columns]

print("COLUMNS:", list(df.columns))


# DETECT SERIES COLUMN
possible_series_cols = [
    "Data Series",
    "DataSeries",
    "data_series",
    "Series",
    "Indicator",
    "Variable",
    "variable"
]

series_col = None
for c in possible_series_cols:
    if c in df.columns:
        series_col = c
        break


if series_col is None:
    series_col = df.columns[0]

df = df.rename(columns={series_col: "series_name"})
print("Using series column:", series_col)


year_cols = [c for c in df.columns if str(c).strip().isdigit()]

if not year_cols:
    raise ValueError(
        "No year columns detected. Check CSV format. "
        f"Columns found: {list(df.columns)}"
    )

# Convert year columns to ints for sorting, then back to strings
year_cols_sorted = sorted([int(c) for c in year_cols], reverse=False)
year_cols_sorted = [str(y) for y in year_cols_sorted]

print("Detected year columns (first 10):", year_cols_sorted[:10])
print("Detected year columns (last 10):", year_cols_sorted[-10:])


# UNPIVOT (WIDE -> LONG)
long_df = df.melt(
    id_vars=["series_name"],
    value_vars=year_cols_sorted,
    var_name="year",
    value_name="value"
)

# CLEAN TYPES
long_df["series_name"] = long_df["series_name"].astype(str).str.strip()
long_df["year"] = pd.to_numeric(long_df["year"], errors="coerce")
long_df["value"] = pd.to_numeric(long_df["value"], errors="coerce")


long_df = long_df.dropna(subset=["year", "value"])
long_df["year"] = long_df["year"].astype(int)

long_df = long_df[long_df["year"] >= MIN_YEAR]
long_df = long_df.drop_duplicates(subset=["series_name", "year"])

# Sort nicely
long_df = long_df.sort_values(["series_name", "year"])


# OUTPUT
long_df.to_csv(OUTPUT_CSV, index=False)
print(f"Wrote {OUTPUT_CSV} with {len(long_df)} rows")

# Print a preview for sanity
print("\nPreview:")
print(long_df.head(10).to_string(index=False))

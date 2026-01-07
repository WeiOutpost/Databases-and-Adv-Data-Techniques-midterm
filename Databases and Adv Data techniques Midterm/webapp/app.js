const express = require("express");
const pool = require("./db");

const app = express();
app.set("view engine", "ejs");
app.use(express.urlencoded({ extended: true }));

// Home page: show buttons
app.get("/", async (req, res) => {
  res.render("index", { rows: null, title: "Choose a question" });
});

// Q1: Trend of electricity consumption (2015+)
app.post("/q1", async (req, res) => {
  try {
    const sql = `
      SELECT y.year, f.value
      FROM fact_observation f
      JOIN dim_series s ON s.series_id = f.series_id
      JOIN dim_year y ON y.year_id = f.year_id
      WHERE s.series_name = 'Electricity Consumption'
        AND y.year >= 2015
      ORDER BY y.year;
    `;

    const [rows] = await pool.query(sql);
    res.render("index", {
      title: "Q1: Electricity Consumption trend (2015+)",
      rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).send(err.message);
  }
});

// Q2: Top sector in a chosen year
app.post("/q2", async (req, res) => {
  try {
    const year = parseInt((req.body.year || "").trim(), 10) || 2022;

    const sql = `
      SELECT s.series_name AS sector, f.value
      FROM fact_observation f
      JOIN dim_series s ON s.series_id = f.series_id
      JOIN dim_year y ON y.year_id = f.year_id
      WHERE y.year = ?
        AND s.series_name NOT IN ('Electricity Generation', 'Electricity Consumption')
      ORDER BY f.value DESC
      LIMIT 10;
    `;

    const [rows] = await pool.query(sql, [year]);

    res.render("index", {
      title: `Q2: Top sectors in ${year}`,
      rows
    });
  } catch (err) {
    console.error("Q2 ERROR:", err);
    res.status(500).send("Q2 error: " + err.message);
  }
});


// Q3: Compare manufacturing vs commerce/services over time
app.post("/q3", async (req, res) => {
  const sql = `
    SELECT y.year,
           SUM(CASE WHEN s.series_name='Manufacturing' THEN f.value END) AS manufacturing_gwh,
           SUM(CASE WHEN s.series_name='Commerce And Service-Related' THEN f.value END) AS services_gwh
    FROM fact_observation f
    JOIN dim_series s ON s.series_id = f.series_id
    JOIN dim_year y ON y.year_id = f.year_id
    WHERE s.series_name IN ('Manufacturing','Commerce And Service-Related')
    GROUP BY y.year
    ORDER BY y.year;
  `;
  const [rows] = await pool.query(sql);
  res.render("index", { rows, title: "Q3: Manufacturing vs Services over time" });
});

// Q4: YoY change for electricity generation
app.post("/q4", async (req, res) => {
  const sql = `
    SELECT cur.year,
           cur.value AS generation_gwh,
           (cur.value - prev.value) AS yoy_change_gwh
    FROM (
      SELECT y.year, f.value
      FROM fact_observation f
      JOIN dim_series s ON s.series_id=f.series_id
      JOIN dim_year y ON y.year_id=f.year_id
      WHERE s.series_name='Electricity Generation'
    ) cur
    JOIN (
      SELECT y.year, f.value
      FROM fact_observation f
      JOIN dim_series s ON s.series_id=f.series_id
      JOIN dim_year y ON y.year_id=f.year_id
      WHERE s.series_name='Electricity Generation'
    ) prev
      ON prev.year = cur.year - 1
    ORDER BY cur.year;
  `;
  const [rows] = await pool.query(sql);
  res.render("index", { rows, title: "Q4: YoY change in Electricity Generation" });
});

// Q5: Biggest growth between two years
app.post("/q5", async (req, res) => {
  const y1 = Number(req.body.y1 || 2015);
  const y2 = Number(req.body.y2 || 2024);

  const sql = `
    SELECT s.series_name,
           (f2.value - f1.value) AS growth_gwh
    FROM dim_series s
    JOIN dim_year y1d ON y1d.year = ?
    JOIN dim_year y2d ON y2d.year = ?
    JOIN fact_observation f1 ON f1.series_id=s.series_id AND f1.year_id=y1d.year_id
    JOIN fact_observation f2 ON f2.series_id=s.series_id AND f2.year_id=y2d.year_id
    ORDER BY growth_gwh DESC
    LIMIT 10;
  `;
  const [rows] = await pool.query(sql, [y1, y2]);
  res.render("index", { rows, title: `Q5: Biggest growth (between the years 2015 to 2024)` });
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Web app running on http://localhost:${port}`));

app.get("/ping", async (req, res) => {
  const [rows] = await pool.query("SELECT 1 AS ok");
  res.json(rows);
});

USE electricity_db;

-- 1) Source + unit
INSERT INTO dim_source (publisher, provider, dataset_name, dataset_url, licence_url)
VALUES (
  'SINGSTAT (Singapore Department of Statistics)',
  'Energy Market Authority',
  'Electricity Generation And Consumption, Annual',
  'https://data.gov.sg/datasets/d_3745e3aa98ff3c4bcfcb8e1f6dffef42/view',
  'https://data.gov.sg/open-data-licence'
);

INSERT INTO dim_unit (unit_name, unit_symbol)
VALUES ('Gigawatt Hours', 'GWh');

--Categories
INSERT INTO dim_category (category_name, parent_category_id) VALUES
('Generation', NULL),
('Consumption', NULL),
('Industrial-Related', (SELECT category_id FROM dim_category WHERE category_name='Consumption')),
('Commerce And Service-Related', (SELECT category_id FROM dim_category WHERE category_name='Consumption'));

--Series
INSERT INTO dim_series (series_name, category_id) VALUES
('Electricity Generation', (SELECT category_id FROM dim_category WHERE category_name='Generation')),
('Electricity Consumption', (SELECT category_id FROM dim_category WHERE category_name='Consumption')),
('Manufacturing', (SELECT category_id FROM dim_category WHERE category_name='Industrial-Related')),
('Construction', (SELECT category_id FROM dim_category WHERE category_name='Industrial-Related')),
('Commerce And Service-Related', (SELECT category_id FROM dim_category WHERE category_name='Commerce And Service-Related'));

--Years
INSERT INTO dim_year (year) VALUES
(2015),(2016),(2017),(2018),(2019),(2020),(2021),(2022),(2023),(2024);

--Example facts 
INSERT INTO fact_observation (series_id, year_id, unit_id, source_id, value)
SELECT s.series_id, y.year_id, u.unit_id, src.source_id, 99999.9
FROM dim_series s, dim_year y, dim_unit u, dim_source src
WHERE s.series_name='Electricity Consumption' AND y.year=2022 AND u.unit_symbol='GWh'
LIMIT 1;

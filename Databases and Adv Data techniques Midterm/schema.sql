CREATE DATABASE IF NOT EXISTS electricity_db;
USE electricity_db;

DROP TABLE IF EXISTS fact_observation;
DROP TABLE IF EXISTS dim_year;
DROP TABLE IF EXISTS dim_series;
DROP TABLE IF EXISTS dim_category;
DROP TABLE IF EXISTS dim_unit;
DROP TABLE IF EXISTS dim_source;

CREATE TABLE dim_source (
  source_id INT AUTO_INCREMENT PRIMARY KEY,
  publisher VARCHAR(120) NOT NULL,
  provider VARCHAR(120) NOT NULL,
  dataset_name VARCHAR(200) NOT NULL,
  dataset_url VARCHAR(300) NOT NULL,
  licence_url VARCHAR(300) NOT NULL
);

CREATE TABLE dim_unit (
  unit_id INT AUTO_INCREMENT PRIMARY KEY,
  unit_name VARCHAR(50) NOT NULL UNIQUE,
  unit_symbol VARCHAR(20) NOT NULL
);

CREATE TABLE dim_category (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(120) NOT NULL UNIQUE,
  parent_category_id INT NULL,
  CONSTRAINT fk_category_parent
    FOREIGN KEY (parent_category_id) REFERENCES dim_category(category_id)
);

CREATE TABLE dim_series (
  series_id INT AUTO_INCREMENT PRIMARY KEY,
  series_name VARCHAR(200) NOT NULL UNIQUE,
  category_id INT NULL,
  CONSTRAINT fk_series_category
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id)
);

CREATE TABLE dim_year (
  year_id INT AUTO_INCREMENT PRIMARY KEY,
  year INT NOT NULL UNIQUE
);

CREATE TABLE fact_observation (
  observation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  series_id INT NOT NULL,
  year_id INT NOT NULL,
  unit_id INT NOT NULL,
  source_id INT NOT NULL,
  value DECIMAL(12,1) NOT NULL,

  CONSTRAINT fk_fact_series FOREIGN KEY (series_id) REFERENCES dim_series(series_id),
  CONSTRAINT fk_fact_year   FOREIGN KEY (year_id) REFERENCES dim_year(year_id),
  CONSTRAINT fk_fact_unit   FOREIGN KEY (unit_id) REFERENCES dim_unit(unit_id),
  CONSTRAINT fk_fact_source FOREIGN KEY (source_id) REFERENCES dim_source(source_id),

  UNIQUE KEY uq_series_year (series_id, year_id),
  KEY idx_year (year_id)
);

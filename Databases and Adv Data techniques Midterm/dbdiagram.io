Table dim_source {
  source_id int [pk, increment]
  publisher varchar(120) [not null] // e.g., "SINGSTAT (Singapore Department of Statistics)"
  provider varchar(120) [not null]  // e.g., "Energy Market Authority"
  dataset_name varchar(200) [not null]
  dataset_url varchar(300) [not null]
  licence_url varchar(300) [not null]
}

Table dim_unit {
  unit_id int [pk, increment]
  unit_name varchar(50) [not null, unique] // "Gigawatt Hours"
  unit_symbol varchar(20) [not null]       // "GWh"
}

Table dim_category {
  category_id int [pk, increment]
  category_name varchar(120) [not null, unique] // "Consumption", "Industrial-Related", etc.
  parent_category_id int [ref: > dim_category.category_id, null]
}

Table dim_series {
  series_id int [pk, increment]
  series_name varchar(200) [not null, unique] // matches "Data Series" value in CSV
  category_id int [ref: > dim_category.category_id, null]
}

Table dim_year {
  year_id int [pk, increment]
  year int [not null, unique]
}

Table fact_observation {
  observation_id bigint [pk, increment]
  series_id int [not null, ref: > dim_series.series_id]
  year_id int [not null, ref: > dim_year.year_id]
  unit_id int [not null, ref: > dim_unit.unit_id]
  source_id int [not null, ref: > dim_source.source_id]
  value decimal(12,1) [not null]

  indexes {
    (series_id, year_id) [unique]
    (year_id)
  }
}

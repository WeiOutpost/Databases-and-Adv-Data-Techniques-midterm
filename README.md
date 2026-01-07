Requirements to run the project locally
Python 3.8+
Node.js 16+
MySQL 8.0
npm (Node Package Manager)

Databases and Adv Data techniques Midterm/
├── data_processing.py
├── load_observations.py
├── observations.csv
├── schema.sql
├── load.sql
├── app.js
├── db.js
├── package.json
└── README.md

//Start MySQL Server

//Create Database and Tables

CREATE DATABASE electricity_db;
USE electricity_db;
SOURCE schema.sql;
SOURCE load.sql;

//Run ETL and load Data into database

python data_processing.py
python load_observations.py

//install Node.js dependencies
npm install

//Run Web Application
node app.js




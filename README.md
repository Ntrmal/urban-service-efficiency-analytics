# \# Urban Service Efficiency Analytics



## \## Project Overview



This project analyses NYC 311 Service Requests data from January to March 2026.



The aim was to understand the most common problems reported by residents, how service requests are distributed across boroughs and agencies, and how requests are handled.



I used SQL to clean and analyse the data and Google Sheets to create a dashboard showing the main results.



##### \## Tools Used



\- \*\*SQLite\*\* – database management and data analysis

\- \*\*DBeaver\*\* – writing and running SQL queries

\- \*\*SQL\*\* – data cleaning, aggregations, JOINs and subqueries

\- \*\*Google Sheets\*\* – dashboard and data visualisation



##### \## Dataset



\- Source: https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2020-to-Present/erm2-nwe9/about\_data

\- Period: January–March 2026

\- Total records: 1,016,333



The original dataset was kept unchanged. A separate table called `clean\_311\_requests` was created for the analysis.



The original dataset is not included in this repository because of its large file size.



##### \## Project Files



\- `sql/sql\_project\_develhope.sql` – SQL queries used for data cleaning and analysis.

\- `report/project\_report.pdf` – final project report.



##### \## Dashboard



\[View the Google Sheets Dashboard](https://docs.google.com/spreadsheets/d/1I-UmAYDzkeOMPFx6D8Dwn5Qws5\_wYSOX3DuNccro6ls/edit?usp=sharing)



##### \## Main Analysis Topics



\- Most common service request problem types

\- Service requests by borough

\- Monthly service request trends

\- Request status distribution

\- Closure rates by problem type

\- Service requests by agency

\- Agencies with above-average request volume

\- Problem types with the highest percentage of not-closed requests

\- Requests not closed by borough

\- Average resolution time



##### \## Key Findings



\- Heat/Hot Water was the most reported problem, with 167,038 requests.

\- Brooklyn had the highest number of requests, with 310,999.

\- NYPD and HPD together received approximately 66.56% of all requests.

\- Approximately 96.7% of requests were marked as Closed.

\- The average resolution time was approximately 7.94 days for requests with valid resolution times.



##### \## Limitations



The analysis covers only three months of data. Request status and closure rates do not necessarily measure service quality or resident satisfaction. The average resolution time also includes only requests with valid, non-negative resolution times and recorded closure dates.


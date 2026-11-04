--Selecting first 10 rows
select * from "311_Service_Requests" limit 10;

--How many requests This is called a KPI (Key Performance Indicator)
select COUNT(*) from "311_Service_Requests";

--Check missing values in your dataset
select count(*) as total_rows,
	sum(case
		when "Unique Key" is null
		then 1 else 0
		end)as missing_request_id,
		
	sum(case
		when "Created Date" is null
		or trim("Created Date") =''
		then 1 else 0
		end)as missing_created_date,
		
		sum(case
		when "Closed Date" is null
		or trim("Closed Date") =''
		then 1 else 0
		end)as missing_Closed_Date,
	
		sum(case
		when "Agency" is null
		or trim("Agency") =''
		then 1 else 0
		end)as missing_Agency,
		
		sum(case
		when "Agency Name" is null
		or trim("Agency Name") =''
		then 1 else 0
		end)as missing_Agency_Name,
		
		sum(case
			when "Problem (formerly Complaint Type)" is null
			or trim("Problem (formerly Complaint Type)") =''
			then 1 else 0
		end)as missing_problem,
		
		sum(case
			when "Problem Detail (formerly Descriptor)" is null
			or trim("Problem Detail (formerly Descriptor)") =''
			then 1 else 0
		end)as missing_problem_Details,
		sum(case
			when "Status" is null
			or trim("Status") =''
			then 1 else 0
		end)as missing_Status,
		sum(case
			when "Borough" is null
			or trim("Borough") =''
			then 1 else 0
		end)as Borough
		
from "311_Service_Requests";
--inspect the missing closure dates and statuses
select
    "Status",
    count(*) AS total_requests,
    sum(
        case
            when "Closed Date" is null
              or trim("Closed Date") = ''
            then 1
            else 0
      end
    ) as missing_closed_dates
 from "311_Service_Requests"
 Group by "Status"
 order by total_requests Desc;

--inspecting the three exceptions

select 
	"Unique Key",
    "Created Date",
    "Closed Date",
    "Problem (formerly Complaint Type)",
    "Status",
    "Borough"
from "311_Service_Requests"
where "Status"='Closed'
	and(
	"Closed Date" is null
	or
	trim("Closed Date") =''
	);

-- Formating the date 
select
	"Created Date" as orginal_Date,
	SUBSTR("Created Date",7,4)||'-'||
	SUBSTR("Created Date",1,2)||'-'||
	SUBSTR("Created Date",4,2) as standard_date
from "311_Service_Requests"
limit 10;
	
--creating cleaned dataset
drop table if exists clean_311_requests;
CREATE TABLE clean_311_requests AS
SELECT
    "Unique Key" AS request_id,

    substr("Created Date", 7, 4) || '-' ||
    substr("Created Date", 1, 2) || '-' ||
    substr("Created Date", 4, 2) AS created_date,

    NULLIF(TRIM("Closed Date"), '') AS closed_date,

    NULLIF(TRIM("Agency"), '') AS agency,
    NULLIF(TRIM("Agency Name"), '') AS agency_name,

    NULLIF(
        TRIM("Problem (formerly Complaint Type)"), ''
    ) AS problem_type,

    NULLIF(
        TRIM("Problem Detail (formerly Descriptor)"), ''
    ) AS problem_detail,

    NULLIF(TRIM("Borough"), '') AS borough,
    CAST("Incident Zip" AS TEXT) AS incident_zip,
    NULLIF(TRIM("Status"), '') AS status

FROM "311_Service_Requests"
WHERE "Unique Key" IS NOT NULL
  AND "Created Date" IS NOT NULL
  AND TRIM("Created Date") <> '';
	
--validation
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT request_id) AS unique_requests,
    MIN(created_date) AS first_created_date,
    MAX(created_date) AS last_created_date
FROM clean_311_requests;
--Missing values
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE
        WHEN request_id IS NULL THEN 1 ELSE 0
    END) AS missing_request_id,

    SUM(CASE
        WHEN created_date IS NULL OR TRIM(created_date) = ''
        THEN 1 ELSE 0
    END) AS missing_created_date,

    SUM(CASE
        WHEN closed_date IS NULL OR TRIM(closed_date) = ''
        THEN 1 ELSE 0
    END) AS missing_closed_date,

    SUM(CASE
        WHEN agency IS NULL OR TRIM(agency) = ''
        THEN 1 ELSE 0
    END) AS missing_agency,

    SUM(CASE
        WHEN problem_type IS NULL OR TRIM(problem_type) = ''
        THEN 1 ELSE 0
    END) AS missing_problem_type,

    SUM(CASE
        WHEN status IS NULL OR TRIM(status) = ''
        THEN 1 ELSE 0
    END) AS missing_status,

    SUM(CASE
        WHEN borough IS NULL OR TRIM(borough) = ''
        THEN 1 ELSE 0
    END) AS missing_borough

FROM clean_311_requests;
--What are the most common problems reported to NYC 311?

select problem_type,
		count(*) as total_rows
from clean_311_requests
group by problem_type 
order by total_rows desc
limit 10;
--Which NYC borough receives the most service requests?
	
SELECT
    borough,
    COUNT(*) AS total_requests
FROM clean_311_requests
GROUP BY borough
ORDER BY total_requests DESC
LIMIT 10;

--Calculate each borough's percentage

SELECT
    borough,
    COUNT(*) AS total_requests,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM clean_311_requests),
        2
    ) AS percentage_of_requests
FROM clean_311_requests
GROUP BY borough
ORDER BY total_requests DESC;
--How many requests are Open, Closed, In Progress, or in another status?
SELECT 
	status,
	count(*) as total_requests
from clean_311_requests
group by status
order by total_requests Desc;
--Monthly request trends
SELECT
    SUBSTR(created_date, 1, 7) AS request_month,
    COUNT(*) AS total_requests
FROM clean_311_requests
GROUP BY request_month
ORDER BY request_month;

--compare how many requests were closed versus not closed for each problem type.

SELECT 
	problem_type,
	count(*)as total_requests,
	sum(
	case 
		when status='Closed' then 1
		else 0
	end )as closed_requests,
	sum(
	case 
		when status='Open' then 1
		else 0
	end )as opened_requests
from clean_311_requests
group by problem_type
order by total_requests desc
limit 10;

--Closure percentage
SELECT
    problem_type,
    COUNT(*) AS total_requests,
    SUM(
        CASE WHEN status = 'Closed'
             THEN 1 ELSE 0
        END
    ) AS closed_requests,
    ROUND(
    100.0 *sum(
    	 case WHEN status = 'Closed'
             THEN 1 ELSE 0
           End
          )/count(*),2)as closure_percentage
        
 from clean_311_requests
 group by problem_type
 order by total_requests desc
 limit 10;
	
-- How many requests are not closed
 SELECT 
 	problem_type,
 	count(*) as total_request,
 	sum(
 		case
 			when status <> 'Closed' then 1
 			else 0
 		end)as not_closed_requests
 from clean_311_requests
 group by problem_type
 order by not_closed_requests desc
limit 10;
--calculate the not-closed percentage
SELECT
    problem_type,
    COUNT(*) AS total_requests,
    SUM(
        CASE
            WHEN status <> 'Closed' THEN 1
            ELSE 0
        END
    ) AS not_closed_requests,
  round(100.0 *sum(
  	CASE 
         WHEN status <> 'Closed' THEN 1
          ELSE 0
    END)/count(*),2)
    as not_closed_percentage
from clean_311_requests
group by problem_type 
having count(*)>=100
order by not_closed_percentage desc,
not_closed_requests DESC 
limit 10;
  
--Why are all 3,289 helicopter-noise requests and all 350 construction-lead-dust requests not marked Closed?

SELECT
    problem_type,
    status,
    COUNT(*) AS total_requests
FROM clean_311_requests
WHERE problem_type IN (
    'Noise - Helicopter',
    'Construction Lead Dust'
)
GROUP BY problem_type, status
ORDER BY problem_type, total_requests DESC;
--how old are these requests?
SELECT
    problem_type,
    MIN(created_date) AS first_request_date,
    MAX(created_date) AS latest_request_date,
    COUNT(*) AS total_requests
FROM clean_311_requests
WHERE problem_type IN (
    'Noise - Helicopter',
    'Construction Lead Dust'
)
GROUP BY problem_type;

--are these requests concentrated in one month?

SELECT 	
	SUBSTR(created_date,1,7)as request_month,
	problem_type,
	count(*)as total_requests
from clean_311_requests
where problem_type in(
    'Noise - Helicopter',
    'Construction Lead Dust'
)
group by SUBSTR(created_date ,1,7),
		problem_type 
order by request_month ,
		problem_type ;

--Does the percentage of requests not marked 'Closed' differ by borough?
SELECT
    borough,
    COUNT(*) AS total_requests,
    SUM(
        CASE
            WHEN status <> 'Closed' THEN 1
            ELSE 0
        END
    ) AS not_closed_requests,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN status <> 'Closed' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS not_closed_percentage
FROM clean_311_requests
GROUP BY borough
ORDER BY not_closed_percentage DESC;
--compare closure percentages by borough

SELECT
    borough,
    COUNT(*) AS total_requests,
    SUM(
        CASE
            WHEN status = 'Closed' THEN 1
            ELSE 0
        END
    ) AS closed_requests,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN status = 'Closed' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS closure_percentage
FROM clean_311_requests
WHERE borough <> 'Unspecified'
GROUP BY borough
ORDER BY closure_percentage ASC;

--resolution time

SELECT
    "Unique Key" AS request_id,
    "Created Date" AS created_datetime,
    "Closed Date" AS closed_datetime,
    "Status"
FROM "311_Service_Requests"
WHERE "Closed Date" IS NOT NULL
  AND TRIM("Closed Date") <> ''
LIMIT 10;
--conversion


SELECT
    "Unique Key" AS request_id,

    "Created Date" AS original_created,
    "Closed Date" AS original_closed,

    -- Convert creation timestamp
    substr("Created Date", 7, 4) || '-' ||
    substr("Created Date", 1, 2) || '-' ||
    substr("Created Date", 4, 2) || ' ' ||
    printf('%02d',
        CASE
            WHEN substr("Created Date", 21, 2) = 'AM'
                 AND CAST(substr("Created Date", 12, 2) AS INTEGER) = 12
                THEN 0
            WHEN substr("Created Date", 21, 2) = 'PM'
                 AND CAST(substr("Created Date", 12, 2) AS INTEGER) < 12
                THEN CAST(substr("Created Date", 12, 2) AS INTEGER) + 12
            ELSE CAST(substr("Created Date", 12, 2) AS INTEGER)
        END
    ) || ':' ||
    substr("Created Date", 15, 2) || ':' ||
    substr("Created Date", 18, 2) AS created_datetime,

    -- Convert closure timestamp
    substr("Closed Date", 7, 4) || '-' ||
    substr("Closed Date", 1, 2) || '-' ||
    substr("Closed Date", 4, 2) || ' ' ||
    printf('%02d',
        CASE
            WHEN substr("Closed Date", 21, 2) = 'AM'
                 AND CAST(substr("Closed Date", 12, 2) AS INTEGER) = 12
                THEN 0
            WHEN substr("Closed Date", 21, 2) = 'PM'
                 AND CAST(substr("Closed Date", 12, 2) AS INTEGER) < 12
                THEN CAST(substr("Closed Date", 12, 2) AS INTEGER) + 12
            ELSE CAST(substr("Closed Date", 12, 2) AS INTEGER)
        END
    ) || ':' ||
    substr("Closed Date", 15, 2) || ':' ||
    substr("Closed Date", 18, 2) AS closed_datetime

FROM "311_Service_Requests"
WHERE "Closed Date" IS NOT NULL
  AND TRIM("Closed Date") <> ''
LIMIT 10;

--calculation


WITH converted_dates AS (
    SELECT
        "Unique Key" AS request_id,

        substr("Created Date", 7, 4) || '-' ||
        substr("Created Date", 1, 2) || '-' ||
        substr("Created Date", 4, 2) || ' ' ||
        printf('%02d',
            CASE
                WHEN substr("Created Date", 21, 2) = 'AM'
                     AND CAST(substr("Created Date", 12, 2) AS INTEGER) = 12
                    THEN 0
                WHEN substr("Created Date", 21, 2) = 'PM'
                     AND CAST(substr("Created Date", 12, 2) AS INTEGER) < 12
                    THEN CAST(substr("Created Date", 12, 2) AS INTEGER) + 12
                ELSE CAST(substr("Created Date", 12, 2) AS INTEGER)
            END
        ) || ':' ||
        substr("Created Date", 15, 2) || ':' ||
        substr("Created Date", 18, 2) AS created_datetime,

        substr("Closed Date", 7, 4) || '-' ||
        substr("Closed Date", 1, 2) || '-' ||
        substr("Closed Date", 4, 2) || ' ' ||
        printf('%02d',
            CASE
                WHEN substr("Closed Date", 21, 2) = 'AM'
                     AND CAST(substr("Closed Date", 12, 2) AS INTEGER) = 12
                    THEN 0
                WHEN substr("Closed Date", 21, 2) = 'PM'
                     AND CAST(substr("Closed Date", 12, 2) AS INTEGER) < 12
                    THEN CAST(substr("Closed Date", 12, 2) AS INTEGER) + 12
                ELSE CAST(substr("Closed Date", 12, 2) AS INTEGER)
            END
        ) || ':' ||
        substr("Closed Date", 15, 2) || ':' ||
        substr("Closed Date", 18, 2) AS closed_datetime

    FROM "311_Service_Requests"
    WHERE "Closed Date" IS NOT NULL
      AND TRIM("Closed Date") <> ''
)
SELECT
    request_id,
    created_datetime,
    closed_datetime,
    ROUND(
        (
            CAST(strftime('%s', closed_datetime) AS REAL) -
            CAST(strftime('%s', created_datetime) AS REAL)
        ) / 3600.0,
        2
    ) AS resolution_hours
FROM converted_dates
LIMIT 10;

--calculate average resolution time

WITH converted_dates AS (
    SELECT
        "Unique Key" AS request_id,

        substr("Created Date", 7, 4) || '-' ||
        substr("Created Date", 1, 2) || '-' ||
        substr("Created Date", 4, 2) || ' ' ||
        printf('%02d',
            CASE
                WHEN substr("Created Date", 21, 2) = 'AM'
                     AND CAST(substr("Created Date", 12, 2) AS INTEGER) = 12
                    THEN 0
                WHEN substr("Created Date", 21, 2) = 'PM'
                     AND CAST(substr("Created Date", 12, 2) AS INTEGER) < 12
                    THEN CAST(substr("Created Date", 12, 2) AS INTEGER) + 12
                ELSE CAST(substr("Created Date", 12, 2) AS INTEGER)
            END
        ) || ':' ||
        substr("Created Date", 15, 2) || ':' ||
        substr("Created Date", 18, 2) AS created_datetime,

        substr("Closed Date", 7, 4) || '-' ||
        substr("Closed Date", 1, 2) || '-' ||
        substr("Closed Date", 4, 2) || ' ' ||
        printf('%02d',
            CASE
                WHEN substr("Closed Date", 21, 2) = 'AM'
                     AND CAST(substr("Closed Date", 12, 2) AS INTEGER) = 12
                    THEN 0
                WHEN substr("Closed Date", 21, 2) = 'PM'
                     AND CAST(substr("Closed Date", 12, 2) AS INTEGER) < 12
                    THEN CAST(substr("Closed Date", 12, 2) AS INTEGER) + 12
                ELSE CAST(substr("Closed Date", 12, 2) AS INTEGER)
            END
        ) || ':' ||
        substr("Closed Date", 15, 2) || ':' ||
        substr("Closed Date", 18, 2) AS closed_datetime

    FROM "311_Service_Requests"
    WHERE "Closed Date" IS NOT NULL
      AND TRIM("Closed Date") <> ''
),
resolution_times AS (
    SELECT
        (
            CAST(strftime('%s', closed_datetime) AS REAL) -
            CAST(strftime('%s', created_datetime) AS REAL)
        ) / 3600.0 AS resolution_hours
    FROM converted_dates
    WHERE strftime('%s', created_datetime) IS NOT NULL
      AND strftime('%s', closed_datetime) IS NOT NULL
)
SELECT
    COUNT(*) AS closed_requests_analyzed,
    ROUND(AVG(resolution_hours), 2) AS average_resolution_hours,
    ROUND(MIN(resolution_hours), 2) AS minimum_resolution_hours,
    ROUND(MAX(resolution_hours), 2) AS maximum_resolution_hours
FROM resolution_times
WHERE resolution_hours >= 0;

--Analyze requests by agency
SELECT
    agency,
    COUNT(*) AS total_requests
FROM clean_311_requests
GROUP BY agency
ORDER BY total_requests DESC
LIMIT 20;

--Calculate each agency’s percentage
SELECT
    agency,
    COUNT(*) AS total_requests,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM clean_311_requests),
        2
    ) AS percentage_of_all_requests
FROM clean_311_requests
GROUP BY agency
ORDER BY total_requests DESC
LIMIT 10;


--Creating a second table for the JOIN
drop table if exists agency_lookup;

create table agency_lookup as
select distinct
				trim("Agency") as agency,
				trim("Agency Name")as agency_name
from "311_service_requests"
where "agency" is not null
	and trim("Agency")<> ''
	and "Agency Name" is not null
	and trim("Agency Name")<> '';

select * from agency_lookup;

--inner join
SELECT 
	r.request_id,
	r.problem_type,
	r.agency,
	a.agency_name
from clean_311_requests r
inner join agency_lookup a
	on r.agency =a.agency
	limit 10;
--request has an agency code that does not exist in agency_lookup
select 
	r.request_id,
	r.agency,
	a.agency_name
from clean_311_requests r
left join agency_lookup a
on r.agency_name =a.agency_name 
where a.agency is null
--Every agency code in your cleaned requests table has a match in the lookup table.
--No request was left without a corresponding agency name.

--How many service requests does each agency receive?
select 
	a.agency,
	a.agency_name,
	count(r.request_id) as total_requests
from agency_lookup a 
left join clean_311_requests r 
on a.agency_name =r.agency_name 
group BY 
		a.agency, 
		a.agency_name
order by total_requests desc	

-- Identify pairs of service requests with the same problem type and borough.

SELECT
    r1.request_id AS request_1,
    r2.request_id AS request_2,
    r1.problem_type,
    r1.borough
FROM clean_311_requests AS r1
INNER JOIN clean_311_requests AS r2
    ON r1.problem_type = r2.problem_type
    AND r1.borough = r2.borough
    AND r1.request_id < r2.request_id
LIMIT 20;
--joining three tables
CREATE TABLE agency_categories (
    agency TEXT,
    department_category TEXT
);
INSERT INTO agency_categories VALUES
('NYPD', 'Public Safety'),
('HPD', 'Housing'),
('DSNY', 'Sanitation'),
('DOT', 'Transportation'),
('DEP', 'Environment'),
('DOB', 'Buildings'),
('DOHMH', 'Public Health'),
('DPR', 'Parks and Recreation'),
('TLC', 'Transportation'),
('DHS', 'Social Services');

INSERT INTO agency_categories VALUES
('DCWP', 'Consumer Protection'),
('EDC', 'Economic Development'),
('OOS', 'Public Safety'),
('DOE', 'Education'),
('NYC311-PRD', '311 Operations'),
('OTI', 'Technology');

SELECT *
FROM agency_categories;

SELECT
    r.request_id,
    r.problem_type,
    r.agency,
    a.agency_name,
    c.department_category
FROM clean_311_requests AS r
LEFT JOIN agency_lookup AS a
    ON r.agency = a.agency
LEFT JOIN agency_categories AS c
    ON r.agency = c.agency
LIMIT 10;
--finding missing caregories
SELECT
    r.agency,
    a.agency_name,
    COUNT(*) AS total_requests
FROM clean_311_requests AS r
LEFT JOIN agency_lookup AS a
    ON r.agency = a.agency
LEFT JOIN agency_categories AS c
    ON r.agency = c.agency
WHERE c.agency IS NULL
GROUP BY
    r.agency,
    a.agency_name
ORDER BY total_requests DESC;

--the average requests per agency

SELECT AVG(total_requests)
FROM (
    SELECT
        agency,
        COUNT(*) AS total_requests
    FROM clean_311_requests
    GROUP BY agency
) AS agency_totals;

--agencies receive more requests than the average

SELECT
    agency,
    COUNT(*) AS total_requests
FROM clean_311_requests
GROUP BY agency
HAVING COUNT(*) > (
    SELECT AVG(total_requests)
    FROM (
        SELECT
            agency,
            COUNT(*) AS total_requests
        FROM clean_311_requests
        GROUP BY agency
    ) AS agency_totals
)
ORDER BY total_requests DESC;

--Count requests that are not closed in each borough

SELECT
    borough,
    COUNT(*) AS total_requests,
    SUM(
        CASE
            WHEN status <> 'Closed' OR status IS NULL
            THEN 1
            ELSE 0
        END
    ) AS not_closed_requests
FROM clean_311_requests
GROUP BY borough
ORDER BY not_closed_requests DESC;
--Calculate the percentage of not-closed requests
SELECT
    borough,
    COUNT(*) AS total_requests,
    SUM(
        CASE
            WHEN status <> 'Closed' OR status IS NULL
            THEN 1
            ELSE 0
        END
    ) AS not_closed_requests,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN status <> 'Closed' OR status IS NULL
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS not_closed_percentage
FROM clean_311_requests
GROUP BY borough
ORDER BY not_closed_percentage DESC;



SELECT
    a.agency,
    a.agency_name,
    COUNT(r.request_id) AS total_requests
FROM agency_lookup AS a
LEFT JOIN clean_311_requests AS r
    ON a.agency = r.agency
GROUP BY
    a.agency,
    a.agency_name
ORDER BY total_requests DESC
LIMIT 10;

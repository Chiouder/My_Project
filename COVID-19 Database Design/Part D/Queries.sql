-- 4.1
SELECT 
    loc.location_name AS 'Country Name(CN)',
    -- The following CASE statements are to convert NULL to 0 or the correct month.
    CASE WHEN MV1.month IS NOT NULL THEN MV1.month ELSE '2022-04' END AS 'Observation Months 1 (OM1)',
    CASE WHEN MV1.total_administered_vaccine IS NOT NULL THEN MV1.total_administered_vaccine ELSE 0 END AS 'Administered Vaccine on OM1 (VOM1)',
    CASE WHEN MV2.month IS NOT NULL THEN MV2.month ELSE '2022-05' END AS 'Observation Months 2 (OM2)',
    CASE WHEN MV2.total_administered_vaccine IS NOT NULL THEN MV2.total_administered_vaccine ELSE 0 END AS 'Administered Vaccine on OM2 (VOM2)',
    CASE -- if any month value was 0, it means that the month’s data wasn’t collected. Turn 0 into ‘no valid data collected’.
        WHEN (MV1.total_administered_vaccine IS NULL AND MV2.total_administered_vaccine IS NULL) OR 
        (MV1.total_administered_vaccine = 0 AND MV2.total_administered_vaccine = 0) THEN 'No valid data collected for the selected month'
        WHEN MV1.total_administered_vaccine = 0 THEN 'No valid data collected for OM1'
        WHEN MV2.total_administered_vaccine = 0 THEN 'No valid data collected for OM2'
        ELSE (MV2.total_administered_vaccine - MV1.total_administered_vaccine)
    END AS 'Difference of totals (VOM1-VOM2)'
FROM 
    Locations loc
LEFT JOIN -- Some locations did not have records at 2022-04, so using LEFT JOIN Locations relation to include these no-record locations
    (SELECT -- Get the monthly total administrated vaccine of each iso_code on 2022-04
        iso_code,
        strftime('%Y-%m', date) AS month,
        SUM(daily_vaccinations) AS total_administered_vaccine
    FROM 
        Daily_Records
    WHERE strftime('%Y-%m', date) = '2022-04'
    GROUP BY 
        iso_code, month
    ) AS MV1 
    ON loc.iso_code = MV1.iso_code
LEFT JOIN 
    (SELECT -- Get the monthly total administrated vaccine of each iso_code on 2022-05
        iso_code,
        strftime('%Y-%m', date) AS month,
        SUM(daily_vaccinations) AS total_administered_vaccine
    FROM 
        Daily_Records
    WHERE strftime('%Y-%m', date) = '2022-05'
    GROUP BY 
        iso_code, month
    ) AS MV2 
    ON loc.iso_code = MV2.iso_code
ORDER BY loc.iso_code; 

-- 4.2
SELECT 
    loc.location_name AS 'Country Name',
    mc.month AS 'Month',
    mc.total_vaccinations AS 'Cumulative Doses'
FROM 
    (
        SELECT  -- Calculate the total vaccinations for each country in each month
            iso_code,
            strftime('%Y-%m', date) AS month,
            SUM(daily_vaccinations) AS total_vaccinations
        FROM 
            Daily_Records
        GROUP BY 
            iso_code, 
            strftime('%Y-%m', date)
    ) AS mc
    JOIN
        (
        SELECT -- Calculate the average total vaccinations for each month
            month,
            AVG(total_vaccinations) AS avg_vaccinations
        FROM 
            (
                SELECT --Get sum of each month first, then calculate avg
                    iso_code,
                    strftime('%Y-%m', date) AS month,
                    SUM(daily_vaccinations) AS total_vaccinations
                FROM 
                    Daily_Records
                GROUP BY 
                    iso_code, 
                    strftime('%Y-%m', date)
            ) AS Monthly_Cumulative
        GROUP BY month
    ) AS ma
    ON     
    mc.month = ma.month
JOIN 
    Locations loc -- to get iso_code corresponding lecation_name
    ON 
    mc.iso_code = loc.iso_code
WHERE 
    mc.total_vaccinations > ma.avg_vaccinations
ORDER BY 
    mc.month, loc.location_name;
    
-- 4.3
SELECT 
    DISTINCT pv.Mname AS Vaccine_Type,  
    loc.location_name  AS Country                 
FROM 
    Provides_Vaccines pv
JOIN Locations loc ON pv.iso_code = loc.iso_code          -- Join on the ISO code to get the country name
ORDER BY 
    loc.location_name;        -- Order by country name
    
SELECT 
    DISTINCT s.Mname AS Vaccine_Type, 
    loc.location_name AS Country      
FROM 
    Suppliers s
JOIN Locations loc ON s.iso_code = loc.iso_code      
ORDER BY 
    loc.location_name;      

-- 4.4
SELECT 
    loc.location_name AS Country_Name, 
    CASE -- some locations' data do not indicate its source, such as OWID_EUR
        WHEN vs.source_name != '' AND vs.source_link != '' THEN vs.source_name || ' (' || vs.source_link || ')'
        ELSE 'Not indicated source in original dataset'
    END AS 'Source_Name(URL)',
    dr.max_total_vaccinations AS Total_Administered_Vaccines
FROM 
    (SELECT -- I choose the max value of total_vaccinations in each iso_code's data, becuase some iso's newest total_vaccinations data is broken, like OWID_WLS
        iso_code, 
        MAX(total_vaccinations) AS max_total_vaccinations
     FROM 
        Daily_Records
     WHERE 
        total_vaccinations IS NOT NULL
        AND total_vaccinations != ''
     GROUP BY 
        iso_code
    ) AS dr
JOIN 
    Vaccine_Sources vs
ON 
    dr.iso_code = vs.iso_code
JOIN 
    Locations loc
ON 
    dr.iso_code = loc.iso_code
ORDER BY 
    dr.max_total_vaccinations;

--4.5

SELECT 
    c.month AS "Date Range (Months)",  -- Formatting month for display
    CASE -- this case statement is to turn blank or NULL value to prompt text
        WHEN u.people_fully_vaccinated IS NULL OR u.people_fully_vaccinated = '' THEN 'No complete data for the month'
        ELSE u.people_fully_vaccinated
    END AS "United States",
    CASE
        WHEN w.people_fully_vaccinated IS NULL OR w.people_fully_vaccinated = '' THEN 'No complete data for the month'
        ELSE w.people_fully_vaccinated
    END AS "Wales",
    CASE
        WHEN c.people_fully_vaccinated IS NULL OR c.people_fully_vaccinated = '' THEN 'No complete data for the month'
        ELSE c.people_fully_vaccinated
    END AS "Canada",
    CASE
        WHEN d.people_fully_vaccinated IS NULL OR d.people_fully_vaccinated = '' THEN 'No complete data for the month'
        ELSE d.people_fully_vaccinated
    END AS "Denmark"
FROM 
    (
        -- Subquery to get the last day of each month for Canada and its total fully vaccinated count
        SELECT 
            strftime('%Y-%m', date) AS month, 
            people_fully_vaccinated
        FROM 
            Certain_Country_Records
        WHERE 
            UPPER(iso_code) = 'CAN' 
            AND strftime('%Y', date) IN ('2022', '2023') 
            AND date IN (
                SELECT 
                    MAX(date) -- use the last day of the month to count the total fully vaccinated number, becuase people_fully_vaccinated is a cumulative value.
                FROM 
                    Certain_Country_Records
                WHERE 
                    UPPER(iso_code) = 'CAN' 
                    AND strftime('%Y', date) IN ('2022', '2023')
                GROUP BY 
                    strftime('%Y', date), strftime('%m', date)
            )
    ) AS c
LEFT JOIN 
    (
        -- Logic is the same as above, just changing the iso_code to USA
        SELECT 
            strftime('%Y-%m', date) AS month, 
            people_fully_vaccinated
        FROM 
            Certain_Country_Records
        WHERE 
            UPPER(iso_code) = 'USA' 
            AND strftime('%Y', date) IN ('2022', '2023')
            AND date IN (
                SELECT 
                    MAX(date)
                FROM 
                    Certain_Country_Records
                WHERE 
                    UPPER(iso_code) = 'USA' 
                    AND strftime('%Y', date) IN ('2022', '2023')
                GROUP BY 
                    strftime('%Y', date), strftime('%m', date)
            )
    ) AS u
ON c.month = u.month
LEFT JOIN 
    (
        -- Logic is the same as above, just changing the iso_code
        SELECT 
            strftime('%Y-%m', date) AS month, 
            people_fully_vaccinated
        FROM 
            Certain_Country_Records
        WHERE 
            UPPER(iso_code) = 'OWID_WLS' 
            AND strftime('%Y', date) IN ('2022', '2023')
            AND date IN (
                SELECT 
                    MAX(date)
                FROM 
                    Certain_Country_Records
                WHERE 
                    UPPER(iso_code) = 'OWID_WLS' 
                    AND strftime('%Y', date) IN ('2022', '2023')
                GROUP BY 
                    strftime('%Y', date), strftime('%m', date)
            )
    ) AS w
ON c.month = w.month
LEFT JOIN 
    (
        -- Logic is the same as above, just changing the iso_code
        SELECT 
            strftime('%Y-%m', date) AS month, 
            people_fully_vaccinated
        FROM 
            Certain_Country_Records
        WHERE 
            UPPER(iso_code) = 'DNK' 
            AND strftime('%Y', date) IN ('2022', '2023')
            AND date IN (
                SELECT 
                    MAX(date)
                FROM 
                    Certain_Country_Records
                WHERE 
                    UPPER(iso_code) = 'DNK' 
                    AND strftime('%Y', date) IN ('2022', '2023')
                GROUP BY 
                    strftime('%Y', date), strftime('%m', date)
            )
    ) AS d
ON c.month = d.month
WHERE
    -- Filter out rows where all countries have no complete data to display
    (c.people_fully_vaccinated IS NOT NULL AND c.people_fully_vaccinated != '') OR 
    (u.people_fully_vaccinated IS NOT NULL AND u.people_fully_vaccinated != '') OR
    (w.people_fully_vaccinated IS NOT NULL AND w.people_fully_vaccinated != '') OR
    (d.people_fully_vaccinated IS NOT NULL AND d.people_fully_vaccinated != '')
ORDER BY 
    c.month;








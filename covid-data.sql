/** CHECK ROWS **/
SELECT COUNT(*)
	FROM coviddeath;

SELECT COUNT(*)
	FROM covidvaccination;
    
SELECT location, date, population, total_deaths, total_cases
	FROM coviddeath
    WHERE location = 'china'
    ORDER BY location, date;
    
SELECT location, date, total_deaths, population, total_cases,
	(total_deaths/total_cases)*100 AS death_rate,
    (total_deaths/population)*100 AS nationalwise
    FROM coviddeath
    WHERE location in ('China', 'Spain')
    ORDER BY location, date;
    /* death rate might seem highly but can be dilluted by total population*/
    
SELECT location, date,total_cases, population, 
	(total_cases/population)*100 AS population_infection_rate
	FROM coviddeath
    WHERE location = 'China'
    ORDER BY location, date;


#SELECT CAST(total_deaths AS INT);
SELECT location, continent, MAX(total_deaths) as TotalDeathCount
	FROM coviddeath
    WHERE continent IS NOT NULL
    GROUP BY location
    ORDER BY TotalDeathCount DESC;

SELECT location, MAX(total_deaths) as TotalDeathCount
	FROM coviddeath
    WHERE continent IS NULL
    GROUP BY location
    ORDER BY TotalDeathCount DESC;
    
SELECT location, date, population, total_deaths, total_cases, 
	(total_deaths/total_cases)*100 AS deathrate
	FROM coviddeath
    WHERE continent IS NOT NULL
    ORDER BY location, date;
    
SELECT location, date, population,icu_patients,hosp_patients,
	(icu_patients/hosp_patients)*100 AS ICUOcupancyRate
    FROM coviddeath
    WHERE continent IS NOT NULL
    ORDER BY location, date;

SELECT date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 AS NewDeathRate
	FROM coviddeath
    WHERE continent IS NOT NULL
    GROUP BY date
    ORDER BY 1,2;


SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER 
    (PARTITION BY death.location ORDER BY death.location, death.date) AS AggVaccination
	FROM covidvaccination vac
	JOIN coviddeath death
    ON death.location = vac.location
    AND death.date = vac.date
    WHERE death.continent IS NOT NULL 
    ORDER BY location, date;

-- CTE 

WITH PercentVaccination (Continent, Location, Date, Population, New_Vaccinations, AggVaccination)
AS
(SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER 
    (PARTITION BY death.location ORDER BY death.location, death.date) AS AggVaccination
	FROM covidvaccination vac
	JOIN coviddeath death
    ON death.location = vac.location
    AND death.date = vac.date
    WHERE death.continent IS NOT NULL 
    -- ORDER BY location, date;
)
SELECT *, (AggVaccination/population)*100 AS PercentVaccination
FROM PercentVaccination;



-- temp table *
/**
DROP TABLE IF EXISTS #PercentVaccination
CREATE TABLE #PercentVaccination
	(continent varchar(25),
	 location varchar(25),
     date datetime,
     population INT,
     new_vaccination INT,
     AggVaccination INT
	 )
    INSERT INTO #PercentVaccination
    SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER 
    (PARTITION BY death.location ORDER BY death.location, death.date) AS AggVaccination
	FROM covidvaccination vac
	JOIN coviddeath death
    ON death.location = vac.location
    AND death.date = vac.date
    --WHERE death.continent IS NOT NULL 
    --ORDER BY location, date;
SELECT *, (AggVaccination/population)/100
FROM #PercentVaccination**/


CREATE VIEW PercentVaccination AS
 SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER 
    (PARTITION BY death.location ORDER BY death.location, death.date) AS AggVaccination
	FROM covidvaccination vac
	JOIN coviddeath death
    ON death.location = vac.location
    AND death.date = vac.date
    WHERE death.continent IS NOT NULL 

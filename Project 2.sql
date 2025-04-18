SELECT location,`date`,total_cases,new_cases,total_deaths,population
FROM portfolioprojects.df1
WHERE continent is NOT NULL
ORDER BY location,`date`;

-- total cases vs total deaths

SELECT location,`date`,total_cases,total_deaths,(total_deaths/total_cases) * 100 AS Death_Percentage
FROM portfolioprojects.df1
WHERE location like '%tates%'
ORDER BY location,`date`;

-- total cases vs population
-- shows waht percentage what they got covid
SELECT location,`date`,total_cases,population,(total_cases/population) * 100 AS POP_Percentage
FROM portfolioprojects.df1
-- WHERE location like '%states%'
ORDER BY location,`date`;

-- looking with countries with highest infection rate
SELECT location,population,MAX(total_deaths) AS HighestInfectionCount,MAX((total_cases/population)) * 100 AS Death_Percentage
FROM portfolioprojects.df1
-- WHERE location like '%tates%'
GROUP BY location,population
ORDER BY Death_Percentage DESC ;

-- show countries with hoighest dwath count

SELECT 
    location,
    population,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount  
FROM 
    portfolioprojects.df1
-- WHERE location LIKE '%tates%'
WHERE continent IS NOT NULL
GROUP BY 
    location, population
ORDER BY 
    TotalDeathCount DESC;
    
    
-- LETS break this into continent

SELECT location,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount  
FROM 
    portfolioprojects.df1
-- WHERE location LIKE '%tates%'
WHERE continent IS NULL
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;


-- shows the continent with high death continet
SELECT location,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount  
FROM 
    portfolioprojects.df1
-- WHERE location LIKE '%tates%'
WHERE continent IS NULL
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;
    
SELECT  continent,MAX(CAST(total_deaths AS SIGNED)) AS DeathCount
FROM portfolioprojects.df1
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCount DESC
LIMIT 1
;

-- global numbers
SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths as SIGNED)) as total_deaths,SUM(CAST(new_deaths as SIGNED))/SUM(new_cases)*100 as DeathPercentage
FROM portfolioprojects.df1
WHERE continent is NOT NULL
ORDER BY total_cases,total_deaths;

WITH CTE1 AS (
SELECT A.continent,A.location, A.`date`,A.population,B.new_vaccinations,SUM(CAST(B.new_vaccinations AS SIGNED )) OVER (PARTITION BY A.location ORDER BY A.location,A.`date`) AS Rolling_Total
FROM portfolioprojects.df1 A
JOIN portfolioprojects.df2  B ON A.location= B.location AND A.`Date` = B.`Date`
WHERE A.continent is NOT NULL
ORDER BY A.location,A.`date`)

SELECT *, ( Rolling_total/population)*100
from CTE1;


-- Temp Table
-- if u are doing any alteration  or some thing u can run this DROP TABLE if exists PercentPopulationVaccinated1
CREATE TABLE PercentPopulationVaccinated1 (
    continent VARCHAR(255),
    location VARCHAR(255),
    `date` DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rolling_total NUMERIC
);

INSERT INTO PercentPopulationVaccinated1
SELECT 
    A.continent,
    A.location,
    A.`date`,
    A.population,
    B.new_vaccinations,
    SUM(CAST(B.new_vaccinations AS SIGNED)) 
        OVER (PARTITION BY A.location ORDER BY A.location, A.`date`) AS rolling_total
FROM 
    portfolioprojects.df1 A
JOIN 
    portfolioprojects.df2 B 
    ON A.location = B.location AND A.`date` = B.`date`
WHERE 
    A.continent IS NOT NULL
ORDER BY 
    A.location, A.`date`;


SELECT *, ( Rolling_total/population)*100
from PercentPopulationVaccinated1;


-- create a view  to store data for visulaizations 

CREATE VIEW Data1 AS 
SELECT 
    A.continent,
    A.location, 
    A.`date`,
    A.population,
    B.new_vaccinations,
    SUM(CAST(B.new_vaccinations AS SIGNED)) 
        OVER (PARTITION BY A.location ORDER BY A.`date`) AS rolling_total
FROM 
    portfolioprojects.df1 A
JOIN 
    portfolioprojects.df2 B 
    ON A.location = B.location AND A.`date` = B.`date`
WHERE 
    A.continent IS NOT NULL;
    
    
SELECT VERSION();
SHOW FULL TABLES IN portfolioprojects WHERE TABLE_TYPE LIKE 'VIEW';
CREATE VIEW test_view AS
SELECT location, population
FROM portfolioprojects.df1
LIMIT 10;




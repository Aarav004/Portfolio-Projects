/*
Covid-19 Data Exploration
Explored the data using- Joins, Aggregate Functions, Casting data types, CTEs, Temp tables, Window functions
*/

SELECT * 
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date

--select data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
order by location, date

--Total Cases vs Total Deaths (day wise)
-- Shows the likelihood of dying if covid is spread in a country( rate of mortality upon infection)

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases::DECIMAL)*100,4) AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL and location = 'India'
ORDER BY location, date

--Total Cases Vs Total Deaths (Monthly)
SELECT location, TO_CHAR(date, 'YYYY-MM') AS year_month, SUM(new_cases) AS TotalCasesInAMonth, SUM(new_deaths) AS TotalDeathsInAMonth, ROUND((SUM(new_deaths)/NULLIF(SUM(new_cases),0)::DECIMAL)*100,4) AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, year_month
ORDER BY location, year_month

--Total Cases vs Population
-- Shows the percentage of population infected with covid
SELECT location, date, population, total_cases, ROUND((total_cases/population::DECIMAL)*100,10) AS percentpopulationinfected
FROM coviddeaths
order by 1,2

-- Countries with Highest Infection Rate Compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectioncount, ROUND(max(total_cases/population::DECIMAL)*100,10) AS percentpopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY percentpopulationInfected DESC

--Countries with Highest Death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,ROUND(SUM(new_deaths)/SUM(new_cases::DECIMAL)*100,10) AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one covid vaccination

SELECT *, ROUND((RollingPeopleVaccinated/population::DECIMAL)*100,6) AS Percentpeoplevaccinated
FROM(
SELECT d.continent, d.location, d. date, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location order by d.location, d.date) as RollingPeopleVaccinated
FROM coviddeaths d
INNER JOIN covidvaccinations v
	ON d.location =v.location AND d.date=v.date
WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL)
ORDER BY location, date

-- Using CTE, we can achieve  the same result

WITH popvsvac AS (
	SELECT d.continent, d.location, d. date, d.population, v.new_vaccinations,
		SUM(v.new_vaccinations) OVER (PARTITION BY d.location order by d.location, d.date) as RollingPeopleVaccinated
	FROM coviddeaths d
	INNER JOIN covidvaccinations v
		ON d.location =v.location AND d.date=v.date
	WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL
)
SELECT *, ROUND((RollingPeopleVaccinated/population::DECIMAL)*100,6) AS Percentpeoplevaccinated
 FROM popvsvac
 ORDER BY location, date

-- we can also achieve the above result using temporary table

SELECT *
INTO TEMP TABLE Percent_Pop_Vaccinated
FROM
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location order by d.location, d.date) as RollingPeopleVaccinated
FROM coviddeaths d
INNER JOIN covidvaccinations v
	ON d.location =v.location AND d.date=v.date
--WHERE d.continent IS NOT NULL
)

SELECT * ,ROUND((RollingPeopleVaccinated/population::DECIMAL)*100,6)
FROM Percent_Pop_Vaccinated


































































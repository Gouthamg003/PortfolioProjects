
SELECT *
FROM PortfolioProject.dbo.Coviddeath
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.Covidvaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject.dbo.Coviddeath
ORDER BY 1,2

--Looking at the total cases vs total deaths
--Shows the likeliness of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as numeric)/cast ( total_cases as numeric)*100 ) AS DeathPercentage
FROM PortfolioProject.dbo.Coviddeath
WHERE Location like '%CANADA%'
ORDER BY 1,2


-- Looking at total cases vs population
-- Shows what percentage of population got covid

SELECT location, date, total_cases, population, (cast(total_cases as numeric)/cast ( population as numeric)*100) AS CovidPercenatge
FROM PortfolioProject.dbo.Coviddeath
--WHERE Location like '%CANADA%'
ORDER BY 1,2

-- Countries with highest infection rate compared to population

SELECT location, population, max(total_cases) AS HIghestInfectionCount,MAX(cast(total_cases as numeric))/cast(population as numeric)*100 AS PercenatPopulationInfected
FROM PortfolioProject.dbo.Coviddeath
--WHERE continent = 'ASIA'
GROUP BY population,location
ORDER BY PercenatPopulationInfected DESC

-- Countries with the highest death count per population

SELECT location, Max(Cast(total_deaths as numeric)) AS TotaldeathCount 
FROM PortfolioProject.dbo.Coviddeath
--WHERE continent = 'ASIA'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotaldeathCount  

-- Using continent to look highest total death count

SELECT continent, SUM(Cast(total_deaths as numeric)) AS TotaldeathCount 
FROM PortfolioProject.dbo.Coviddeath
--WHERE continent = 'ASIA'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotaldeathCount  DESC

--Global number of covid cases

SELECT max(total_cases)as totalcases, max(total_deaths)as totaldeaths, MAX(cast(total_deaths as numeric))/MAX(cast( total_cases as numeric))*100 AS GlobaldeathCount
FROM PortfolioProject.dbo.Coviddeath
WHERE continent IS NOT NULL
--GROUP BY DATE
ORDER BY 1,2

--Looking at total pouplation vs vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(CONVERT(numeric, Vacc.new_vaccinations)) OVER(PARTITION BY Dea.location Order BY Dea.location, Dea.date) RollingPeopleVaccinated
FROM PortfolioProject.dbo.Coviddeath Dea
JOIN PortfolioProject.dbo.Covidvaccinations Vacc
	ON Dea.location = Vacc.location
	and Dea.date = Vacc.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to find out RollingPeopleVaccinated vs population

WITH VaccPop(continent, location, date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(CONVERT(numeric, Vacc.new_vaccinations)) OVER(PARTITION BY Dea.location Order BY Dea.location, Dea.date) RollingPeopleVaccinated
FROM PortfolioProject.dbo.Coviddeath Dea
JOIN PortfolioProject.dbo.Covidvaccinations Vacc
	ON Dea.location = Vacc.location
	and Dea.date = Vacc.date
WHERE Dea.continent IS NOT NULL
)
Select*, (RollingPeopleVaccinated/population)*100
From VaccPop

-- Using temp table instead of CTE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(CONVERT(numeric, Vacc.new_vaccinations)) OVER(PARTITION BY Dea.location Order BY Dea.location, Dea.date) RollingPeopleVaccinated
FROM PortfolioProject.dbo.Coviddeath Dea
JOIN PortfolioProject.dbo.Covidvaccinations Vacc
	ON Dea.location = Vacc.location
	and Dea.date = Vacc.date
WHERE Dea.continent IS NOT NULL

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for visualization


USE PortfolioProject GO CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(CONVERT(numeric, Vacc.new_vaccinations)) OVER(PARTITION BY Dea.location Order BY Dea.location, Dea.date) RollingPeopleVaccinated
FROM PortfolioProject.dbo.Coviddeath Dea
JOIN PortfolioProject.dbo.Covidvaccinations Vacc
	ON Dea.location = Vacc.location
	and Dea.date = Vacc.date
WHERE Dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
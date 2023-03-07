0--SELECT location, date, new_cases, total_deaths, population
--FROM CovidDeath$


SELECT *
FROM PortfolioProjectCovid..CovidDeath$
Where continent is not null
ORDER BY 3,4


-- total_cases vs total_death
SELECT date, location, population, new_cases, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Percentage_Death
FROM PortfolioProjectCovid..CovidDeath$
WHERE location = 'Nigeria'
ORDER BY Percentage_Death DESC

-- Population Vs Total cases

SELECT date, location, population, total_cases, (total_cases/population)*100 AS Percentage_Population
FROM CovidDeath$
WHERE location = 'Nigeria'
ORDER BY Percentage_Population DESC

-- Countries with high infection rate Vs Population
SELECT location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 AS Percentage_Population_Infected
FROM PortfolioProjectCovid..CovidDeath$
-- WHERE location = 'Nigeria'
GROUP BY location, population
ORDER BY Percentage_Population_Infected DESC

-- Location Vs HighestDeath
SELECT location, population, MAX(cast(total_deaths as int)) as HighestDeathRate 
FROM PortfolioProjectCovid.dbo.CovidDeath$
-- WHERE location = 'Nigeria'
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestDeathRate DESC

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as percentageTotalDeath
From PortfolioProjectCovid..CovidDeath$
Where continent is not null
Group by date
Order by 1,2

-- GLOBAL NUMBERS AS A WHOLE
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as percentageTotalDeath
From PortfolioProjectCovid..CovidDeath$
Where continent is not null
--Group by date
Order by 1,2

-- Total Population Vs Total Vaccination
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeath$ dea
Join PortfolioProjectCovid..CovidVaccine$ vac
ON dea.location = vac.location 
AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeath$ dea
Join PortfolioProjectCovid..CovidVaccine$ vac
ON dea.location = vac.location 
AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
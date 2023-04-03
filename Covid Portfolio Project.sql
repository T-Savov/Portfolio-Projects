SELECT *
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM [Portfolio Project].dbo.CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

--Selecting data that will be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if contracted with covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location like '%Europe%'
and continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what % of population got Covid

SELECT location, date, Population, total_cases, (total_cases/Population)*100 as CasePercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
--WHERE location like '%Europe%'
ORDER BY 1,2

--Loking at countries with Highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/Population))*100 as PercentagPopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE location like '%Europe%'
WHERE continent is not null
GROUP BY location, Population
ORDER BY PercentagPopulationInfected DESC

--Showing Continents with Highest Death Count per Population

 SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE location like '%Europe%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE continent like '%Europe%'
WHERE continent is not null
--group by date
ORDER BY 1, 2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated,
  (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
	order by 2, 3
	
	--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
	--order by 2, 3
	)
	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM PopvsVac


	--Temp Table

DROP Table if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
	--order by 2, 3
	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM #PercentPopulationVaccinated


	--Creating view to store data for later visualizations

	Create View PercentPopulationVaccinated as
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
	--order by 2, 3


	SELECT *
	FROM PercentPopulationVaccinated


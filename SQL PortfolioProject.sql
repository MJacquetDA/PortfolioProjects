--SELECT * FROM CovidDeaths$
--ORDER BY 3,4

-- SELECT * FROM CovidVaccinations$
-- ORDER BY 3,4

SELECT Location, Date, total_cases, new_cases, total_deaths, [population]
from CovidDeaths$ AS CD
order by 1,2

-- Looking at total cases vs total deaths
-- shows the likelihood oh dying if you contract covid in your country
SELECT Location, Date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as Death_Percentage
from CovidDeaths$ AS CD
where location like '%states%'
order by 1,2 

-- Looking at the total cases vs population
SELECT Location, Date, total_cases, population, (Total_cases/population)*100 as Contract_Percentage
from CovidDeaths$ AS CD
where location like 'France'
order by 1,2 desc

-- highest infestion rate over countries
SELECT Location, Max(total_cases) as HighestInfectionCount, round(Max(Total_cases/population)*100,2) as PercentPopInfected
from CovidDeaths$ AS CD
GROUP BY POPULATION, Location
order by 3 desc

-- Showing countries w/ highest death count per Population
SELECT Location, Max(CAST(total_deaths as int)) as TotalDeqthCount
from CovidDeaths$ AS CD
where continent is not null
GROUP BY Location
order by 2 desc

-- Let's Break down by continent
SELECT location, Max(CAST(total_deaths as int)) as TotalDeqthCount
from CovidDeaths$ AS CD
where continent is null
GROUP BY location
order by 2 desc

-- Global Numbers
SELECT sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths AS INT))/sum(new_cases)*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
where continent is not null
order by 1,2 ASC

-- Looking at total population vs vaccination*
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location order by dea.DATE, dea.location) as RollingPplVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] as dea
join [PortfolioProject].[dbo].[CovidVaccinations$] as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
where dea.location = 'Albania'
order by 2,3

-- USE CTE
WITH Pop_vs_Vacc (Continent,Location, Date,Population,New_Vaccinations,RollingPplVaccinated) 
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location order by dea.DATE, dea.location) as RollingPplVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] as dea
join [PortfolioProject].[dbo].[CovidVaccinations$] as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
)
SELECT *, (RollingPplVaccinated/Population)*100
from Pop_vs_Vacc
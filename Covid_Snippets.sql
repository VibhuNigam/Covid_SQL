select * from PortfolioProject..CovidVaccinations
where continent is not null
order by 3, 4;

--select * from PortfolioProject..CovidDeaths
--order by 3,4;


--Data Exploration

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;


-- Total Cases vs Total Deaths

SELECT location,
       date,
       total_cases,
       total_deaths,
       (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' and continent is not null
ORDER BY 1,2;

--Total Cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2;

-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 
as PercentofPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentofPopulationInfected desc;

--Showing countries with Highest  Death Count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing the continents with highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as tota_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2;

-- total_deaths, total_cases, total_percentage

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as tota_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2;

select *
from PortfolioProject..CovidVaccinations


--Using joins between the two tables

--Looking at Total Population vs Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
From PortfolioProject..CovidDeaths as cd
Join PortfolioProject..CovidVaccinations as cv
	ON cd.location= cv.location
	and cd.date= cv.date
where cd.continent is not null
order by 2,3;

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location,
cd.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as cd
Join PortfolioProject..CovidVaccinations as cv
	ON cd.location= cv.location
	and cd.date= cv.date
where cd.continent is not null
order by 2,3;

-- Using CTE

with Pop_vs_Vac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location,
cd.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RPCPercent
from Pop_vs_Vac


--Creating Temp Table

Drop table if exists #PercentPopualtionVaccinated
Create Table #PercentPopualtionVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacciantion numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopualtionVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location,
cd.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location=cv.location
	and cd.date=cv.date
--where cd.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopualtionVaccinated



--Creating View to store data fro later data visualization
Create View PercentPopualtionVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location,
cd.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not null

Select * from PercentPopualtionVaccinated



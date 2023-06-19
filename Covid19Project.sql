Select *
From CovidProject..CovidDeaths$
Where continent is not null
order by 3, 4

--Select *
--From CovidProject..CovidVaccinations$
--order by 3, 4
-- Select Data that we are goig to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths$
Where continent is not null
order by 1, 2

-- Looking at Total-Cases vs Total_Deaths
-- shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (Total_deaths/total_cases)* 100 as DeathPercentage
From CovidProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1, 2

-- looking at Total_cases vs Population
-- shows what percentage of population got Covid

Select location, date,  Population, total_cases, (total_cases/Population)* 100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
-- Where location like '%states%'
Where continent is not null
order by 1, 2 

-- Looking at country with the highest infection rate compared to population

Select Location,  Population, MAX(total_cases) as HighestInfectionCountry, MAX((total_cases/Population))* 100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
-- Where location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

-- showing Countries with Highest Death Count per population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
-- Where location like '%states%' 
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THIS DOWN BY CONTINENT

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
-- Where location like '%states%' 
Where continent is null
Group by location
order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
-- Where location like '%states%' 
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
-- Where location like '%states%' 
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_cases , SUM(cast(new_deaths as int))/SUM(New_cases)* 100 as DeathPercentage
From CovidProject..CovidDeaths$
-- Where location like '%states%'
Where continent is not null
-- Group By date
order by 1, 2

-- looking at the Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated -- (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated -- (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated -- (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualization


Create View PercentpopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated -- (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3


Select *
From PercentpopulationVaccinated
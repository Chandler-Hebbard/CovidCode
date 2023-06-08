/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- All Covid Deaths data 

Select *
From Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4

-- All Covid Vaccinations data 

Select *
From Portfolio_Project..CovidVaccinations
order by 3,4

-- Select Data that we are going to be starting with

Select Location, Date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From Portfolio_Project..CovidDeaths
where continent is not null AND location like '%states%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


Select Location, Date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
where continent is not null AND location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
From Portfolio_Project..CovidDeaths
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
From Portfolio_Project..CovidDeaths
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select Date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
where continent is not null
Group by Date
order by 1,2

-- Total Global numbers

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, RollingPeopleVaccinated, New_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select * , (RollingPeopleVaccinated/Population)*100 
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * , (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated

-- Creating Views to store data for later visualizations

USE Portfolio_Project
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



USE Portfolio_Project
GO
Create View LocationCasesDeathsPopulation as
Select Location, Date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
where continent is not null


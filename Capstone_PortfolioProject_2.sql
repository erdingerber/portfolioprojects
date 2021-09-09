/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From Project2_CovidData..CovidDeaths
Where continent is not null
order by 3,4

-- Selecting the Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Project2_CovidData..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Looking at the likelihood of dying if you get Covid in selected country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPerc
From Project2_CovidData..CovidDeaths
Where location like '%states'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what % of the population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PopPrecInfected
From Project2_CovidData..CovidDeaths
--Where location like '%states'
order by 1,2

-- Looking at countries w/ Highest INFECTION Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopPrecInfected
From Project2_CovidData..CovidDeaths
-- Where location like '%states'
Group by location, population
Order by PopPrecInfected desc

-- Showing countries w/ Highest DEATH count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project2_CovidData..CovidDeaths
-- Where location like '%states'
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- BREAK THINGS DOWN BY CONTINENT 


-- Showing continents with the greatest DEATH COUNT per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project2_CovidData..CovidDeaths
-- Where location like '%states'
Where continent is null
Group by continent 
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPerc
From Project2_CovidData..CovidDeaths
--Where location like '%states'
where continent is not null
-- Group by date
order by 1,2

-- Looking at Total Populations vs Total Vaccinations

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaxs.new_vaccinations, SUM(CONVERT(int, vaxs.new_vaccinations)) 
	OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as PeopleVaxRolling
From Project2_CovidData..CovidDeaths deaths
Join Project2_CovidData..CovidVax vaxs
	On deaths.location = vaxs.location
	and deaths.date = vaxs.date
where deaths.continent is not null
order by 2,3

-- USE CTE

With PopVsVax (Continent, Location, Date, Population, new_vaccinations, PeopleVaxRolling)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaxs.new_vaccinations, SUM(CONVERT(int, vaxs.new_vaccinations)) 
	OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as PeopleVaxRolling

From Project2_CovidData..CovidDeaths deaths
Join Project2_CovidData..CovidVax vaxs
	On deaths.location = vaxs.location
	and deaths.date = vaxs.date
where deaths.continent is not null
--order by 2,3
)
Select *, (PeopleVaxRolling/Population)*100
From PopVsVax

-- CREATE A TEMP TABLE 

DROP table if exists #PercentPopVaxd
Create Table #PercentPopVaxd
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaxRolling numeric,
)


Insert into #PercentPopVaxd
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaxs.new_vaccinations, SUM(CONVERT(int, vaxs.new_vaccinations)) 
	OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as PeopleVaxRolling

From Project2_CovidData..CovidDeaths deaths
Join Project2_CovidData..CovidVax vaxs
	On deaths.location = vaxs.location
	and deaths.date = vaxs.date
--where deaths.continent is not null
--order by 2,3

Select *, (PeopleVaxRolling/Population)*100
From PopVsVax


-- Creating VIEW to store data for viz

Create View #PercentPopVaxd as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaxs.new_vaccinations, SUM(CONVERT(int, vaxs.new_vaccinations)) 
	OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as PeopleVaxRolling
From Project2_CovidData..CovidDeaths deaths
Join Project2_CovidData..CovidVax vaxs
	On deaths.location = vaxs.location
	and deaths.date = vaxs.date
where deaths.continent is not null
--order by 2,3

Select *
From PercentPopVaxd

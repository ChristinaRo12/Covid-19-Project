select * 
from PorfolioProject..['Covid deaths$']
order by 3,4


--select * 
--from PorfolioProject..['Covid Vaccinations$']
--order by 3,4


--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths,population
from PorfolioProject ..['Covid deaths$']
order by 1,2

--Looking at Total Cases Vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
from PorfolioProject ..['Covid deaths$']
order by 1,2

--Looking at Total Cases Vs Total Deaths at States 
-- Shows likelihood of dying if you contract covid in your country 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
from PorfolioProject ..['Covid deaths$']
Where location like '%states%'
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got Covid

Select location, date, Population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
from PorfolioProject ..['Covid deaths$']
-- Where location like '%states%'
order by 1,2 

-- Looking at Countries with Highest Infection Rate compated to population

Select location, Population, Max(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
from PorfolioProject ..['Covid deaths$']
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select location, Max(Cast(Total_deaths as bigint)) As TotalDeathCount
from PorfolioProject..['Covid deaths$']
Group by location
Order by TotalDeathCount desc

Select location, Max(Cast(Total_deaths as int)) As TotalDeathCount
from PorfolioProject..['Covid deaths$']
Group by location
Order by TotalDeathCount desc

Select location, Max(Cast(Total_deaths as int)) As TotalDeathCount
from PorfolioProject..['Covid deaths$']
-- where location like '%state%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 



-- Showing continents with the Highest Death Count Per population

Select continent, Max(Cast(Total_deaths as int)) As TotalDeathCount
from PorfolioProject..['Covid deaths$']
-- where location like '%state%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

-- Global total_cases, Total_deaths and DeathPercentage by date

Select date, SUM(new_cases) as Total_cases, SUM(Cast(new_deaths as int)) as Total_deaths, SUM(Cast(New_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
From PorfolioProject ..['Covid deaths$']
-- Where location like '%states%'
where continent is not null
group by date
order by 1,2

-- Global Total_cases, Total_deaths and DeathPercentage

Select SUM(new_cases) as Total_cases, SUM(Cast(new_deaths as int)) as Total_deaths, SUM(Cast(New_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
From PorfolioProject ..['Covid deaths$']
-- Where location like '%states%'
where continent is not null
-- group by date
order by 1,2


-- Going over Vaccination data and numbers

Select *
From PorfolioProject..['Covid Vaccinations$']

-- Joining both of the tables coviddeaths and covidvaccinations

Select *
From PorfolioProject..['Covid deaths$'] dea
Join PorfolioProject..['Covid Vaccinations$'] Vac
On dea.location = Vac.location
and dea.date = Vac.date

-- Looking at Total Population Vs Total Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PorfolioProject..['Covid deaths$'] dea
Join PorfolioProject..['Covid Vaccinations$'] Vac
On dea.location = Vac.location
and dea.date = Vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PorfolioProject..['Covid deaths$'] dea
Join PorfolioProject..['Covid Vaccinations$'] Vac
On dea.location = Vac.location
and dea.date = Vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PorfolioProject..['Covid deaths$'] dea
Join PorfolioProject..['Covid Vaccinations$'] Vac
On dea.location = Vac.location
and dea.date = Vac.date
where dea.continent is not null
order by 2,3

-- Total number of people vaccinated vs total population  

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population) * 100
From PorfolioProject..['Covid deaths$'] dea
Join PorfolioProject..['Covid Vaccinations$'] Vac
On dea.location = Vac.location
and dea.date = Vac.date
where dea.continent is not null
order by 2,3

-- Use CTE or temp table

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
From PorfolioProject..['Covid deaths$'] dea
Join PorfolioProject..['Covid Vaccinations$'] Vac
On dea.location = Vac.location
and dea.date = Vac.date
where dea.continent is not null
-- order by 2,3
)
Select * 
From PopvsVac 

-- USE CTE finding the % of people are vaccinated vs the total population

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population) * 100
From PorfolioProject..['Covid deaths$'] dea
Join PorfolioProject..['Covid Vaccinations$'] Vac
On dea.location = Vac.location
and dea.date = Vac.date
where dea.continent is not null
 -- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100 as Percentage_TotalNumber_Vaccinated
From PopvsVac 

-- TEMP Table 

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population) * 100
From PorfolioProject..['Covid deaths$'] dea
Join PorfolioProject..['Covid Vaccinations$'] Vac
On dea.location = Vac.location
and dea.date = Vac.date
where dea.continent is not null
 -- order by 2,3

 Select *, (RollingPeopleVaccinated/Population) * 100 as Percentage_TotalNumber_Vaccinated
From #PercentPopulationVaccinated

-- Drop table 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population) * 100
From PorfolioProject..['Covid deaths$'] dea
Join PorfolioProject..['Covid Vaccinations$'] Vac
On dea.location = Vac.location
and dea.date = Vac.date
-- where dea.continent is not null
 -- order by 2,3

 Select *, (RollingPeopleVaccinated/Population) * 100 as Percentage_TotalNumber_Vaccinated
From #PercentPopulationVaccinated

-VIEWS

--GLOBAL NUMBERS

-- View showing Global total_cases, Total_deaths and DeathPercentage by date
Create view Global_TotalCases_TotalDeaths_DeathPercentage as 
Select date, SUM(new_cases) as Total_cases, SUM(Cast(new_deaths as int)) as Total_deaths, SUM(Cast(New_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
From PorfolioProject ..['Covid deaths$']
-- Where location like '%states%'
where continent is not null
group by date
--order by 1,2


-- View showing continents with the Highest Death Count Per population

Create view HighestDeathPerPopulation as 
Select continent, Max(Cast(Total_deaths as int)) As TotalDeathCount
from PorfolioProject..['Covid deaths$']
-- where location like '%state%'
Where continent is not null
Group by continent
--Order by TotalDeathCount desc

-- Creating View to store data for later Visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population) * 100
From PorfolioProject..['Covid deaths$'] dea
Join PorfolioProject..['Covid Vaccinations$'] Vac
On dea.location = Vac.location
and dea.date = Vac.date
where dea.continent is not null
 -- order by 2,3


Select *
From PercentPopulationVaccinated










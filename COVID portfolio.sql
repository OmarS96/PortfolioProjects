--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select *
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--shows the likelihood of dying if you conrract covid in your country

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at the total cases vs population

Select Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Countries with high infection rate compared to population

Select Location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location , population
order by PercentPopulationInfected desc


-- Countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location 
order by TotalDeathCount desc


-- BREAKING THIS DOWN BY CONTINENT



-- Showing the continents with highest death count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent 
order by TotalDeathCount desc



-- Global numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
--Group by Date
order by 1,2

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

with popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccincated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select * , (RollingPeopleVaccincated/Population)*100
From popvsvac


-- TEMP Table

 Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated


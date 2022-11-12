select * from [Portfolio project]..CovidDeaths$
where continent is not null
order by 3,4

--select * from [Portfolio project]..CovidVaccinations$
--order by 3,4    
                                                       
-- Select data that we are going to be using from the imported tables (all data)

select Location, date, total_cases,new_cases,total_deaths,population 
from [Portfolio project]..CovidDeaths$
order by 1,2

-- Looking at Total cases vs total deaths
-- The deathpercentage shows chance of dying if you get covid in any country
select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeaths$
where Location like '%states%' 
order by 1,2

-- looking at Total cases vs population
-- what percentage of the population got Covid
select Location, date, population,total_cases, (total_cases/population)*100 as InfectedPercentage
from [Portfolio project]..CovidDeaths$
--where Location like '%states%' 
order by 1,2

-- Among all countries, which counntries highest infection comparted to population
select Location, population,max(total_cases) as HighestInfection, max((total_cases/population))*100 as InfectedPercentage
from [Portfolio project]..CovidDeaths$
--where Location like '%states%' 
group by Location, population
order by InfectedPercentage desc

--lets break things down by continent

-- show countries with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths$
where continent is not null
--where Location like '%states%' 
group by continent
order by TotalDeathCount desc

-- Showing the continent with highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths$
where continent is not null
--where Location like '%states%' 
group by continent
order by TotalDeathCount desc

-- GLOBAL numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage--total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeaths$
--where Location like '%states%' 
where continent is not null
--group by date
order by 1,2 

-- looking at total population vs vaccinations

-- Using CTE

with PopvsVac  (Continent,Location,Date,Population, New_Vaccinations, RollingPeopleVac)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVac
--, (RollingPeopleVac/population)*100
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVac/Population)*100
from PopvsVac

-- Temp table
Drop table if exists #PercentPopVac
Create table #PercentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVac numeric)

Insert into #PercentPopVac
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVac
--, (RollingPeopleVac/population)*100
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVac/Population)*100
from #PercentPopVac

--Create view to store data for later

Create view PercentPopVac as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVac
--, (RollingPeopleVac/population)*100
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopVac
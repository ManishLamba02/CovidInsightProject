--Total death VS Total Cases (Likehood of dying if someone has the COVID in their country)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Covid Portfolio Project]..CovidDeaths$
where continent is not null
--where location like 'Germ%'
order by 1,2

-- Total cases VS Population
-- Showing how much % of population got COVID 
select location, date, total_cases, population, (total_cases/population)*100 as PopulationInfectedPercent
from [Covid Portfolio Project]..CovidDeaths$
where continent is not null
--where location like 'Germ%'
order by 1,2

-- Showing which countries have highest infection rate
select location, max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PopulationInfectedPercent
from [Covid Portfolio Project]..CovidDeaths$
where continent is not null
group by location
order by PopulationInfectedPercent desc

-- Showing which countries having highest death count
select location, max(cast(total_deaths as int)) as HighestDeathCount
from [Covid Portfolio Project]..CovidDeaths$
where continent is not null
group by location
order by HighestDeathCount desc

--BREAK THINGS DOWN BY CONTINENT
select continent, max(cast(total_deaths as int)) as HighestDeathCount
From [Covid Portfolio Project]..CovidDeaths$
where continent is not null
group by continent
order by HighestDeathCount desc


--GLOBAL NUMBER

select location, date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths --(sum(cast(new_deaths as int))/SUM(new_cases)) as DeathPercent
from [Covid Portfolio Project]..CovidDeaths$
where continent is not null
group by location,date
--where location like 'Germ%'
order by 1,2




-- SHOWING TOTAL VACCINATION VS POPULATION
select DT.continent, DT.location, dt.date, dt.population, vc.new_vaccinations,
sum(cast(vc.new_vaccinations as bigint)) OVER (Partition by dt.location order by dt.location,dt.date) as RollingPeopleVaccinated
from [Covid Portfolio Project]..CovidDeaths$ dt
join [Covid Portfolio Project]..CovidVaccination$ vc
	  on dt.location = vc.location
	  and dt.date = vc.date
where dt.continent is not null
order by 2,3

-- Use of CTE 

with PopVsVac (Continent, location, Date, Population, New_Vaccination, RollingVaccineDose)
AS
(
select DT.continent, DT.location, dt.date, dt.population, vc.new_vaccinations,
sum(cast(vc.new_vaccinations as bigint)) OVER (Partition by dt.location order by dt.location,dt.date) as RollingVaccineDose
from [Covid Portfolio Project]..CovidDeaths$ dt
join [Covid Portfolio Project]..CovidVaccination$ vc
	  on dt.location = vc.location
	  and dt.date = vc.date
where dt.continent is not null
)
select *, (RollingVaccineDose/Population)*100
from PopVsVac
--where location='Germany'


--  Temp Table

DROP TABLE IF exists #PercentPopulationDose
Create Table #PercentPopulationDose
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingVaccineDose numeric
)

Insert into #PercentPopulationDose
select DT.continent, DT.location, dt.date, dt.population, vc.new_vaccinations,
sum(cast(vc.new_vaccinations as bigint)) OVER (Partition by dt.location order by dt.location,dt.date) as RollingVaccineDose
from [Covid Portfolio Project]..CovidDeaths$ dt
join [Covid Portfolio Project]..CovidVaccination$ vc
	  on dt.location = vc.location
	  and dt.date = vc.date
where dt.continent is not null

select *, (RollingVaccineDose/Population)*100
from #PercentPopulationDose



--	CREATING VIEWS FOR LATER VISUALIZATION IN BI TOOLS

Create view PercentPeopleDosed as 
select DT.continent, DT.location, dt.date, dt.population, vc.new_vaccinations,
sum(cast(vc.new_vaccinations as bigint)) OVER (Partition by dt.location order by dt.location,dt.date) as RollingVaccineDose
from [Covid Portfolio Project]..CovidDeaths$ dt
join [Covid Portfolio Project]..CovidVaccination$ vc
	  on dt.location = vc.location
	  and dt.date = vc.date
where dt.continent is not null


select *
from PercentPeopleDosed

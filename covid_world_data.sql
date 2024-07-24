-- Looking at Total Cases vs Total Deaths in Mexico

select location, `date`, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location = 'mexico'

-- Looking at Total Cases vs Population

select location, `date`, population, total_cases, (total_cases/population)*100 as DeathPercentage
from coviddeaths
where location = 'mexico'

-- Looking at countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighesteInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths
group by location, population
order by PercentPopulationInfected desc

-- Looking at countries with Highest Death Count per Population

select location, max(total_deaths) as TotalDeathCount
from coviddeaths
where continent <> ''
group by location
order by TotalDeathCount desc

-- Looking at continents with Highest Death Count

select location, max(total_deaths) as TotalDeathCount
from coviddeaths
where continent = ''
group by location
order by TotalDeathCount desc

-- Global death count

select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from coviddeaths
where continent <> ''

-- Looking at total population vs vaccinations

select death.continent, death.location, death.`date`, death.population, vaccinations.new_vaccinations,
	sum(vaccinations.new_vaccinations) over (partition by death.location order by death.`date`) as RollingPeopleVaccinated
from coviddeaths death
join covidvaccinations vaccinations
	on death.location = vaccinations.location
	and death.`date` = vaccinations.`date`
where death.continent <> ''
order by 2, 3

-- Use CTE (Commn Table Expression)

with PopVsVac (Continent, Location, `Date`, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.`date`, death.population, vaccinations.new_vaccinations,
	sum(vaccinations.new_vaccinations) over (partition by death.location order by death.`date`) as RollingPeopleVaccinated
from coviddeaths death
join covidvaccinations vaccinations
	on death.location = vaccinations.location
	and death.`date` = vaccinations.`date`
where death.continent <> ''
)
select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

-- Create view to store data for later visualization

create view PercentPopulationVaccinatedView as
select death.continent, death.location, death.`date`, death.population, vaccinations.new_vaccinations,
	sum(vaccinations.new_vaccinations) over (partition by death.location order by death.`date`) as RollingPeopleVaccinated
from coviddeaths death
join covidvaccinations vaccinations
	on death.location = vaccinations.location
	and death.`date` = vaccinations.`date`
where death.continent <> ''
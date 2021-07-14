Select location, date, total_cases, new_cases, total_deaths, population
From covidProject..Covid_death
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as deathPercentage
From covidProject..Covid_death
Where location Like '%states%'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid in USA

Select location, date, total_cases, population, (total_cases/population)* 100 as covidInfectionRate
From covidProject..Covid_death
Where location Like '%states%'
order by 1, 2

-- Looking at Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)* 100 as covidInfectionRate
From covidProject..Covid_death
Where continent is not NULL
Group by location, population
order by covidInfectionRate desc

-- Looking at Countries with highest death count
Select location, MAX(cast(total_deaths as int)) as totalDeathCount
From covidProject..Covid_death
Where continent is not NULL
Group by location
order by totalDeathCount desc

-- Looking at Continents with highest death count
Select location, MAX(cast(total_deaths as int)) as totalDeathCount
From covidProject..Covid_death
Where continent is NULL
Group by location
order by totalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From covidProject..Covid_death
where continent is not NULL
Group by date
order by DeathPercentage desc


--Looking at total popuation vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) --can also do CONVERT(int, vac.new_vaccinations)
OVER (Partition by dea.location Order by dea.location , dea.date) as VaccineTotal --Breaking up by location
From covidProject..Covid_death dea
JOIN covidProject..Covid_vaccination vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
order by 1, 2, 3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, VaccineTotal)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int))
OVER (Partition by dea.location Order by dea.location , dea.date) as VaccineTotal
From covidProject..Covid_death dea
JOIN covidProject..Covid_vaccination vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
)

Select *, (VaccineTotal/population)*100 as vacPerPop
From PopvsVac
order by 2, 3


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
total_vaccinated numeric,
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) 
OVER (Partition by dea.location Order by dea.location , dea.date) as VaccineTotal
From covidProject..Covid_death dea
JOIN covidProject..Covid_vaccination vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL

Select *, total_vaccinated/population*100 as vacPerPop
From #PercentPopulationVaccinated
order by 2, 3


--Create View to store date for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location , dea.date) as VaccineTotal
From covidProject..Covid_death dea
JOIN covidProject..Covid_vaccination vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL

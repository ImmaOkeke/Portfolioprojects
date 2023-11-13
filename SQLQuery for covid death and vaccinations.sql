Select *
From Portfolioprojects..CovidDeathMain
Where continent is not null
Order by 3,4

Select *
From Portfolioprojects..CovidVaccinationMain
Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolioprojects..CovidDeathMain
Where continent is not null
order by 1,2


Select Location, date, total_cases,total_deaths,(CAST(total_deaths as decimal)/ CAST(total_cases as decimal))*100 as Deathpercentages
From Portfolioproject..CovidDeathMain
Where continent is not null
Where Location like 'Germany'
order by 1,2

---Showing the death likelihood of individuals that caught corona per location
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF (CONVERT(float, total_cases), 0)) * 100 as DeathPerentage
From Portfolioprojects..CovidDeathMain
Where Location like '%many%'
Where continent is not null
order by 1,2

--- Showing percentage of population infected per location
Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF (CONVERT(float, population), 0)) * 100 as PercentofPopulationInfected
From Portfolioprojects..CovidDeathMain
--Where Location like '%many%'
Where continent is not null
order by 1,2

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max(( total_cases/population)) * 100 as percentageofPopulationInfected
From Portfolioprojects..CovidDeathMain
--Where Location like '%many%'
Where continent is not null
Group by population, Location
order by PercentageofPopulationInfected desc

--- Countries with highest death count per population

Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From Portfolioprojects..CovidDeathMain
--Where Location like '%many%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

---Continents with highest death count
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From Portfolioprojects..CovidDeathMain
--Where Location like '%many%'
Where Continent is not null
Group by continent
order by TotalDeathCount desc

---Global Numbers
Select SUM(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int)) / Sum(new_cases) * 100 as DeathPerentage
From Portfolioprojects..CovidDeathMain
--Where Location like '%many%'
Where continent is not null
--Group by date
order by 1,2

---looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
From Portfolioprojects..CovidDeathMain dea
Join Portfolioprojects..CovidVaccinationMain vac
on dea.location = vac.location
and dea.date = vac.date
and dea.population = vac.population
Where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioprojects..CovidDeathMain dea
Join Portfolioprojects..CovidVaccinationMain vac
on dea.location = vac.location
and dea.date = vac.date
and dea.population = vac.population
Where dea.continent is not null
--order by 2,3
)
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM
    PopvsVac;


	---TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioprojects..CovidDeathMain dea
Join Portfolioprojects..CovidVaccinationMain vac
on dea.location = vac.location
and dea.date = vac.date
and dea.population = vac.population
Where dea.continent is not null
--order by 2,3

SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM
  #PercentPopulationVaccinated



 
 ---Creating view to store data for later visualisations
 Create view PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioprojects..CovidDeathMain dea
Join Portfolioprojects..CovidVaccinationMain vac
on dea.location = vac.location
and dea.date = vac.date
and dea.population = vac.population
Where dea.continent is not null
--order by 2,3

Create view ContinentwwithhighestDeathCount as
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From Portfolioprojects..CovidDeathMain
--Where Location like '%many%'
Where Continent is not null
Group by continent
--order by TotalDeathCount desc

Create view CountrieswithhighestDeathCount as
Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From Portfolioprojects..CovidDeathMain
--Where Location like '%many%'
Where continent is not null
Group by Location
--order by TotalDeathCount desc

Create view PopInfectedperLocation as
Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF (CONVERT(float, population), 0)) * 100 as PercentofPopulationInfected
From Portfolioprojects..CovidDeathMain
--Where Location like '%many%'
Where continent is not null
--order by 1,2

Create view DeathLikelihoodperlocation as
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF (CONVERT(float, total_cases), 0)) * 100 as DeathPerentage
From Portfolioprojects..CovidDeathMain
--Where Location like '%many%'
Where continent is not null
--order by 1,2

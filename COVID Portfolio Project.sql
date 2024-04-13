Select*
From PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

Select*
From PortofolioProject..CovidVaccinations
order by 3,4

--Select data that we are going to be using

Select location, date,total_cases,new_cases,total_deaths,population
From PortofolioProject..CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date,total_cases,total_deaths,CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)*100 AS death_percentage
From PortofolioProject..CovidDeaths
where location like '%kenya%'
order by 1,2


--Looking at the Total cases vs Population
--Shows what percentage of population got Covid

Select location, date,population,total_cases,CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)*100 AS PercentPopulationInfected
From PortofolioProject..CovidDeaths
where location like '%kenya%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population

Select location,population,MAX(total_cases)AS HighestInfectionCount ,max(CAST(total_cases AS FLOAT))  / NULLIF(CAST(population AS FLOAT), 0)*100 AS PercentPopulationInfected
From PortofolioProject..CovidDeaths
where location like '%kenya%'
order by 1,2



SELECT location,population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(CAST(total_cases AS FLOAT)) / NULLIF(CAST(population AS FLOAT), 0) * 100 AS PercentPopulationInfected
FROM 
    PortofolioProject..CovidDeaths
WHERE 
    location LIKE '%Africa%'
GROUP BY location,population
ORDER BY PercentPopulationInfected desc

--Showing countries with highest Death Count per Population
SELECT location,MAX(CAST(Total_deaths AS Int)) as TotalDeathCount
FROM 
    PortofolioProject..CovidDeaths
WHERE 
    location LIKE '%Africa%'
and continent is not nuLl
GROUP BY location
ORDER BY TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

SELECT continent,MAX(CAST(Total_deaths AS Int)) as TotalDeathCount
FROM 
    PortofolioProject..CovidDeaths
WHERE 
    location LIKE '%Africa%'
and continent is not nuLl
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases)as total_cases,SUM(new_deaths)as total_deaths,SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS death_percentage
From PortofolioProject..CovidDeaths
--where location like '%Kenya%'
where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date)as
RollingPeopleVaccinated
,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  order by 2,3

  --USE CTE
  with PopvsVac(Continent,Location, Date, Population, New_vaccinations,RollingPeopleVaccinated)
  as
  (
  Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date)as
RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  --order by 2,3
  )
  Select*,(RollingPeopleVaccinated/Population)*100
  From PopvsVac

  --TEMP TABLE

  Drop Table if exists #PercentPopulationVaccinated
  Create Table #PercentPopulationVaccinated
  (
  Continent nvarchar (255),
  Location nvarchar (255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )


  Insert into #PercentPopulationVaccinated
  Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date)as
RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
  --where dea.continent is not null
  --order by 2,3
  Select*,(RollingPeopleVaccinated/Population)*100
  From #PercentPopulationVaccinated


  --Creating View to store data for later visualizations

  create view PercentPopulationVaccinated as
  Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date)as
RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  --order by 2,3


  select*
  From PercentPopulationVaccinated
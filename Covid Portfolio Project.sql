Select * from PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4

--Select * from PortfolioProject..CovidVaccinations order by 3,4

--Select data that we are going to be using 

Select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject..CovidDeaths 
where continent is not null
order by 1,2

--looking at total cases vs total death
--shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and
where continent is not null
order by 1,2

--looking at total cases vs population
--shows what % of population got covid

Select location,date,population,total_cases, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
where location = 'India' 
order by 1,2

--looking at countries with highest infection rate compared to popuation 

Select location,population,MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population)*100) as PercentagepopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'India' 
Group by location,population
order by PercentagepopulationInfected desc

--showing countries with highest death count per population 

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


--Showing continent with highest death count per population

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%' and
where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%' and
where continent is not null
--Group by date
order by 1,2


-- join Covid vaccination
Select * 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location and 
 dea.date = vac.date

--Looking at total population vs Vaccination

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) AS rollingPeopleVaccinated,
 --(rollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location and 
 dea.date = vac.date
where dea.continent is not null
order by 2,3

 --use CTE
 With PopvsVac(continent,location,date,population,new_vaccinations,rollingPeopleVaccinated)
 as
 (
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) AS rollingPeopleVaccinated
-- (rollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location and 
 dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingPeopleVaccinated/population)*100 
from PopvsVac

--Temp table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) AS rollingPeopleVaccinated
-- (rollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location and 
 dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(rollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


--Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as 

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CONVERT(INT,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) AS rollingPeopleVaccinated
-- (rollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location and 
 dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated
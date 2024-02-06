select location ,date,total_cases,new_cases,total_cases,population
from PortfolioProject..CovidDeathInfo$
order by 1, 2 

--looking at total cases vs total deaths
--shows liklihood of dying if you contract covid in your country
select location ,date,total_cases,total_deaths,(CONVERT (float,total_deaths) / nullif(convert(float,total_cases),0))*100 as DeathPercentage
from PortfolioProject..CovidDeathInfo$
where location like '%states%'
order by 1, 2 

--looking at total cases vs population

select location ,date,population,total_cases,(CONVERT (float,total_cases) / nullif(convert(float,population),0))*100 as DeathPercentage
from PortfolioProject..CovidDeathInfo$
where location like '%states%'
order by 1, 2 

--looking at countries with highest infection rate compared to population
select location ,population,Max (total_cases) as HighestInfectionCount ,Max (CONVERT (float,total_cases) / nullif(convert(float,population),0))*100 
as PercntPopulationInfected
from PortfolioProject..CovidDeathInfo$
--where location like '%states%'
group by location,Population
order by PercntPopulationInfected desc

--showing countries with highest death count per population
select location ,Max(cast (total_deaths as int)) as totalDeathcount
from PortfolioProject..CovidDeathInfo$
--where location like '%states%'
where continent is not null
group by location,Population
order by totalDeathcount desc

--lets break things down by continent(showing continents with highest death count per population)
select continent ,Max(cast (total_deaths as int)) as totalDeathcount
from PortfolioProject..CovidDeathInfo$
--where location like '%states%'
where continent is not null
group by continent
order by totalDeathcount desc

--global numbers 

select sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeathInfo$
--where location like '%states%'
where continent is not null
--group by date
order by 1, 2 

--looking total population vs vaccinations 

select dea.continent, dea.location ,dea.date, dea.population , vac.new_vaccinations, 
sum(CONVERT (bigint,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,dea.date) as rollingpeopleVaccinated
from PortfolioProject..CovidDeathInfo$ dea
join PortfolioProject..CovidVaccinationsInfo$ vac
    on dea.location = vac.location
    and dea.date = vac.date 
 where dea.continent is not null
 order by 2,3

 --USE CTE
 with PopvsVac (continent ,location,date ,population,new_vaccinations,rollingpeopleVaccinated) as
 (select dea.continent, dea.location ,dea.date, dea.population , vac.new_vaccinations, 
sum(CONVERT (bigint,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,dea.date) as rollingpeopleVaccinated
from PortfolioProject..CovidDeathInfo$ dea
join PortfolioProject..CovidVaccinationsInfo$ vac
    on dea.location = vac.location
    and dea.date = vac.date 
 where dea.continent is not null
 --order by 2,3)
 )
 select *,(rollingpeopleVaccinated/population)*100
 from PopvsVac

 --Temp table 
 create table  #percentpopulationvaccinated
 (
 continent nvarchar(255), 
 location nvarchar(255), 
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeopleVaccinated numeric)
 insert into #percentpopulationvaccinated
 select dea.continent, dea.location ,dea.date, dea.population , vac.new_vaccinations, 
sum(CONVERT (bigint,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,dea.date) as rollingpeopleVaccinated
from PortfolioProject..CovidDeathInfo$ dea
join PortfolioProject..CovidVaccinationsInfo$ vac
    on dea.location = vac.location
    and dea.date = vac.date 
 where dea.continent is not null
 --order by 2,3)
 select *,(rollingpeopleVaccinated/population)*100
 from #percentpopulationvaccinated

create view [percentagepopulationvaccinated] as
  select dea.continent, dea.location ,dea.date, dea.population , vac.new_vaccinations, 
sum(CONVERT (bigint,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,dea.date) as rollingpeopleVaccinated
from PortfolioProject..CovidDeathInfo$ dea
join PortfolioProject..CovidVaccinationsInfo$ vac
    on dea.location = vac.location
    and dea.date = vac.date 
 where dea.continent is not null
 --order by 2,3)
GO


select *
from percentagepopulationvaccinated
Select*
from ProtfolioProject..['Covid-Deaths']
Where continent is not null
order by 3,4


Select*
from ProtfolioProject..['Covid-Vaccinations']
Where continent is not null
order by 3,4

select Location, date, new_cases, total_cases, total_deaths, population

from ProtfolioProject..['Covid-Deaths']
Where continent is not null
order by 1,2

--Looking at total_Deaths versus total_cases
--shows the ,likelyhood of dying if you contract in india

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProtfolioProject..['Covid-Deaths']
Where Location like '%India%'
Where continent is not null
order by 1,2

--Looking at the total_cases vs the population
--shows what percentage of population got covid

select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from ProtfolioProject..['Covid-Deaths']
--Where Location like '%India%'
Where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

select Location, population, MAX(total_cases) as HIGHESTINFECTIONCOUNT, MAX((total_cases/population))*100 
as PercentPopulationInfected
from ProtfolioProject..['Covid-Deaths']
--Where Location like '%India%'
Group by Location, population
order by PercentPopulationInfected desc

-- This is showing the countries with the highest deathcount per population

--Lets break this down by continent

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProtfolioProject..['Covid-Deaths']
--Where Location like '%India%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Lets break this down by continent
--This is showing the continent with the highest deathcount

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProtfolioProject..['Covid-Deaths']
--Where Location like '%India%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases ) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from ProtfolioProject..['Covid-Deaths']
Where continent is  not null
--Group by date
order by 1, 2

Select * 
from ProtfolioProject..['Covid-Deaths'] dea
Join ProtfolioProject..['Covid-Vaccinations'] vac
 On dea.location = vac.location
 and dea.date = vac.date
 order by 1, 2

 --Looking at TotalPopulation vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from ProtfolioProject..['Covid-Deaths'] dea
Join ProtfolioProject..['Covid-Vaccinations'] vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is  not null
 order by 2, 3
	

	--CTE
With PopVsVac(Continent, Location, Date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from ProtfolioProject..['Covid-Deaths'] dea
Join ProtfolioProject..['Covid-Vaccinations'] vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is  not null
 --order by 2, 3
 )
 select *, (RollingPeopleVaccinated/population)*100 from
 PopVsVac

 --TempTable
 Drop Table if exists #PercentPeopleVaccinated
 Create Table #PercentPeopleVaccinated
 (
 continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
)

 Insert into #PercentPeopleVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from ProtfolioProject..['Covid-Deaths'] dea
Join ProtfolioProject..['Covid-Vaccinations'] vac
 On dea.location = vac.location
 and dea.date = vac.date
 --Where dea.continent is  not null
 --order by 2, 3

 select * ,(RollingPeopleVaccinated/population)*100
 from #PercentPeopleVaccinated


 --Creating view to store data for visualisation
 
 Create View PercentPeopleVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from ProtfolioProject..['Covid-Deaths'] dea
Join ProtfolioProject..['Covid-Vaccinations'] vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is  not null
 --order by 2, 3
 

 Create View PeopleVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from ProtfolioProject..['Covid-Deaths'] dea
Join ProtfolioProject..['Covid-Vaccinations'] vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is  not null
 --order by 2, 3
 
 Select * from PercentPeopleVaccinated
 

select*
From portfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--select*
--From portfolioProject..CovidVaccinations
--order by 3,4

--Select data that going to be used

Select Location,date, total_cases,new_cases, total_deaths, population
From portfolioProject..CovidDeaths
Order by 1,2

--Observing at the Total Cases vs Total Deaths
--Showing likelihood of deaths if in contact with Covid in your country

Select Location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathPercentage
From portfolioProject..CovidDeaths
Where location like '%States%'
and continent is not null
Order by 1,2

--Looking t the Total Cases vc Population
--Shows what percentage of population got Covid

Select Location,date, total_cases,population, (total_deaths/population)*100 as PercentPopulationInfected
From portfolioProject..CovidDeaths
--Where location like '%States%'
Order by 1,2


-- Looking at countries with Highest Rate compared to population

Select Location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
From portfolioProject..CovidDeaths
--Where location like '%States%'
Group by Location, population
Order by PercentPopulationInfected desc

--Showing countries with Highest Deaths Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Let's break it down by continent


--Showing continents with the highest death counts per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From portfolioProject..CovidDeaths
--Where location like '%States%'
where continent is not null
--Group by date
Order by 1,2

--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccincated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac. date
	where dea.continent is not null
Order by 2,3

--Use CTE

With PopvsVac (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVacccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccincated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
--Order by 2,3
)
Select*, (RollingPeopleVacccinated/Population)*100
From PopvsVac


--Temp table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccincated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
--Order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create View to store data for later visualizations

Create View PercentPopulationVacc as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccincated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
--Order by 2,3

Select*
From PercentPopulationVacc





select * from CovidVaccinations where location='Afghanistan'

select * from CovidDeaths
where location='India' order by date desc

select location,date,total_cases,new_cases,total_deaths,population  from CovidDeaths
order by location,date

--Looking at Total deaths vs total cases
--Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths)/(total_cases)*100 
as DeathPercentage
from CovidDeaths
where location ='India'
order by location,date



--what percentage of population got covid
select location,date,population, total_cases ,(total_cases)/(population)*100 
as PercentpopulationInfected
from CovidDeaths
--where location ='India'
order by location,date

--looking at countries with highest infection rate compared to population
select location,population,Max(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentpopulationInfected  from CovidDeaths
--where location='India'
group by population,location
order by PercentpopulationInfected desc

--Showing Countries with highest death count per population

select  * from CovidDeaths
where location='United States' and continent is not null

select location,population,Max(cast(total_deaths as int)) as HighestDeaths,Max(cast(total_deaths as int))/(population)*100 
as HighestDeathRate
from CovidDeaths
where continent is not null 
group by location,population
order by HighestDeathRate desc

--Breaking it down into continents
--Highest Death Count and Rate in terms of continents

select location,population,Max(cast(total_deaths as int)) as HighestDeaths,
Max(cast(total_deaths as int))/(population)*100 
as HighestDeathRate
from CovidDeaths
where continent is null and location!='World'and location!='International'
group by location,population
order by HighestDeaths desc

--Showing continents with the Highest death count per population

select continent,Max(cast(total_deaths as int)) as HighestDeaths
from CovidDeaths
where continent is not null 
group by continent
order by HighestDeaths desc

--Breaking down into global numbers

select date, Sum(new_cases) as TotalNewCases,Sum(cast(new_deaths as int)) as TotalNewDeaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage
from CovidDeaths
where continent is not null
group by date
order by date

select Sum(new_cases) as TotalNewCases,Sum(cast(new_deaths as int)) as TotalNewDeaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


--Lokking at total popualtion vs Vaccination

select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/dea.population)*100
from CovidDeaths dea
inner join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null --and vac.new_vaccinations is not null and dea.location='India'
order by dea.location,dea.continent




--USE CTE Total Percentage of people vaccinated

With popvsvac (Continent,Location,Population,Date,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
inner join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and dea.location='India'
--order by dea.location,dea.continent
)

select *,(RollingPeopleVaccinated/Population)*100 as PercentpopulationVaccinated
from popvsvac
order by PercentpopulationVaccinated desc


--TEMP TABLE PercentPopulationVaccinated

Drop table if exists #PercentpopulationVaccinated
Create table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
Date datetime,
New_Vaccinations numeric,
RollingPeoplevaccinated numeric
)

Insert into #PercentpopulationVaccinated
select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
inner join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null and dea.location='India'
--order by dea.location,dea.continent

select *,(RollingPeopleVaccinated/Population)*100 as PercentpopulationVaccinated
from #PercentpopulationVaccinated
order by PercentpopulationVaccinated desc


--Creating View too store data for later visualization

Create view percentpopulationVaccinated as
select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
inner join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null and dea.location='India'
--order by dea.location,dea.continent

select * from percentpopulationVaccinated

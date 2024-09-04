SELECT * from Portfolio_Project..CovidDeaths
where continent is not NULL
order by 3,4



--SELECT CONVERT(date, GETDATE()) from Portfolio_Project..CovidDeaths

SELECT * from Portfolio_Project..CovidVaccinations
order by 3,4



-- checking data of united states based on total cases and total deaths
-- finds percentage of deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_Project..CovidDeaths
where location like '%states%'
order by Death_Percentage desc




-- looking at continents with highest infection rate

select continent,population, 
MAX(total_cases) as Highest_Infected,
MAX((total_deaths/total_cases))*100 as Death_Percentage
from Portfolio_Project..CovidDeaths
group by continent,population
order by Death_Percentage DESC



--looking at countries with highest infection rate


select location,population, 
MAX(total_cases) as Highest_Infected,
MAX((total_deaths/total_cases))*100 as Death_Percentage
from Portfolio_Project..CovidDeaths
group by location,population
order by Death_Percentage DESC



--Showing countries with highest death count

select location,MAX(cast(total_deaths as int)) as total_death_count
from Portfolio_Project..CovidDeaths 
where continent is not null
group by location
order by total_death_count desc



--continents with highest death count

select continent,MAX(cast(total_deaths as int)) as total_death_count
from Portfolio_Project..CovidDeaths 
where continent is not null
group by continent
order by total_death_count desc




--global numbers

select SUM(new_cases) as total_new_cases,SUM(CAST(new_deaths as int)) as total_new_deaths,(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as latest_death_percentage   --,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2 desc

--getting specific countries info by leaving out common areas

select location,SUM(cast(new_deaths as int)) as Total_death_count
from Portfolio_Project..CovidDeaths
where continent is null
and location not in ('World','European Union','International')
Group by location
order by Total_death_count desc




--covid vaccinations

select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location) as people_vaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 desc



--Using CTE

With populationVAC (continent,location,date,population,new_vaccinations,people_vaccinated)
as 
(
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location) as people_vaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 desc
)
select *, (people_vaccinated/population)*100 as percentage_vaccinated
from populationVAC



--TEMP Table

Drop table if exists percentofpeoplevaccinated
Create table percentofpeoplevaccinated
(
continent nvarchar(255),date datetime,location nvarchar(255),new_vaccinations numeric,people_vaccinated numeric,population numeric
)
Insert into percentofpeoplevaccinated
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location) as people_vaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 desc
select *, (people_vaccinated/population)*100 as percentage_vaccinated
from percentofpeoplevaccinated



--Creating view for visualisation

Create View percentpeoplevaccinated as
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location) as people_vaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 desc

select * from percentpeoplevaccinated


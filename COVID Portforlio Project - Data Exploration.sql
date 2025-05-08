
/*
COVID19 Data Exploration

Skills used:  Joins, CTE's, Team Tables, Windows Functions, Aggregate Functions, Creating Views, Convertins Data Types
*/



-- Running both queries to verify data imported correctly

Select *
from PortfolioProject.dbo.CovidDeaths;

Select *
from CovidVaccinations;

-- Select Data that we are going to be using

-- Sorting the data first by location and then by date ascending which is the default sort order

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2;

-- Let's look at total cases vs total deaths

-- This query shows the running percenatage of deaths per cases by day sorted by country and date

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1, 2;

-- Now we want to run the same query but filter the results to show only the percentage of deaths by day for the United States

-- The results show the running totals for the United States for total cases, total deaths, and the percentage of deaths over time

-- Shows the likelyhood of dying specifically if you live in the United States

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2;

-- Let's look at total cases vs the population - United States

-- Shows what percentage of the population has had COVID19 in the United States over time

Select location, date, population, total_cases, (total_cases/population) * 100 as 'Percentage of Cases'
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2;

-- What countries have the highest case rate based by country

Select location, population, MAX(total_cases) as 'Highest Infection Count', MAX((total_cases/population) * 100) as 'Percent of Population Infected'
from PortfolioProject..CovidDeaths
group by location, population
order by 'Percent of Population Infected' desc;

-- Let's run the same query but now we only want large countries with populations over 100 million

Select location, population, MAX(total_cases) as 'Highest Infection Count', MAX((total_cases/population) * 100) as 'Percent of Population Infected'
from PortfolioProject..CovidDeaths
where population > 100000000
group by location, population
order by 'Percent of Population Infected' desc;

-- Now lets show the countries with the largest death count

-- We run into an issue with the data when we run the query below due to the data formating of total_deaths

Select location, population, MAX(population) as TotalPopulation, MAX(total_deaths) as TotalDeaths
from CovidDeaths
group by location, population
order by TotalDeaths desc;

-- To fix the query above we have to use CAST to modify the data type within the query

-- New we get the data as we expected

Select location, population, MAX(population) as TotalPopulation, MAX(CAST(total_deaths as int)) as TotalDeaths
from CovidDeaths
group by location, population
order by TotalDeaths desc;

-- The query above gives works as expected, however, the results show some unexpected data

-- There is data on continents when we only want to focus on the countries

-- To fix this we will add a where clause to only include countries

-- Here's the same query with the where clause added so that we only get the results for the countries

-- Now we have removed the continents and can analyze the data for the countries

Select location, population, MAX(population) as TotalPopulation, MAX(CAST(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
group by location, population
order by TotalDeaths desc;

-- Population and TotalPopulation are redundant in the query above but I included it as a check to verify the results

-- Here I removed the population from the query to clean up the results

Select location, MAX(population) as TotalPopulation, MAX(CAST(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc;


-- Now let's analyze the higest death rates by country

Select location, MAX(population) as TotalPopulation, MAX(CAST(total_deaths as int)) as TotalDeaths, ((MAX(total_deaths))/(MAX(population))) * 100 as DeathRate
from CovidDeaths
where continent is not null
group by location
order by DeathRate desc;

-- Now let's switch things up and analyze the death rates by continent

-- First I want to look at the data for location and continent to know waht to exclude

-- I will narrow my resuls down to Africa since it is both a country and continent so that I don't have to scroll through the full data

Select continent, location
from CovidDeaths
where continent is null
order by continent;

-- Based on the data I want to return results for the locations where the data in continents is not null

-- Now we want to analyze the highest number of cases by continent

-- The data is not broken out by the 7 continents we typically refer to so here are the results

Select location, SUM(new_cases) as MaxCases
from CovidDeaths
where continent is null and location != 'World' and location != 'European Union'
group by location
order by MaxCases desc;

-- Now I want to add the total number of deaths sorted by the highest number of cases

Select location, SUM(new_cases) as MaxCases, SUM(CAST(new_deaths as int)) as MaxDeaths
from CovidDeaths
where continent is null and location != 'World' and location != 'European Union'
group by location
order by MaxCases desc;

-- Now let's analyze the highest percentage of deaths by continent based on total number of cases

Select location, SUM(new_cases) as MaxCases, SUM(CAST(new_deaths as int)) as MaxDeaths, ((SUM(CAST(new_deaths as int)))/(SUM(new_cases))) * 100 as DeathRate
from CovidDeaths
where continent is null and location != 'World' and location != 'European Union'
group by location
order by DeathRate desc;

-- Let's take it one step further and add population and also get the death rate based on total population

-- I removed the results for "International" to clean up the data because it does not have any population data and to remove the null

Select location, population, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, ((SUM(CAST(new_deaths as int)))/(SUM(new_cases))) * 100 as CaseDeathRate,
	((SUM(CAST(new_deaths as int)))/(MAX(population))) * 100 as PopulationDeathRate
from CovidDeaths
where continent is null and location != 'World' and location != 'European Union' and population is not null
group by location, population
order by PopulationDeathRate desc;

-- Global Numbers (Numbers not dependent on location or continent)

-- Let's look at new cases by date

Select date, SUM(new_cases) as NewDailyCases
from CovidDeaths
where continent is not null
group by date
order by date;

-- Now we add new deaths by date

-- NOTE:  Just a reminder that since new_deaths is formatted as nvarchar we have to modify the format while we don't have
-- to do that with new_cases since it is formatted as a float

Select date, SUM(new_cases) as NewDailyCases, SUM(CAST(new_deaths as int)) as NewDailyDeaths
from CovidDeaths
where continent is not null
group by date
order by date;

-- Let's take this further and add the death rates, both by cases and by population

Select date, MAX(population), SUM(new_cases) as NewDailyCases, SUM(CAST(new_deaths as int)) as NewDailyDeaths,
	((SUM(CAST(new_deaths as int)))/(SUM(new_cases))) * 100 as NewCaseDeathRate,
	((SUM(CAST(new_deaths as int)))/(MAX(population))) * 100 as NewPopulationDeathRate
from CovidDeaths
where continent is not null and new_cases != 0
group by date
order by date;

-- Now let's join tables together

-- We'll join the CovidDeaths and CovidVaccinations tables together

-- This Joins the 2 tables togeher as a full outer join

Select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date;


-- New let's look at total population vs vaccinations

-- We want to exclude records where the continent field is null and sort by continent, location, and date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3;

-- New we want to add a rolling sum to add the totals by day in a new column

-- Here I uesed convert to correct the format of new_vaccinatons the same as I used cast before to remove the formatting error

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationTotal
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3;

-- New we want to get the percentage of vaccinations based on population

-- We need to setup a CTE

-- The query below returns as error message that the order by clause cant me used in views (CTE's) so I just commented it out rather than remove it

With PopulationvsVaccinations (continent, location, date, population, new_vaccinations, RollinigVaccinationTotal)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationTotal
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 1, 2, 3;
)
Select *
from PopulationvsVaccinations;

-- Now that the CTE is setup and the query return the expected results we will add the percentage vaccinated calcualtion

With PopulationvsVaccinations (continent, location, date, population, new_vaccinations, RollinigVaccinationTotal)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollinigVaccinationTotal
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 1, 2, 3;
)
Select *,  (RollinigVaccinationTotal / population) * 100 as RollingVaccinationPercent
from PopulationvsVaccinations;

-- Here's a look at the results for the United States only

With PopulationvsVaccinations (continent, location, date, population, new_vaccinations, RollinigVaccinationTotal)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollinigVaccinationTotal
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%states%'
-- order by 1, 2, 3;
)
Select *,  (RollinigVaccinationTotal / population) * 100 as RollingVaccinationPercent
from PopulationvsVaccinations;

-- Now I use a temp table to accomplish the same results as above

Create Table #PercentPopulationVaccinated
(
Continient nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationTotal numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationTotal
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%states%'

Select *,  (RollingVaccinationTotal / population) * 100 as RollingVaccinationPercent
from #PercentPopulationVaccinated;

-- Note:  If we run the complete script above we will receive an error message becuase the temp table is already created

-- To fix this or to make changes we can drop the table first then we can rerun the full cript as below

-- Again, here we are only pulling the data for the United States just to limit the results and to make it easier to verify the results are correct

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continient nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationTotal numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationTotal
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%states%'

Select *,  (RollingVaccinationTotal / population) * 100 as RollingVaccinationPercent
from #PercentPopulationVaccinated;

-- Now we'll create a view to use later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationTotal
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

-- This ran successfully and now we have a the view dbo.PercentPopulationVaccinated in views

-- New we can query off of the view

Select *
from PercentPopulationVaccinated;



-- QUERIES FOR TABLEAU ANALYSIS

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
----where location = 'World'
--Group By date
--order by 1,2



-- 2. 

-- We take these out as they are not inlcuded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 4.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc



-- ADDITIONAL QUERIES

-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
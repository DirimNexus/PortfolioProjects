/*
Covid 19 Data Exploration

Skills used : Joins, CTE'S, Temp Tables, Windows Functions, Aggregate Functions, Creating views, onverting Data Types and so on.

*/

SELECT *
FROM [covid death]
WHERE continent IS NOT NULL
ORDER BY 3,4

--Selecting the Data we are starting with

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [covid death]
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Total Deaths.
--Shows the likelihood of dying if you contract covid in your area.

SELECT location, date, total_cases,total_deaths, (CAST(total_deaths AS decimal(18,2))/CAST(total_cases AS decimal(18,2)))* 100 AS DeathPercentage
FROM [covid death]
WHERE location like '%NIGERIA%'
AND continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Population
--Shows the percentage of population infected with covid

SELECT location, date,population, total_cases,(CAST(total_cases AS decimal(18,2))/CAST(population AS decimal(18,2)))* 100 AS Percentage_Population_Infected
FROM [covid death]
WHERE continent IS NOT NULL
ORDER BY 1,2


--Countries with Highest Infections compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count,MAX(total_cases/population) * 100 AS Percentage_Population_Infected
FROM [covid death]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percentage_Population_Infected DESC


--Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as INT)) AS Total_Death_Count
FROM [covid death]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC


--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

SELECT continent, MAX(CAST( total_deaths as INT)) AS Total_Death_Count
FROM [covid death]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths as INT)) AS Total_Deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 AS Death_Percentage
FROM [covid death]
WHERE continent IS NOT NULL
ORDER BY 1,2


---Total population vs Vaccinations
--This shows the percentage of population that has received at least one covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM [covid death] dea
JOIN [Covid Vaccinations] vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


---Using CTE to perform calculation on partition by in previous query



WITH PopVsVac (continent,location,date,population,new_vaccibations, Rolling_People_Vaccinated)

AS

(
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM [covid death] dea
JOIN [Covid Vaccinations] vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT*, (Rolling_People_Vaccinated/population) * 100
FROM PopVsVac

--Using Temp Table to perform calculations on partition by in previous query.







DROP Table IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE  #Percent_Population_Vaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime ,
population numeric,
new_vaccinated numeric,
Rolling_People_Vaccinated numeric
)
 INSERT INTO #Percent_Population_Vaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM [covid death] dea
JOIN [Covid Vaccinations] vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (Rolling_People_Vaccinated/ population) * 100 Rolling_people_vaccinated_percentage
FROM #Percent_Population_Vaccinated

---Creating views to stoe data for later visaulizations

CREATE VIEW 
Percent_Population_Vaccinated AS 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM [covid death] dea
JOIN [Covid Vaccinations] vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

CREATE VIEW
Total_death_count AS
SELECT continent, MAX(CAST( total_deaths as INT)) AS Total_Death_Count
FROM [covid death]
WHERE continent IS NOT NULL
GROUP BY continent

CREATE VIEW
Global_Number AS
SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths as INT)) AS Total_Deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 AS Death_Percentage
FROM [covid death]
WHERE continent IS NOT NULL


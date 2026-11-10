-- CREATE DATABASE IF NOT EXISTS ai_future_work;
-- USE ai_future_work;

-- CREATE TABLE dim_country (
--  country_id VARCHAR(5) PRIMARY KEY, country_name VARCHAR(80), region VARCHAR(50),
--  digital_readiness_index DECIMAL(5,2), ai_adoption_index DECIMAL(5,2),
--  skills_readiness_index DECIMAL(5,2), gdp_per_capita_ppp_usd INT
-- );
-- CREATE TABLE dim_industry (
--  industry_id VARCHAR(10) PRIMARY KEY, industry_name VARCHAR(100)
-- );
-- CREATE TABLE dim_occupation (
--  occupation_id VARCHAR(10) PRIMARY KEY, occupation_title VARCHAR(120),
--  industry_id VARCHAR(10), FOREIGN KEY (industry_id) REFERENCES dim_industry(industry_id)
-- );
-- CREATE TABLE dim_skill (
--  skill_id VARCHAR(10) PRIMARY KEY, skill_name VARCHAR(100), skill_category VARCHAR(50)
-- );
-- CREATE TABLE bridge_occupation_skill (
--  occupation_id VARCHAR(10), skill_id VARCHAR(10), skill_priority_rank INT,
--  PRIMARY KEY (occupation_id,skill_id),
--  FOREIGN KEY (occupation_id) REFERENCES dim_occupation(occupation_id),
--  FOREIGN KEY (skill_id) REFERENCES dim_skill(skill_id)
-- );
-- CREATE TABLE fact_job_outlook (
--  outlook_id VARCHAR(40) PRIMARY KEY, country_id VARCHAR(5), occupation_id VARCHAR(10), year INT,
--  employment_thousands DECIMAL(12,2), employment_growth_pct DECIMAL(7,2),
--  ai_exposure_pct DECIMAL(6,2), automation_risk_pct DECIMAL(6,2),
--  augmentation_potential_pct DECIMAL(6,2), avg_annual_salary_usd_ppp DECIMAL(14,2),
--  annual_job_openings_thousands DECIMAL(12,2), reskilling_demand_index DECIMAL(6,2),
--  remote_work_share_pct DECIMAL(6,2), ai_adoption_pct DECIMAL(6,2),
--  UNIQUE(country_id,occupation_id,year),
--  FOREIGN KEY (country_id) REFERENCES dim_country(country_id),
--  FOREIGN KEY (occupation_id) REFERENCES dim_occupation(occupation_id),
--  INDEX idx_outlook_year(year), INDEX idx_country_year(country_id,year)
-- );
-- CREATE TABLE fact_skill_demand (
--  skill_demand_id VARCHAR(40) PRIMARY KEY, country_id VARCHAR(5), skill_id VARCHAR(10), year INT,
--  skill_demand_index DECIMAL(6,2), share_of_job_postings_pct DECIMAL(6,2),
--  UNIQUE(country_id,skill_id,year),
--  FOREIGN KEY (country_id) REFERENCES dim_country(country_id),
--  FOREIGN KEY (skill_id) REFERENCES dim_skill(skill_id),
--  INDEX idx_skill_year(year)
-- );

-- select * from dim_country;
-- select * from dim_industry;
-- select * from dim_occupation;
-- select * from dim_skill;
-- select * from bridge_occupation_skill;
-- select * from fact_job_outlook;
-- select * from fact_skill_demand;

# total number of occupations
-- create view totaloccupation as
-- select count(*) as total_occupation from dim_occupation;
-- select * from totaloccupation;

# total number of industries;
-- create view totalindustry as 
-- select count(*) as total_industries from dim_industry;

-- select * from totalindustry;

# avg ai exposure
-- create view vw_avg_ai_exposure as
-- select round(avg(ai_exposure_pct),2) as avg_ai_exposure from fact_job_outlook;
-- select * from vw_avg_ai_exposure;

# avg automation risk
-- create view vw_automation_risk as
-- select round(avg(automation_risk_pct),2) as avg_automation_risk from fact_job_outlook;
-- select * from vw_automation_risk;

# avg augmentation potential
-- create view vw_augmentation_potential as
-- select round(avg(augmentation_potential_pct),2) as avg_augmentation from fact_job_outlook;
-- select * from vw_augmentation_potential;

## job replacement analysis
# jobs with high automation risk
-- create view vw_high_risk_jobs as
-- select count(distinct occupation_id) as high_risk_jobs from fact_job_outlook where automation_risk_pct >=70;
-- select * from vw_high_risk_jobs;

# jobs with low automation risk
-- create view vw_low_risk_jobs as
-- select count(distinct occupation_id) as low_risk_jobs from fact_job_outlook where automation_risk_pct < 30;
-- select * from vw_low_risk_jobs;

# ai augmented jobs
-- create view vw_ai_augmented_jobs as
-- select count(distinct occupation_id) as ai_augmented_jobs
-- from fact_job_outlook where augmentation_potential_pct >= 70;
-- select * from vw_ai_augmented_jobs;



## industry analysis

# avg ai automation risk by industry

-- SHOW CREATE VIEW industry_ai_automation_risk;
-- CREATE OR REPLACE VIEW industry_ai_automation_risk AS
-- SELECT i.industry_id,i.industry_name,
--     ROUND(AVG(f.automation_risk_pct), 2) AS Average_Automation_Risk
-- FROM fact_job_outlook f
-- JOIN dim_occupation o ON f.occupation_id = o.occupation_id
-- JOIN dim_industry i ON o.industry_id = i.industry_id
-- GROUP BY i.industry_id,i.industry_name;

-- SELECT * FROM industry_ai_automation_risk ORDER BY Average_Automation_Risk DESC;

# avg ai augmentation by industry
-- create view industry_ai_augmentation as
-- select i.industry_name,round(avg(f.augmentation_potential_pct),2) as avg_augmentation
-- from fact_job_outlook f join dim_occupation o on f.occupation_id=o.occupation_id
-- join dim_industry i on o.industry_id=i.industry_id
-- group by i.industry_name order by avg_augmentation desc;
-- select * from industry_ai_augmentation;

# total employement by industry
-- create view total_employment_by_industry as
-- select	i.industry_name,round(sum(f.employment_thousands),2) as total_employment_thousands
-- from fact_job_outlook f join dim_occupation o on f.occupation_id=o.occupation_id
-- join dim_industry i on o.industry_id=i.industry_id
-- where f.year = 2035 group by i.industry_name order by total_employment_thousands desc;
-- select * from total_employment_by_industry;

# total annual job openings by industry
-- create view annual_job_openings as
-- select i.industry_name,round(sum(f.annual_job_openings_thousands),2) as total_job_openings
-- from fact_job_outlook f join dim_occupation o on f.occupation_id =o.occupation_id 
-- join dim_industry i on o.industry_id=i.industry_id
-- where f.year = 2035 group by i.industry_name order by total_job_openings desc;
-- select * from annual_job_openings;

# top 10 occupations with highest replacement risk 2035

-- CREATE OR REPLACE VIEW top10_high_replacement_risk_occupations AS
-- SELECT
--     o.occupation_id,
--     o.occupation_title,
--     ROUND(AVG(f.automation_risk_pct), 2)
--         AS automation_risk
-- FROM fact_job_outlook f
-- JOIN dim_occupation o ON f.occupation_id = o.occupation_id
-- WHERE f.year = 2035 GROUP BY o.occupation_id, o.occupation_title ORDER BY automation_risk DESC LIMIT 10;
-- select * from top10_high_replacement_risk_occupations

#top 10 occupations with highest ai augmentation potential 2035
-- create view top10_high_augmentation_potential as
-- select o.occupation_title,round(avg(f.augmentation_potential_pct),2) as augmentation_potential
-- from fact_job_outlook f join dim_occupation o on f.occupation_id=o.occupation_id
-- where f.year = 2035 
-- group by o.occupation_id,o.occupation_title order by augmentation_potential desc limit 10;
-- select	* from top10_high_augmentation_potential;

# employment by occupation and year

-- CREATE OR REPLACE VIEW employment_by_occupation_and_year AS
-- SELECT o.occupation_id,o.occupation_title,f.year,ROUND(SUM(f.employment_thousands), 2) AS total_employment
-- FROM fact_job_outlook f JOIN dim_occupation o ON f.occupation_id = o.occupation_id
-- GROUP BY o.occupation_id,o.occupation_title,f.year
-- order by o.occupation_title,f.year;
-- select * from employment_by_occupation_and_year;

# employment trend
-- CREATE OR REPLACE VIEW employment_trend AS
-- SELECT year,ROUND(SUM(employment_thousands), 2) AS total_employment_thousands
-- FROM fact_job_outlook GROUP BY year;
-- select * from employment_trend;

# salary trend
-- create or replace view salary_trend as 
-- select year,round(avg(avg_annual_salary_usd_ppp),2) as avg_salary_usd_ppp
-- select *from fact_job_outlook group by year;

# ai adoption by country
-- create or replace view ai_adoption_by_country as
-- select c.country_id,c.country_name,round(avg(f.ai_adoption_pct),2) as average_ai_adoption_pct
-- from fact_job_outlook f join dim_country c on f.country_id=c.country_id
-- where f.year = 2035 group by c.country_id,c.country_name;
--  select * from ai_adoption_by_country;




# employment  growth by occupation
-- CREATE OR REPLACE VIEW employment_growth_by_occupation AS

-- SELECT
--     o.occupation_id,
--     o.occupation_title,
--     i.industry_name,

--     ROUND(
--         SUM(CASE WHEN f.year = 2025
--         THEN f.employment_thousands ELSE 0 END), 2
--     ) AS employment_2025,

--     ROUND(
--         SUM(CASE WHEN f.year = 2035
--         THEN f.employment_thousands ELSE 0 END), 2
--     ) AS employment_2035,

--     ROUND(
--         (
--             SUM(CASE WHEN f.year = 2035
--             THEN f.employment_thousands ELSE 0 END)
--             -
--             SUM(CASE WHEN f.year = 2025
--             THEN f.employment_thousands ELSE 0 END)
--         ) * 100.0
--         /
--         NULLIF(
--             SUM(CASE WHEN f.year = 2025
--             THEN f.employment_thousands ELSE 0 END), 0
--         ), 2
--     ) AS employment_growth_pct

-- FROM fact_job_outlook f

-- JOIN dim_occupation o
--     ON f.occupation_id = o.occupation_id

-- JOIN dim_industry i
--     ON o.industry_id = i.industry_id

-- WHERE f.year IN (2025, 2035)

-- GROUP BY
--     o.occupation_id,
--     o.occupation_title,
--     i.industry_name;
-- select * from employment_growth_by_occupation;

# top 10 future skills
-- create view top10_future_skills as
-- select s.skill_id,s.skill_name,s.skill_category,
-- round(avg(f.skill_demand_index),2) as avg_skill_demand
-- from fact_skill_demand f join dim_skill s on f.skill_id=s.skill_id
-- where f.year = 2035
-- group by s.skill_id,s.skill_name,s.skill_category
-- order by avg_skill_demand desc limit 10;
-- select * from top10_future_skills

# skill demand trend
-- create view skill_demand_trend as
-- select year,round(avg(skill_demand_index),2) as avg_skill_demand
-- from fact_skill_demand group by year;
-- select * from skill_demand_trend;

# skill demand by category
-- create view skill_demand_by_category as 
-- select s.skill_category,round(avg(f.skill_demand_index),2) as avg_skill_demand
-- from fact_skill_demand f 
-- join dim_skill s on f.skill_id=s.skill_id
-- where f.year=2035 group by s.skill_category;
-- select * from skill_demand_by_category; 


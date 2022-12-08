use car_data ;

---Query No.-1

select * from bmw;
select * from audi;
select * from hyndai;
select * from merc;
select * from cclass;
select * from models;
select * from transmission;
select * from fueltype;

---Query No.-2
---AUDI Table---
select * from audi
inner join models on audi.model_ID = models.model_ID

---Query No.-3
---AUDI Table---
select * from bmw
inner join models on bmw.model_ID = models.model_ID

---Query No.-4
---AUDI Table---
select * from bmw
inner join models on bmw.model_ID = models.model_ID

---Query No.-5
---AUDI Table---
select * from hyndai
inner join models on hyndai.model_ID = models.model_ID

---Query No.-6
---AUDI Table---
select * from merc
inner join models on merc.model_ID = models.model_ID

---Query No.-7
---AUDI Table---
select * from cclass
inner join models on cclass.model_ID = models.model_ID

--Query No.-8
---Adding BrandId---
ALTER TABLE audi
ADD Brand_ID int NOT NULL
DEFAULT 1
WITH VALUES;

--Query No.-9
ALTER TABLE bmw
ADD Brand_ID int NOT NULL
DEFAULT 2
WITH VALUES;

--Query No.-10
ALTER TABLE cclass
ADD Brand_ID int NOT NULL
DEFAULT 3
WITH VALUES;

--Query No.-11
ALTER TABLE hyndai
ADD Brand_ID int NOT NULL
DEFAULT 4
WITH VALUES;

--Query No.-12
ALTER TABLE merc
ADD Brand_ID int NOT NULL
DEFAULT 5
WITH VALUES;

--Query No.-13
ALTER TABLE cclass
ADD tax int NULL;

--Query No.-14
ALTER TABLE cclass
ADD mgp float NULL;


--Query No.-15
---Creating a View---
create view all_brands_information as
(select 'Audi' as brand_name, * from audi
union
select 'BMW' as brand_name, * from bmw
union
select 'CClass' as brand_name, * from cclass
union
select 'Hyundai'as brand_name, * from hyndai
union
select 'Mercedes'as brand_name, * from merc)

select * from all_brands_information;
select * from transmission;
select * from fueltype;
select distinct year from all_brands_information;
--Query No.-16
--- Create an analysis to find the income class of UK citizens based on the price of Cars(You can use per-capita income in the UK from internet sources)
select case when price <= 10000 then 'LIG'

when price > 10000 and price <=20000 then 'MIG'
when price > 20000 and price <=30000 then 'HIG'
when price > 30000 then 'Rich'
end income_group, count(*) as Total_Count

from all_brands_information
group by case when price <= 10000 then 'LIG'

when price > 10000 and price <=20000 then 'MIG'
when price > 20000 and price <=30000 then 'HIG'
when price > 30000 then 'Rich'
end

--Query No.-16
/*2. Categorize the cars on the basis of their price(Create as many buckets as you want as per your understanding of data) and analyze the:
    */

select case when price <= 10000 then 'Mini Compact'
			when price > 10000 and price <=20000 then 'Sub Compact'
			when price > 20000 and price <=30000 then 'Compact'
			when price > 30000 then 'Luxary'
		end Type_of_Car, count(*) as Total_Count
from all_brands_information
group by case when price <= 10000 then 'Mini Compact'
			when price > 10000 and price <=20000 then 'Sub Compact'
			when price > 20000 and price <=30000 then 'Compact'
			when price > 30000 then 'Luxary'
		end


--1.  price changes across the years and identifies the categories which have seen a significant jump in their price
select*,CAR_PRICE-LAG(CAR_PRICE)OVER(partition by brand_name ORDER BY CAR_PRICE)AS CHANGE_PRICE FROM
(select sum(price) as car_price,year,brand_name from(
SELECT *FROM all_brands_information)c group by brand_name ,year)g order by CHANGE_PRICE desc;

								--or
with temp_t1 as
(
select sum(price) as car_price,year,brand_name from(
SELECT *FROM all_brands_information)c group by brand_name ,year
)
select*,CAR_PRICE-LAG(CAR_PRICE)OVER(partition by brand_name ORDER BY CAR_PRICE)AS CHANGE_PRICE FROM
temp_t1 order by CHANGE_PRICE desc;

--b.   changes in the number of cars sold across the years and identify the categories which have seen a significant jump in their sales
with temp as
(
select year,brand_name,count(*) as Counts from all_brands_information
group by brand_name,year 
)
select*,counts-LAG(counts)OVER(partition by brand_name ORDER BY counts)AS count_of_cars_change
from temp
order by count_of_cars_change desc;

/*Using the above-identified categories for both points (a) & (b), do a root cause analysis to identify the probable reason for their increase.
For, e.g., Its fuel efficiency as compared to other types of cars could be a reason.*/
--3 Find relationship between fuel efficiency & price of car/sales of car/fuel type/, etc .

select fueltype,Round(avg(mpg),0) as avg_mpg ,avg(price) as avg_price from all_brands_information
left join fueltype on all_brands_information.fuel_ID=fueltype.fuel_ID
group by fueltype
;
select * from all_brands_information;
---efficiency Vs transmission
select transmission,Round(avg(mpg) ,0)as Avg_mpg from all_brands_information
left join transmission on all_brands_information.transmission_ID=transmission.ID
group by transmission
select * from all_brands_information;


----efficiency vs engine size
select distinct Round(engineSize,2) as engineSize,Round(avg(mpg) ,0)as Avg_mpg from all_brands_information 
group by  Round(engineSize,2)
order by 1;

/*4 .Rank across all the models based on their total sales, average price, average mileage, average engine size, etc.*/
---Total sales
select dense_rank() over (order by count(*) desc) as Rank_Sales,a.brand_name,b.model_name, 
avg(price) as Avg_Price,avg(mileage) as Avg_Mileage,avg(engineSize) as Avg_engineSize
from
(select * from all_brands_information) as a
left join models as b on a.model_ID=b.model_ID
group by brand_name,model_name;

----Avg Price
select dense_rank() over (order by avg(price)  desc) as Rank_Price,a.brand_name,b.model_name, 
avg(price) as Avg_Price,avg(mileage) as Avg_Mileage,avg(engineSize) as Avg_engineSize
from
(select * from all_brands_information) as a
left join models as b on a.model_ID=b.model_ID
group by brand_name,model_name;

---Avg mileage
select dense_rank() over (order by avg(mileage)  desc) as Rank_Mileage,a.brand_name,b.model_name, 
avg(price) as Avg_Price,avg(mileage) as Avg_Mileage,avg(engineSize) as Avg_engineSize
from
(select * from all_brands_information) as a
left join models as b on a.model_ID=b.model_ID
group by brand_name,model_name
;
---Avg engine size
select dense_rank() over (order by avg(engineSize)  desc) as Rank_EngineSize,a.brand_name,b.model_name, 
avg(price) as Avg_Price,avg(mileage) as Avg_Mileage,avg(engineSize) as Avg_engineSize
from
(select * from all_brands_information) as a
left join models as b on a.model_ID=b.model_ID
group by brand_name,model_name;

----now filter the top 5 basis their sales.
select top 5 dense_rank() over (order by count(*) desc) as Rank_Sales,a.brand_name,b.model_name, 
avg(price) as Avg_Price,avg(mileage) as Avg_Mileage,avg(engineSize) as Avg_engineSize
from
(select * from all_brands_information) as a
left join models as b on a.model_ID=b.model_ID
group by brand_name,model_name;












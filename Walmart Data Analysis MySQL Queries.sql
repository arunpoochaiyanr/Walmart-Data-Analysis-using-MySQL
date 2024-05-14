create database if not exists walmart_data;

use walmart_data;
select * from walmart;

select count(*) `Total Count` from walmart;
-- Inference --> there are a total of 1000 entries

-- 1.Generic Question
-- 1.a)	How many unique cities does the data have?
select count(distinct(city)) CityCount from walmart;
-- Inference --> these 1000 entries are from the 3 different cities or
			 --  there are 3 unique cities present in the data

-- 1.b)	In which city, each branch is located?
select distinct(branch),city
from walmart
order by branch,city;
-- Inference --> The branch A is in Yangon, branch B is in Mandalay and C is in Naypyitaw

-- 2.Product
-- 2.a)	How many unique product lines does the data have?
select count(distinct(`product line`)) UniqueProductLine
from walmart;
-- Inference --> the data has 6 unique productlines

-- 2.b)	What is the most common payment method?
select max(payment) ` Most Common Payment`
from walmart;
-- Inference --> the most common payment method is Ewallet

-- 2.c)	What is the most selling product line?
select max(`product line`) `Most Selling ProductLine`
from walmart;
-- Inference --> the most seeling product line is Sports and Travel

-- 2.d)	What is the total revenue by month?
select monthname(date) Month_Name,round(sum(total),2) total_revenue
from walmart
group by  month_name 
order by total_revenue desc;
-- Inference --> January - 116291.87, Febraury - 109455.51 and March - 97219.37


-- 2.e)	Which month had the largest COGS?
select monthname(date) month_name,round(sum(cogs),2) max_cogs
from walmart
group by month_name
order by max_cogs desc limit 1;
-- Inference --> January ahs the highest cogs i.e., 110754.16

-- 2.f)	What product line had the largest revenue?
select `product line`, round(sum(total),2) total_revenue
from walmart
group by `product line`
order by total_revenue desc limit 1;
-- Inference --> Food and Beverages has made the largest revenue - 56144.84

-- 2.g)	What is the city and branch with the largest revenue?
select city,branch,round(sum(total),2) total_revenue
from walmart
group by city,branch
order by total_revenue desc limit 1;
-- Inference --> the branch C at naypyitaw has made more revenue (1110568.71) than the others

-- 2.h)	What product line had the largest VAT?
select `product line`, round(avg(`tax 5%`),2) AvgTax
from walmart
group by `product line`
order by AvgTax desc limit 1;
-- Inference --> Home and lifestyle has the highest tax of all other product line with 16.03

-- 2.i)Fetch each product line and add a column to those product line showing "Good","Bad".
-- Good if its greater than average sales and find the invoice ID which are "Good"
-- the first query is done to find out the average number of products from each productline.
select `product line`,avg(quantity)
from walmart
group by `product line`;

select `invoice id`,`product line`, quantity,
case
	when quantity>=6 then "Good"
    when quantity <6 then "Bad"
end SalesQuality
from walmart;

-- to retreive the SalesQuality Column containing only Good
with CTE as
(
select `invoice id`,`product line`, quantity,
case
	when quantity>=6 then "Good"
    when quantity <6 then "Bad"
end SalesQuality
from walmart
)
select `invoice id`,`product line`
from CTE
where SalesQuality = "Good";

-- 2.j)The average number of products sold at which branch 
-- is higher than that of the total average number of products sold
select branch,round(avg(quantity),2) AvgSales
from walmart
group by branch
having AvgSales > (select round(avg(quantity),2) TotalAvgSales
				  from walmart);
-- Inference --> The average sale at Branch C is more 
--               than that of the total average sales done by all three combined
                  
-- 2.k)What is the most common product line by gender?
select `product line`,gender ,count(gender) as total_count
from walmart
group by `product line`,gender
order by total_count desc,gender asc;

-- 2.l)	What is the average rating of each product line?
select `product line`,round(avg(rating),2) AvgRating
from walmart
group by `product line`
order by AvgRating desc;
-- Inference --> AvgRating for each product line has been calculated and 
-- 				the food and beverages ahs the highest average rating

-- 2.m)	Calculate the total sales (total) for each product line (product_line).
select `product line`,round(sum(total),2) TotalSales
from walmart
group by `product line`
order by TotalSales desc;
-- Inference --> The total sales for each product line is calculated and shown below
-- 				 and the food and beverages ahs the highes total sales

-- 3. Branch Performance Analysis:
-- 3. a) Find the total sales (total) for each branch.
select branch, round(sum(total),2) TotalSales
from walmart
group by branch
order by TotalSales desc;
-- Inference --> TotalSales for each branch is listed below 
--   			 and branch c has made the highest sales of 110568.71

-- 3. b) Calculate the average rating (rating) for each branch.
select branch, round(avg(rating),2) AvgRating
from walmart
group by branch
order by AvgRating desc;
-- Inference --> Branch C and A has received best AvgRating with notable difference

-- 4. Customer Segmentation:
-- 4.a)	Identify the number of customers (invoice_id) in each city (city).
select city,count(`invoice id`) NoOfCustomers
from walmart
group by city;
-- Inference --> the customers visits to each city is evenly distributed

-- 4.b)	Determine the total sales (total) for each customer type (customer_type).
select `customer type`,round(sum(total),2) TotalSales
from walmart
group by `customer type`;
-- Inference --> the customer type "Member" have made contributed more to Sales/purchase

-- 4.c)	How many unique customer types does the data have?
select `customer type`,count(`customer type`) TotalCount
from walmart
group by `customer type`;
-- Inference --> there are two types of customer types "Member" and "Normal"
--               and there is not any notable difference between the customer type

-- 4.d)	How many unique payment methods does the data have?
select payment, count(payment) TotalCount
from walmart
group by payment;
-- Inference --> There are 3 types of payment mode and the data distribution is even

-- 4.e)	Which customer type buys the most(by quantity)?
select *,
dense_rank() over(order by TotalQuantity desc) rn
from ( select `customer type`, sum(quantity) TotalQuantity
from walmart
group by `customer type`
) temp;
-- Inference--> the "Member" customer type has bought 60 more items than the "Normal" customer

-- 4.f)	What is the gender of most of the customers?
select gender,count(gender) TotalCOunt
from walmart
group by gender;
-- Inference --> there distribution of gender is even/ there is not any notable difference

-- 4.g)	What is the gender distribution per branch?
select branch,gender,count(gender) GenderCount
from walmart
group by branch,gender
order by branch,GenderCount desc;

-- 4.h)	Which time of the day do customers give most ratings?
alter table walmart add column part_of_day varchar(20);

set sql_safe_updates = 0;

update walmart
set part_of_day = case 
					when time between "00:00:00" and "11:59:59" then "Morning"
                    when time between "12:00:00" and "15:59:59" then "Afternoon"
                    else "Evening"
				   end;                   
select * from walmart;

select part_of_day, round(avg(rating),2) AvgRating
from walmart
group by part_of_day;
-- Inference --> whatever be the part of the day, the rating given by customers are even

-- 4.i)	Which time of the day do customers give most ratings per branch?
select branch,part_of_day,round(avg(rating),2) AvgRating
from walmart
group by branch,part_of_day
order by AvgRating desc;

-- 4.j)	Which day for the week has the best avg ratings?
select dayname(date) 
from walmart;

alter table walmart add column dayname varchar(10);

update walmart
set `dayname` = dayname(date);
select * from walmart;

select dayname,round(avg(rating),2) AvgRating
from walmart
group by dayname
order by AvgRating desc;
-- Inference-->Monday has the best average rating with 7.15 "may be first day of the week"
--             Wednesday has least average rating with 6.81 "may be mid part of week/office tension"

-- 4.k)	Which day of the week has the best average ratings per branch?
select branch,dayname,round(avg(rating),2) AvgRating
from walmart
group by branch,dayname
order by AvgRating desc;
-- Inference --> it is clear that monday,friday and saturday ahs the best average ratings

-- 5.	Sales Trends:
-- 5.a)	Determine the total sales (total) for each year.
select year(date)Year,round(sum(total),2) TotalSales
from walmart
group by Year;
-- Inference --> the data has only 2019 year and the total sales is 322966.75

-- 5.b)	Find the month with the highest total sales (total) across all years.
select monthname(date) Month,round(sum(total),2) TotalSales
from walmart
group by Month
order by TotalSales desc;
-- Inference --> The january month has the highest sales with 116291.87

-- 5.c)	Number of sales made in each time of the day per weekday
with cte as 
(
select month(date) Month,weekday(date) weekday,hour(time) hour,count(`invoice ID`) TotalCount
from walmart
group by Month, weekday, hour
order by month asc
)
select case 
			when month = 1 then "January"
            when month = 2 then "February"
            when month = 3 then "March"
            end MonthName, weekday,hour, totalcount 
from cte;

-- 5.d)	Which of the customer types brings the most revenue?
select `customer type`,round(sum(total),2) TotalRevenue
from walmart
group by `customer type`
order by TotalRevenue desc;
-- Inference --> The customer type "Member" contributes more to the revenue

-- 6.	Payment Method Analysis:
-- 6.a)	Calculate the average payment amount (payment_method) 
--      for each payment method (payment_method).
select payment,round(avg(total),2) AvgAmountSpent
from walmart
group by payment
order by AvgAmountSpent desc;
-- Inference --> the average amount spent by 3 modes of payments are between 310 to 330

-- 6.b)	Identify the most common payment method (payment_method) used by customers.
select payment,count(payment) TotalCount
from walmart
group by payment
order by TotalCount desc;
-- Inference --> the most commo method of payments is Ewallet

-- 7.	Time Analysis:
-- 7.a)	Analyze the total sales (total) made during each hour of the day (time).
select hour(time) Hour,round(sum(total),2) TotalSales
from walmart
group by Hour
order by hour asc;
-- Inference --> the 10 am hour has made more revenue with 31421.48

-- 7.b)	Determine the day of the week with the highest average sales (total).
select dayname,round(sum(total),2) TotalSales,round(avg(total),2) AvgSales
from walmart
group by dayname
order by AvgSales desc;
-- Inference --> the day "Saturday" has made a totalsales of 56120.81 and average sales of 342.2


-- 8.	Customer Satisfaction Analysis:
-- 8.a)	Find the average rating (rating) for each gender (gender).
select gender,round(avg(rating),2) AvgRating
from walmart
group by gender
order by AvgRating desc;
-- Inference --> there is no any notable difference in rating given by the people

-- 8.b)	Determine the gender (gender) with the highest average rating (rating).
with cte as
(
select gender,rating,
dense_rank() over(order by rating desc) rnk
from walmart
)
select gender,rating
from cte
where rnk = 1;
-- Inference --> Out of five people who gave 10 ratings, 4 were females

-- 9.	Quantity Analysis:
-- 9.a)	Calculate the total quantity (quantity) sold 
--      for each product line (product_line).
select `product line`,sum(quantity) TotalCount 
from walmart
group by `product line`
order by TotalCount desc;
-- Inference --> Electronic accessories has sold more quantities i.e., 971 quantites

-- 10.	VAT Analysis:
-- 10.a)Calculate the total VAT (VAT) collected for each city (city).
select city, round(sum(`tax 5%`),2) VAT
from walmart
group by city 
order by VAT desc;
-- Inference --> the city Naypyitaw has made more VAT i.e., 5265.18

-- 10.b)Determine the city (city) with the highest total VAT collected.
select `invoice id`,city,`tax 5%` VAT
from walmart
order by VAT desc limit 1;
-- Inference --> the city Naypyitaw has made highest VAT with 49.65 & invoice id - 860-79-0874

-- 10.c)Which customer type pays the most in VAT?
select `customer type`,round(sum(`tax 5%`),2) VAT
from walmart
group by `customer type`
order by VAT desc limit 1;
-- Inference --> The "Member" Customer type contributes more to the VAT

-- Walmart Data Analysis - Arun Poochaiayan R

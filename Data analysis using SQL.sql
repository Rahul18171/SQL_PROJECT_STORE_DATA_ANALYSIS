create table if not exists store(
        Row_ID SERIAL,
	    Order_ID  CHAR(25),
	    Order_Date Date,
        Ship_Date Date,
        Ship_Mode VARCHAR(50),
        Customer_ID CHAR(25),
        Customer_Name VARCHAR(75),
        Segment VARCHAR(25),
        Country VARCHAR(50),
        City VARCHAR(50),
        States VARCHAR(50),
        Postal_Code INT,
        Region VARCHAR(12),
	    Product_ID VARCHAR(75),
        Category VARCHAR(25),
        Sub_Category VARCHAR(25),
        Product_Name VARCHAR(255),
        Sales FLOAT,
        Quantity INT,
        Discount FLOAT,
        Profit FLOAT,
        Discount_Amount FLOAT,
        Years INT,
        Customer_Duration VARCHAR(50),
        Returned_Items VARCHAR(50),
        Return_Reason VARCHAR(255)
)
 
 select * from store
 
 --database size--
 select pg_size_pretty(pg_database_size('Data analysis'))
 
-- table size --
select pg_size_pretty(pg_table_size('store'))

--row count of data--
select count(*) AS row_count
from store

/* columns count data*/
select count(*) as column_count
from information_schema.columns
where table_name= 'store'


select *
from information_schema.tables
where table_name = 'store';

/* check dataset information */
select *
from information_schema.columns
where table_name = 'store'

/* get column name of data */
select column_name
from information_schema.columns
where table_name = 'store'

/* get column name with datatype of data */
select column_name,data_type
from information_schema.columns
where table_name = 'store'

/* checking null values of data */
/* using nested(subquery) query */
select * from store
where(select column_name
from information_schema.columns
where table_name = 'store') = NULL

/* droping unnecessary column like raw id */
ALTER TABLE "store" DROP COLUMN "row_id"
select * from store limit 10

/* check the count of united states */
select count(*) AS US_count
from store
where country = 'United States'

/* product level analysis */
/* what are the unique categories? **/
select distinct(category) from store

/* what is the number of product in each category? */
select category, count(*) as NO_of_Product
from store
group by category
order by count(*) desc

/* find the number of subcategories products that are divided? */
select count(distinct(sub_category)) as No_of_category
from store

select category, count(distinct(sub_category)) as No_of_category
from store
group by category
order by count(*)desc

/* find the number of products in each subcategory */
select sub_category, count(*) as  no_of_product
from store
group  by sub_category
order by count(*) desc

/* find the number of unique  product name */
select count(distinct(product_name)) as  unique_product_name
from store

/* which are the top 10 products thats are ordered frequently? */
select product_name, count(*) as No_of_product
from store
group by product_name
order by count(*) desc
limit 10

/* Calculate the cost for each Order_ID wuth respective product name. */
select order_id,product_name, round(cast((sales-profit)as numeric),2) as cost
from store

/* Calculate % profit for each Order_ID wuth respective product name. */
select order_id,product_name, round(cast((profit/((sales-profit))*100)AS numeric), 2) as percentage_profit
from store

/* Calaculate the overall profit of the store */
select round(cast(((sum(profit)/((sum(sales)-sum(profit))))*100)as numeric),2) as percentage_profit
from store

/* calculate percentage profit and group by them with product name and order id */
select order_id,product_name, ((profit/((sales-profit))*100))as percentage_profit
from store
group by order_id,product_name,percentage_profit						   

/* where can we trim losses? 
  In which products?
  we can do this by calculating the average sales and profit, and comparing the values to that average.
 If the sales or profits below average, then they are not best sellers and can be analyzed
  deeper to see if its worth selling them anymore.*/

select round(cast(AVG(sales)as numeric),2) as avg_sales
from store
-- the average sales on any given product is 229.8, so approx 230

select round(cast(AVG(profit)as numeric),2) as avg_profit
from store
-- the average profit on any given product is 28.65, so approx 29

-- Average sales per sub-cat --
select round(cast(AVG(sales)as numeric),2)as avg_sales, Sub_category
from store
group by Sub_category
order by avg_sales asc
limit 9
--the sales of these sub_category products are below the average sales.

-- Average profit per sub-cat --
select round(cast(AVG(profit)as numeric),2)as avg_profit, Sub_category
from store
group by Sub_category
order by avg_profit asc
limit 11
--the profit of these sub_category products are below the average profits.

/* CUSTOMER LEVEL ANALYSIS */ 
/* What is the number of unique customer IDs? */
select count(distinct(customer_id)) as no_of_unique_cust_id
from store

/* find those customers who registered during 2014-2016. */
select distinct(customer_name), customer_id,order_id,city,postal_code
from store
where customer_id  is not null

/* calculate total frequency of each order id by each customer name in descending order. */
select order_id, customer_name, count(order_id)as total_order_id
from store
group by order_id,customer_name
order by total_order_id desc

/* calculate the cost of each customer name */
select customer_id,order_id,customer_name,city,quantity,sales,(sales-profit) as costs,profit
from store
group by customer_name,order_id,customer_id,city,quantity,costs,sales,profit

/* Display the no of customers in each region in descending order. */
select region, count(*) as no_of_customers
from store
group by region
order by no_of_customers desc

/* find the top 10 customers who ordered frequently? */
select customer_name, count(*) as no_of_order
from store
group by customer_name
order by count(*) desc
limit 10

/* Display the records for customers who live in state california and have postal code 90032. */
select* from store
where States='California' and Postal_code='90032'

/* find the top 20 customer who benefitted the store */\
select customer_name,profit,city,states
from store
group by customer_name,profit,city,states
order by profit desc
limit 20

-- which states is the superstore most successful in? Least?
-- Top 10 results
select round(cast(Sum(sales)as numeric),2) as states_sales, states
from store
group by states
order by states_sales desc
offset 1 rows fetch next 10 rows only       /* offset is like limit fun */ 

/* ORDER LEVEL ANALYSIS */
/* number of unique orders */
select count(distinct(order_id)) as no_of_unique_order
from store

/* find sum total sales of superstore */ 
select round(cast(sum(sales)as numeric),2) as total_sales
from store

/* Calculate the time taken for an order to ship and converting the no. of days int format. */
select order_id,customer_id,customer_name,city,states,(ship_date-order_date)as delivery_duration
from store
order by delivery_duration desc
limit 20

/* Extract the year for respective order ID and customer ID with quantity. */
select order_id,customer_id,quantity, EXTRACT(YEAR from order_date) 
from store
group by order_id,customer_id,quantity, EXTRACT(YEAR from order_date)
order by quantity desc

/* what is the sales impact? */
SELECT EXTRACT(YEAR from order_date)as date_part,sales, round(cast(((profit/((sales-profit))*100))as numeric),2) as profit_percentage
from store
group by date_part,sales,profit_percentage
order by profit_percentage desc
limit 20

--Breakdown Top vs Worst sellers 
-- Find the top 10 Categories(with the addition of best sub_category within the category)
Select category,sub_category, round(cast(sum(sales)as numeric),2) as prod_sales
from store
group by category,sub_category
order by prod_sales desc

-- Find top 10 sub_categories
Select sub_category, round(cast(sum(sales)as numeric),2)as prod_sales
from store
group by sub_category
order by prod_sales desc
offset 1 rows fetch next 10 rows only       /* offset is like limit fun bt its not show first one */ 

--Find worst 10 categories;
Select category,sub_category, round(cast(sum(sales)as numeric),2)as prod_sales
from store
group by category, sub_category
order by prod_sales;
offset 1 rows fetch next 10 rows only       /* offset is like limit fun bt its not show first one */ 

--Find worst 10 sub_categories;
Select sub_category, round(cast(sum(sales)as numeric),2)as prod_sales
from store
group by sub_category
order by prod_sales
offset 1 rows fetch next 10 rows only       /* offset is like limit fun bt its not show first one */ 

/* Show the basic order information. */
select count(order_id) as Purchases,
round(cast(sum(sales)as numeric),2)as Total_sales,
round(cast(sum((profit/((sales-profit))*100))/count(*)as numeric),2) as profit_percentage,
min(order_date) as first_purchase_date,
max(order_date) as latest_purchase_date,
count(distinct(product_name)) as product_purchased,
count(distinct(city)) as Location_count
from store

/* RETURN LEVEL ANALYSIS */
/* Find the number of returned orders */
select returned_items, count(returned_items) as returned_items_count
from store
group by returned_items
having returned_items='Returned'

/* Find top 10 returned categories */
select returned_items, count(returned_items) as no_of_returned, category,sub_category
from store
group by returned_items,category,sub_category
having returned_items='Returned'
order by count(returned_items) desc
limit 10

/* Find top 10 returned sub_categories */
select returned_items, count(returned_items),sub_category
from store
group by returned_items,sub_category
having returned_items='Returned'
order by count(returned_items) desc
limit 10

/* Find top 10 customers returned frequently */
select returned_items, count(returned_items) as returned_items_count,customer_name,customer_id,customer_duration,states,city
from store
group by returned_items,customer_name,customer_id,customer_duration,states,city
having returned_items='Returned'
order by count(returned_items) desc
limit 10

/* Find top 20 cities and states having higher return. */
select returned_items, count(returned_items) as returned_items_count,states,city
from store
group by returned_items,states,city
having returned_items='Returned'
order by count(returned_items) desc
limit 20

/* check whether new customers are returning higher or not. */
select returned_items, count(returned_items) as returned_items_count,customer_duration
from store
group by returned_items,customer_duration
having returned_items='Returned'
order by count(returned_items) desc
limit  10

/* Find top reason for returning */
select returned_items, count(returned_items) as returned_items_count,return_reason
from store
group by returned_items,return_reason
having returned_items='Returned'
order by count(returned_items) desc

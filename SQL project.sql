#Skim each table 
select * from customers;
select * from payments;
select * from orderdetails;
select * from orders;
select * from products;
select * from productlines;
select * from orders where status = 'shipped' and shippedDate > requiredDate;

#use table "orders" and "orderdetails" to check the total sales and renvenue by month:
#use the orderdate column to create the month column
#sales=quantityordered
#renvenue=quantityordered*price 
#make sure the order is shipped, otherwise we can not assume the sales actually has happened
select substring(orderDate,1,7) as order_month, sum(quantityOrdered) as sales, sum(quantityOrdered*priceEach) as renvenue
from orders left join orderdetails on orders.orderNumber = orderdetails.orderNumber 
where orders.status = 'shipped' group by order_month;

#create a report showing total sales, renvenue, profit by each product under each month:
#profit = quantityOrdered*priceEach - quantityOrdered*buyPrice 
#also, only count the shipped orders 
select substring(orderDate,1,7) as order_month, p.productName, sum(quantityOrdered) as sales, sum(quantityOrdered*priceEach)
as renvenue, sum(quantityOrdered*priceEach - quantityOrdered*buyPrice) as profit from orders as o left join 
orderdetails as od on o.orderNumber = od.orderNumber left join products as p on od.productCode = p.productCode 
where o.status = 'shipped' group by 1,2;

#rank the products by average sales per month, from highest to lowest
 
create table new as select substring(orderDate,1,7) as order_month, p.productName, sum(quantityOrdered) as sales, sum(quantityOrdered*priceEach)
as renvenue, sum(quantityOrdered*priceEach - quantityOrdered*buyPrice) as profit from orders as o left join 
orderdetails as od on o.orderNumber = od.orderNumber left join products as p on od.productCode = p.productCode 
where o.status = 'shipped' group by 1,2;
select * from new;
select order_month, avg(sales) from new group by order_month order by avg(sales) desc;

select p.productName, od.productCode, substring(orderDate,1,7) as order_month, avg(sum(quantityOrdered)) as avg_sales from orders as o left 
join orderdetails as od on o.orderNumber = od.orderNumber left join products as p on o.productCode = 
p.productCode where o.status = 'shipped' group by 1,2,3 order by avg_sales desc;

# create a report showing total sales, renvenue, profit by each productline under each month, add the description for 
#the productline, and order by profit
create table report as select substring(orderDate,1,7) as order_month, pl.productline, pl.textDescription,
sum(quantityOrdered) as sales, sum(quantityOrdered*priceEach) as revenue, sum(quantityOrdered*priceEach -
quantityOrdered*buyPrice) as profit from orders as o left join orderdetails as od on o.orderNumber = od.orderNumber 
left join products as p on od.productCode = p.productCode left join productionlines as pl on p.productLine
= pl.productionLine where o.status = 'shipped' group by 1,2,3 order by profit desc;

#create a table showing all employeees under each office city:
#key columns in the table: cityname, employee number, name, title and how many people report to the employee
#also make sure if no one report to the employee, then the number should be 0, do not leave NULL value in the table hint:use UPDATE

drop table workforce;
select * from employees;
SELECT * from offices;
create table workforce as select base.*, reporto.num_of_reports from (select off.city, emp.employeenumber, emp.lastname, 
emp.firstname, emp.jobtitle from offices as off left join employees as emp on off.officecode = emp.officeCode) as base left 
join (select reportsto, count(*) as num_of_reports from employees where reportsto is not null group by 1) as reporto on 
base.employeenumber = reporto.reportsto;
update workforce set num_of_reports = 0 where num_of_reports = NULL;
select * from workforce;
select reportsto, count(*) as num_of_reports from employees group by 1;
create table work as select base.*, reporto.num_of_reports from (select off.city, employeenumber, emp.lastname, emp.firstname, emp.jobtitle
from offices as off left join employees as emp on off.officecode=emp.officecode) as base left join (select reportsto, count(reportsto) as 
num_of_reports from employees group by 1) as reporto on base.employeenumber =reporto.reportsto;

select * from work;

create database pizzaspot;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) );

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );

SELECT @@secure_file_priv;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv" into table order_details
fields terminated by ','
ignore 1 lines;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv" into table orders
fields terminated by ','
ignore 1 lines;





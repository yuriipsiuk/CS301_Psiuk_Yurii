create database practical_assignment_01;


create table customers(
	ID Int primary key,
	last_name varchar(50),
	first_name varchar(50),
	email varchar(100)
);
create table restaurants(
	name varchar(200),
	place_id int primary key,
	town varchar(100)
);
create table accounts(
	client_id int,
	account_id int primary key,
	balance int,
	foreign key (client_id) references customers(ID) 
);
create table transactions(
	ID int primary key,
	account_id int,
	amount int,
	transaction_data date,
	foreign key (account_id) references accounts(account_id)
);

create table orders_june26(
	order_id int primary key,
	phone varchar(32),
	order_type varchar(100),
	place_id int,
	foreign key (place_id) references restaurants(place_id),
	foreign key (order_id) references transactions(ID)
);
create table orders_may26(
	order_id int primary key,
	phone varchar(32),
	order_type varchar(100),
	place_id int,
	foreign key (place_id) references restaurants(place_id),
	foreign key (order_id) references transactions(ID)
);
/*
    отримуємо список клієнтів, відсортованих за спаданнях їх витрат у  ресторанах Сіетла
 */
with orders as (
	select * from  orders_may26 union all select * from orders_june26
)
select c."ID",c.last_name,c.first_name,sum(t.amount) as total_amount, count(distinct r.name) as distinct_restaurants,r.town
from customers c 
join accounts a on c."ID"=a.client_id
join transactions t on a.account_id=t.account_id
join orders o on t."ID"=o.order_id
join restaurants r on o.place_id=r.place_id
where town='Seattle'
group by c."ID",c.last_name,c.first_name,r.town
order by total_amount desc;

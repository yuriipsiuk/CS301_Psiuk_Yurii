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

insert into customers (ID,last_name,first_name,email) values 
(1,'John','Smith','johnsmith@r.com'),
(2,'Anton','Smith','johnsmith@r.com'),
(3,'John','Jones','johnsmith@r.com'),
(4,'Eva','Smith','johnsmith@r.com'),
(5,'Jo','Vans','johnsmith@r.com'),
(6,'Jime','Smooth','johnsmith@r.com');

insert into accounts (client_id,account_id,balance) values
(2,1,100),
(2,2,-100),
(5,3,1000),
(6,4,600),
(1,5,700),
(3,6,-10),
(1,7,0);
insert into transactions (ID,account_id,amount,transaction_data) values
(1,1,500,'2026-06-02'),
(2,2,600,'2026-06-03'),
(3,2,50,'2026-06-04'),
(4,3,70,'2026-06-05'),
(5,4,80,'2026-06-01'),
(6,5,50,'2026-06-02'),
(7,6,300,'2026-06-04'),
(8,7,20,'2026-06-07'),
(9,2,1000,'2026-06-07'),
(10,1,40,'2026-06-09'),
(11,3,50,'2026-05-01'),
(12,4,600,'2026-05-02'),
(13,3,700,'2026-05-09'),
(14,2,80,'2026-05-05'),
(15,7,90,'2026-05-04'),
(16,6,700,'2026-05-02'),
(17,5,800,'2026-05-07'),
(18,4,900,'2026-05-02'),
(19,3,600,'2026-05-05'),
(20,2,500,'2026-05-01');
insert into restaurants (name,place_id,town) values 
('House',1,'Kyiv'),
('Bar',2,'Kyiv'),
('Chinatown',3,'Kharkiv');
insert into orders_june26 (order_id, phone, order_type, place_id) values 
(1,'+380931111111', 'delivery', 1),
(2,'+380932222222', 'dine-in',  2),
(3,'+380932222222', 'takeaway', 1),
(4,'+380935555555', 'delivery', 3),
(5,'+380936666666', 'dine-in',  1),
(6,'+380931111111', 'takeaway', 2),
(7,'+380933333333', 'delivery', 2),
(8,'+380931111111', 'dine-in',  3),
(9,'+380932222222', 'delivery', 1),
(10,'+380932222222', 'takeaway', 2);

insert into orders_may26 (order_id, phone, order_type, place_id) values 
(11,'+380935555555', 'delivery', 3),
(12,'+380936666666', 'dine-in',  1),
(13,'+380935555555', 'takeaway', 2),
(14,'+380932222222', 'delivery', 1),
(15,'+380931111111', 'dine-in',  2),
(16,'+380933333333', 'takeaway', 3),
(17,'+380935555555', 'delivery', 1),
(18,'+380936666666', 'dine-in',  2),
(19,'+380935555555', 'takeaway', 3),
(20,'+380932222222', 'delivery', 1);

/*
    отримуємо список клієнтів, відсортованих за спаданнях їх витрат у київських ресторанах
 */
with orders as (
	select * from  orders_may26 union all select * from orders_june26
)
select c.ID,c.last_name,c.first_name,sum(t.amount) as total_amount, count(distinct r.name) as distinct_restaurants,r.town
from customers c 
join accounts a on c.ID=a.client_id
join transactions t on a.account_id=t.account_id
join orders o on t.ID=o.order_id
join restaurants r on o.place_id=r.place_id
where town='Kyiv'
group by c.ID,c.last_name,c.first_name,r.town
order by total_amount desc;

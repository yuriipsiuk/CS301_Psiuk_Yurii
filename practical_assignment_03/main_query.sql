create database practical_assignment_03;
create table customers (
    customer_id serial primary key,
    full_name varchar(100) not null,
    email varchar(100) unique not null,
    balance numeric(10,2) default 0
);

create table products (
    product_id serial primary key,
    product_name varchar(100) not null,
    price numeric(10,2) not null,
    stock_quantity int not null
);

create table orders (
    order_id serial primary key,
    customer_id int references customers(customer_id),
    order_date timestamp default current_timestamp,
    total_amount numeric(10,2) default 0
);

create table order_items (
    order_item_id serial primary key,
    order_id int references orders(order_id),
    product_id int references products(product_id),
    quantity int not null,
    price numeric(10,2) not null
);

create table order_log (
    log_id serial primary key,
    order_id int,
    customer_id int,
    action varchar(50),
    log_date timestamp default current_timestamp
);



 /*Task 1*/
create or replace function calculate_order_total(p_order_id int)
returns numeric(10,2)
as $$
	select coalesce(sum(quantity * price),0) from order_items where order_id=p_order_id;
$$ language sql;

/* Task 2*/
create or replace procedure create_order(p_customer_id int)
language plpgsql
as $$
begin
	if exists (select 23 from customers where customer_id=p_customer_id) then
		insert into orders(customer_id,order_date,total_amount)
		values(p_customer_id,current_timestamp,0);
	end if;
end;
$$;

/*Task 3*/
create or replace procedure add_product_to_order(p_order_id int, p_product_id int, p_quantity int) 
language plpgsql
as $$
begin
	if exists (select 23 from products where product_id=p_product_id and p_quantity>0 and stock_quantity>=p_quantity)
		and exists(select 23 from orders where order_id=p_order_id)
		then
		insert into order_items(order_id,product_id,quantity,price)
		values (p_order_id,p_product_id,p_quantity,(select price from products where product_id=p_product_id));
		update products set stock_quantity=stock_quantity-p_quantity where product_id=p_product_id;
	end if;
end;
$$;

/*Task 4*/
create or replace function normalizer()
returns trigger 
language plpgsql
as $$
begin
	update orders set total_amount=calculate_order_total(coalesce(new.order_id,old.order_id))
	where order_id=coalesce(new.order_id,old.order_id);
	return null;
end;
$$;

create trigger update_order_total 
after delete or insert or update on order_items
for each row
execute function normalizer();

/*Task 5*/
create or replace function add_log()
returns trigger
language plpgsql
as $$
begin
	insert into order_log(order_id,customer_id,action,log_date) 
	values(new.order_id,new.customer_id,'INSERT',current_timestamp);
	return null;
end;
$$;

create trigger logger
after insert on orders
for each row
execute function add_log();

/*Task 6*/
/*creating customers*/
insert into customers(full_name,email,balance) values('Anton Bychkov','abychkov@mail',2300);
/*creating products*/
insert into products (product_name,price,stock_quantity) values('Iron Spoon',5,23);
insert into products (product_name,price,stock_quantity) values('Iron Fox',5.2,233);
/*creating order by procedure*/
call create_order(1001);
/*adding products tp order*/
call add_product_to_order(1001,1001,7);
call add_product_to_order(1001,1002,9);
/*check automatic update*/
select * from orders where order_id=1001
/*check decrease in quantity*/
select * from products where product_id=1001 or product_id=1002
/*check looger*/
select * from order_log where order_id=1001





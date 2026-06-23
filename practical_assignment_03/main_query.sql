 /*Task 1*/
create or replace function calculate_order_total(p_order_id int)
returns int
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
create or replace function normalize ()
returns trigger 
language plpgsql
as $$
begin
	update orders set total_amount=calculate_order_total (coalesce (new.order_id,old.order_id))
	where order_id=coalesce (new.order_id,old.order_id);
	return null;
end;
$$;


create trigger update_order_total 
after delete or insert or update on order_items
for each row
execute function  normalize();


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

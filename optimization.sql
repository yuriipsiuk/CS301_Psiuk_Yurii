/*
  Задача - знайти серед продуктів найпопулярнішої категорії з id більшими ща 9930, замовлених в 2022 році,
  ті, які були достуавлені активним клієнтам з хоча б 3 замовленнями.
 */
/*
  Неоптимізований запит
 */
explain analyze
select c.id,concat(c.name,' ',c.surname) as fullname,c.email,c.phone, c.address, c.status, o.order_id,o.order_date,o.product_id,p.product_name,p.product_category,p.description 
from opt_clients c
join opt_orders o on c.id=o.client_id 
join opt_products p on p.product_id=o.product_id
where c.status='active'
and p.product_id>9930
and o.order_id in (select order_id from opt_clients join opt_orders on opt_clients.id=opt_orders.client_id join opt_products on opt_products.product_id=opt_orders.product_id where extract(year from order_date)=2022) 
and c.id in (select opt_clients.id from opt_clients join opt_orders on opt_clients.id=opt_orders.client_id join opt_products on opt_products.product_id=opt_orders.product_id group by opt_clients.id having count(*)>3)
group by c.id,c.name,c.surname,c.email,c.phone, c.address, c.status, o.order_id,o.order_date,o.product_id,p.product_name,p.product_category,p.description 
having p.product_category in (select product_category from opt_products group by product_category order by count(*) desc limit 1)
order by concat(c.name,' ',c.surname)
limit 1000
/*
  Індекси для оптимізації
 */
create index DateIndex on opt_orders(order_date);
create index StatusIndex on opt_clients(status);
create index ProductInndex on opt_products(product_id);
create index JoinOrderProductIndex on opt_orders(order_id,product_id);
create index JoinOrderClientIndex on opt_orders(order_id,client_id);
/*
  Оптимізований запит
 */

explain analyze 
with filtredclients as (
	select * from opt_clients where status='active'
),
filtredproducts as (
	select * from opt_products where product_id>9930
),
filtredorders as (
	select * from opt_orders where order_date>='2022-01-01' and order_date<'2023-01-01'
),
clientOrderProduct as (
	select c.id,concat(c.name,' ',c.surname) as fullname,c.email,c.phone, c.address, c.status, o.order_id,o.order_date,o.product_id,p.product_name,p.product_category,p.description 
	from filtredclients c join filtredorders o on c.id=o.client_id 
	join filtredproducts p on o.product_id=p.product_id
),
activeClients as(
	select client_id  as id from opt_orders group by client_id having count(*)>3
),
topCategory as (
	select product_category from opt_products group by product_category order by count(*) desc limit 1
)
select * from clientOrderProduct c
join activeClients a on c.id=a.id 
where product_category in (select * from topCategory )
order by fullname 
limit 1000
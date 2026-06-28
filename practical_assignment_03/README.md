# Практична робота №3 з CS301

**Виконав:** Юрій Псюк — практична група 4

Репозиторій містить розв'язання третьої практичної роботи з CS301.

---

## У даному репозиторії містяться:
1. `main_query.sql` — містить функції, процедури, тригери і тестування необхідні для завдання
2. `create_schema.sql` — містить схему бази даних
3. `*.csv` — таблиці, згенеровані фейкером, для демонстрації роботи БД
4. `Explain_Analyze` — аналіз запиту і його виконання
5. `answers.md` — файл з відповідями на теоретичні питання

---

## Опис завдань

### Task 1
function `calculate_order_total(p_order_id int)` фільтрує order_items по order_id=p_order_id, знаходить їх суму і повертає результата

### Task 2
procedure `create_order(p_customer_id int)` перевіряє чи є такий id в customer, якщо є, то створює нове замовлення з поки 0 total_amount 

### Task 3
procedure `add_product_to_order(p_order_id int, p_product_id int, p_quantity int)` перевіряє чи існують order і product з даними id, перевіряє чи достатньо stock_quantity. Якщо всі умови задовольняються, то оновлюється кількість і додається новий рядок в order_items

### Task 4
trigger `update_order_total` — спрацьовує після DML операцій над order_items і викликає для таких рядків функцію normalizer()
Для усіх рядків з orders де order_id такий ж як в рядків, над якими були операції оновляємо за допомогою функції з Task 1 total_amount.
order_id рядка зі змінами визначається як `coalesce(new.order_id,old.order_id)`, бо при Delete new.order_id=null, при Insert old.order_id=null.

### Task 5
trigger `logger` після створення нових замовлень, викликає для новостворених рядків в orders add_log(). Дана функція вставляє в order_log рядок з даними про customer_id, order_id і час новоствореного замовлення.

---

## Тестування (Task 6)

```sql
insert into customers(full_name,email,balance) values('Anton Bychkov','abychkov@mail',2300); - Створення 1001-ого клієнта
insert into products (product_name,price,stock_quantity) values('Iron Spoon',5,23); - Створення 1001-ого товару
insert into products (product_name,price,stock_quantity) values('Iron Fox',5.2,233); - Створення 1002-ого товару
call create_order(1001); - Виклик процедури для створення 1001-ого замовлення
call add_product_to_order(1001,1001,7); - Викликаємо процедуру для додавання 7 одиниць 1001-ого товару в 1001-е замовлення
call add_product_to_order(1001,1002,9); - Викликаємо процедуру для додавання 9 одиниць 1002-ого товару в 1001-е замовлення 
select * from orders where order_id=1001 - Перевірка чи тригер оновляє total_amount
select * from products where product_id=1001 or product_id=1002 - Перевірка чи списався товар
select * from order_log where order_id=1001 - Перевірка тригера-логера
```
Політика використання штучого інтелекту:
Дані для таблиць генерував за допомогою https://fabricate.tonic.ai/
README.md форматував через GEMINI

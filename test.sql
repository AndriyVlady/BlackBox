-- 1. СОЗДАЕМ ТАБЛИЦУ (теперь это первая команда)
CREATE TABLE IF NOT EXISTS STG_ORDERS (
    order_id INTEGER,
    customer_id INTEGER,
    order_date TIMESTAMP,
    amount DECIMAL
);

-- 2. ВСТАВЛЯЕМ ДАННЫЕ (чтобы было что селектить)
INSERT INTO STG_ORDERS VALUES 
(1, 101, '2026-02-25 10:00:00', 500.00),
(2, 102, '2026-02-25 12:00:00', 300.00);

-- 3. ТВОЙ КРАСИВЫЙ ЗАПРОС С ХЕШАМИ
SELECT
    UPPER(MD5(order_id :: varchar)) AS order_hk,
    customer_id,
    order_date,
    COALESCE(amount, 0) as amount,
    CURRENT_TIMESTAMP() AS load_dts,
    'STG_ORDERS' AS record_source
FROM 
    STG_ORDERS;

select
    UPPER(MD5(order_id :: varchar)) AS order_hk,
    --UPPER(MD5(CAST(order_id AS VARCHAR)))
    customer_id,
    order_date,
    COALESCE(amount, 0) as amount,
    -- IFNULL(amount, 0) IFNULL — это функция конкретных баз (например, MySQL или Snowflake). В универсальном стандарте SQL чаще используют COALESCE
    NOW() AS load_dts,
    'STG_ORDERS' AS record_source -- В DV всегда важно знать, откуда пришла запись
from  STG_ORDERS

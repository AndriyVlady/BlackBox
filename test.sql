select
    UPPER(MD5(order_id :: varchar)) AS order_hk,
    --UPPER(MD5(CAST(order_id AS VARCHAR)))
    customer_id,
    order_date,
    COALESCE(amount, 0) as amount,
    -- IFNULL(amount, 0) IFNULL — это функция конкретных баз (например, MySQL или Snowflake). В универсальном стандарте SQL чаще используют COALESCE
    CURRENT_TIMESTAMP() AS load_dts,
    'STG_ORDERS' AS record_source -- В DV всегда важно знать, откуда пришла запись
from
    STG_ORDERS
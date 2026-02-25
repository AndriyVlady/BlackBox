# Файл с примерами автоматизации Методанных и склейки Python и SQL

def generate_hub_sql(metadata):
    # Достаем значения из словаря (metadata)
    h_name   = metadata['hub_name']
    t_bk     = metadata['target_bk'] # Название колонки в Хабе (customer_id)
    s_table  = metadata['source_table']
    s_bk     = metadata['source_bk'] # Название колонки в источнике (cust_id или client_no)

    # Генерируем SQL
    sql = f"""
    INSERT INTO {h_name} (hub_hk, {t_bk}, load_date, record_source)
    SELECT 
        UPPER(MD5(CAST({s_bk} AS VARCHAR))) as hub_hk, 
        {s_bk} as {t_bk}, 
        CURRENT_TIMESTAMP as load_date, 
        '{s_table}' as record_source
    FROM {s_table} as src
    WHERE NOT EXISTS (
        SELECT 1 FROM {h_name} as tgt 
        WHERE tgt.hub_hk = UPPER(MD5(CAST(src.{s_bk} AS VARCHAR)))
    );
    """
    return sql

# --- А ТЕПЕРЬ МАГИЯ АВТОМАТИЗАЦИИ ---

# Представь, что у нас список маппингов из YAML
mappings = [
    {'hub_name': 'HUB_CUSTOMER', 'target_bk': 'customer_id', 'source_table': 'stg_crm_data', 'source_bk': 'cust_id'},
    {'hub_name': 'HUB_CUSTOMER', 'target_bk': 'customer_id', 'source_table': 'stg_erp_data', 'source_bk': 'client_no'}
]

# Мы просто в цикле прогоняем их через одну и ту же функцию
for m in mappings:
    print(f"-- Генерируем загрузку для {m['source_table']}")
    print(generate_hub_sql(m))


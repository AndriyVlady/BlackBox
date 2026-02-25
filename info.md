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


def generate_sat_sql(metadata):
    sat_name = metadata['sat_name']
    fields = metadata['attributes'] # Это список ['first_name', 'last_name', 'email']
    
    # Мы склеиваем поля для SQL так, чтобы база данных сама их соединила с разделителем
    # Получится что-то вроде: COALESCE(first_name, '') || ';' || COALESCE(last_name, '') ...
    concat_logic = " || ';' || ".join([f"COALESCE(CAST({f} AS VARCHAR), '^^')" for f in fields])
    
    sql = f"""
    INSERT INTO {sat_name} (hash_diff, load_date, {', '.join(fields)})
    SELECT 
        UPPER(MD5({concat_logic})) as hash_diff,
        CURRENT_TIMESTAMP,
        {', '.join(fields)}
    FROM source_table;
    """
    return sql



    def get_concatenated_fields(fields_list):
    # 1. Мы создаем заготовку для каждого поля.
    # f"..." - это шаблон. Мы говорим: "Возьми имя поля и оберни его в COALESCE"
    parts = []
    for field in fields_list:
        part = f"COALESCE(CAST({field} AS VARCHAR), '^^')"
        parts.append(part)
    
    # 2. Теперь мы склеиваем все эти кусочки через разделитель || ';' ||
    result = " || ';' || ".join(parts)
    
    return result

# ПРОВЕРКА:
my_fields = ['first_name', 'last_name', 'email']
print(get_concatenated_fields(my_fields))



1. "Встроенное" (Built-in) — есть всегда
Это как базовые детали конструктора Lego.
print() — вывести на экран.
.join() — склеить список в строку.
lower(), upper() — сменить регистр.
Циклы for и условия if.

2. "Библиотеки" (Packages) — нужно просто импортировать
Это готовые наборы инструментов, которые кто-то уже написал.
import yaml — чтобы Python "понимал" формат YAML.
import hashlib — чтобы считать MD5.
import pandas — (самый важный инструмент дата-инженера) для работы с таблицами.



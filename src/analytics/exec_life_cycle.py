#%%
import pandas as pd
import sqlalchemy
#%%

def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

query = import_query("life_cycle.sql")

#%%
engine_app = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
engine_analytical = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

dates = pd.date_range(start="2024-01-01", end="2024-12-31", freq="D")

for i in dates:
    query_format = query.format(date=i.strftime('%Y-%m-%d'))  # <-- CONVERTER PARA STRING
    df = pd.read_sql(query_format, engine_app)
    
    # Verifica se tem dados
    if not df.empty:
        df.to_sql("life_cycle", engine_analytical, if_exists="append", index=False)
        print(f"✅ {i.strftime('%Y-%m-%d')}: {len(df)} registros inseridos")
    else:
        print(f"⚠️ {i.strftime('%Y-%m-%d')}: Nenhum dado encontrado")

#%%

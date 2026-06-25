#%%
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt

#%%

engine = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
#%%
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

query = import_query("frequencia_valor.sql")
# %%

df = pd.read_sql(query, engine)
df.head()

df = df[df['qtdePontosPos'] < 4000]
# %%

plt.plot(df['qtdeFrequencia'], df['qtdePontosPos'], 'o')
plt.grid(True)
plt.xlabel('Frequência')
plt.ylabel('Valor')
plt.show()


# %%

from sklearn import cluster
from sklearn import preprocessing

minmax = preprocessing.MinMaxScaler()
X = minmax.fit_transform(df[['qtdeFrequencia', 'qtdePontosPos']])

kmean = cluster.KMeans(n_clusters=5)

kmean.fit(X)
df['cluster_calc'] = kmean.labels_



df.groupby(by='cluster_calc')['idCliente'].count()

# %%

import seaborn as sns
sns.scatterplot(data = df, x='qtdeFrequencia', y='qtdePontosPos', hue='cluster_calc', palette='Set1')

plt.hlines(y=1500, xmin=0, xmax=25, colors='black', linestyles='--')
plt.hlines(y=750, xmin=0, xmax=25, colors='black', linestyles='--')

plt.vlines(x= 4, ymin=0, ymax=750, colors='black', linestyles='--')
plt.vlines(x= 10, ymin=0, ymax=3000, colors='black', linestyles='--')

plt.grid()
# %%
sns.scatterplot(data = df, x='qtdeFrequencia', y='qtdePontosPos', hue='cluster', palette='Set1')
plt.grid()
#%%
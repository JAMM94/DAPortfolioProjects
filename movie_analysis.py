# Import libraries

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

# Set the default figure size
plt.rcParams['figure.figsize'] = (12, 8)


# Read in the data
df = pd.read_csv(r'C:\Users\Administrador\Documents\Programas\data_analysis\movies.csv')
print(df.head())

for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, pct_missing))

# Data types for our columns

print(df.dtypes)

# Change data type of columns

df['budget'] = df['budget'].fillna(0).astype('int64')
df['gross'] = df['gross'].fillna(0).astype('int64')

# Create correct Year column

df['yearCorrect'] = df['released'].str.split(',').str[1].str.strip().str[:4]

df = df.sort_values(by=['gross'], inplace=False, ascending=False)


#Drop any duplicates

print(df['company'].drop_duplicates().sort_values(ascending=False))

# Hipotesis
#   Budget high correlation
#   Company high correlation

# Scatter plot with budget vs gross

plt.scatter(x=df['budget'], y=df['gross'])
plt.title('Budget vs Gross Earnings')
plt.xlabel('Gross Earnings')
plt.ylabel('Budget for film')
plt.show()

# Plot budget vs gross using seaborn

sns.regplot(x='budget', y='gross', data=df, scatter_kws={"color":"red"}, line_kws={"color":"blue"})
plt.show()

# Looking at correlation

numeric_df = df.select_dtypes(include=[np.number])
correlation_matrix = numeric_df.corr()
print(correlation_matrix)

# High correlation between budget and gross

sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation Matrix for Numeric Features')
plt.show()

# Looks at company

df_numerized = df

for col_name in df_numerized:
    if(df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes

print(df_numerized.head())

numeric_df = df_numerized.select_dtypes(include=[np.number])
correlation_matrix = numeric_df.corr()
sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation Matrix for Numeric Features')
plt.show()

pd.set_option('display.max_rows', None)

correlation_mat = df_numerized.corr()
corr_pairs = correlation_mat.unstack()
sorted_pairs = corr_pairs.sort_values()
high_corr = sorted_pairs[(sorted_pairs) > 0.5]
print(high_corr)

# Votes and budget have the highest correlation to gross earnings
# Company has low correlation
import pandas as pd

# load the dataset
df = pd.read_csv('Realestate.csv')

# 2. normalize houseAge with min-max scaling (puts everything between 0 and 1)
age_min = df['houseAge'].min()
age_max = df['houseAge'].max()
normalized_age = (df['houseAge'] - age_min) / (age_max - age_min)

# 3. store the normalized values in a new column
df['houseAgeStandardized'] = normalized_age
print(df[['houseAge', 'houseAgeStandardized']].head())

# 4. drop the convenience stores column, inplace so df actually changes
df.drop(columns=['numberOfConvenienceStores'], inplace=True)

# 5. rename transaction -> transactionDate
df.rename(columns={'transaction': 'transactionDate'}, inplace=True)

# 6. .loc uses labels and includes the end, so 0-10 gives 11 rows
print(df.loc[0:10])

# 7. .iloc uses positions and excludes the end, so 0:10 gives the first 10
print(df.iloc[0:10])

# 8. check for duplicate rows, then drop them and reset the index
print('Duplicates found:', df.duplicated().sum())
print(df[df.duplicated(keep=False)])
df.drop_duplicates(inplace=True)
df.reset_index(drop=True, inplace=True)
print('Rows after removing duplicates:', len(df))

# 9. count missing values per column, then fill with each column's mean
print(df.isnull().sum())
df.fillna(df.mean(numeric_only=True), inplace=True)
print('Missing values left:', df.isnull().sum().sum())

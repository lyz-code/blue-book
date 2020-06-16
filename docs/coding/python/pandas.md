---
title: Pandas
date: 20200616
author: Lyz
---

[Pandas](https://pandas.pydata.org/) is a fast, powerful, flexible and easy to
use open source data analysis and manipulation tool, built on top of the Python
programming language.

# Install

```bash
pip3 install pandas
```

Import

```python
import pandas as pd
```


# Snippets

## [Load csv](https://www.shanelynn.ie/python-pandas-read_csv-load-data-from-csv-files/)

```python
data = pd.read_csv("filename.csv")
```

If you want to parse the dates of the `start` column give `read_csv` the
argument `parse_dates=['start']`.

## [Do operation on column data and save it in other column](https://stackoverflow.com/questions/26886653/pandas-create-new-column-based-on-values-from-other-columns-apply-a-function-o)

```python
# make a simple dataframe
df = pd.DataFrame({'a':[1,2], 'b':[3,4]})
df
#    a  b
# 0  1  3
# 1  2  4

# create an unattached column with an index
df.apply(lambda row: row.a + row.b, axis=1)
# 0    4
# 1    6

# do same but attach it to the dataframe
df['c'] = df.apply(lambda row: row.a + row.b, axis=1)
df
#    a  b  c
# 0  1  3  4
# 1  2  4  6
```
## [Get unique values of column](https://chrisalbon.com/python/data_wrangling/pandas_list_unique_values_in_column/)

If we want to get the unique values of the `name` column:

```python
df.name.unique()
```

## [Extract columns of dataframe](https://stackoverflow.com/questions/11285613/selecting-multiple-columns-in-a-pandas-dataframe)
```python
df1 = df[['a','b']]
```
## [Remove dumplicate rows](https://jamesrledoux.com/code/drop_duplicates)

```python
df = df.drop_duplicates()
```

## [Remove column from dataframe](https://stackoverflow.com/questions/13411544/delete-column-from-pandas-dataframe)

```python
del df['name']
```

## [Count unique combinations of values in selected columns](https://stackoverflow.com/questions/35268817/unique-combinations-of-values-in-selected-columns-in-pandas-data-frame-and-count)

```python
df1.groupby(['A','B']).size().reset_index().rename(columns={0:'count'})

     A    B  count
0   no   no      1
1   no  yes      2
2  yes   no      4
3  yes  yes      3
```
## [Get row that contains the maximum value of a column](https://stackoverflow.com/questions/15741759/find-maximum-value-of-a-column-and-return-the-corresponding-row-values-using-pan)
```python
df.loc[df['Value'].idxmax()]
```

# References

* [Homepage](https://pandas.pydata.org/)


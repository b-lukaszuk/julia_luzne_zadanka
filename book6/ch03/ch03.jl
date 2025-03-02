import CSV as Csv
import CairoMakie as Cmk
import DataFrames as Dfs
import GLM as Glm

const Flt = Float64
const Int = Int64
const Str = String
const Vec = Vector

# 3.6 Lab: Linear Regression

## 3.6.1 Importing Packages

# In [2]
# https://www.statsmodels.org/stable/index.html

# In [3]
# https://www.statsmodels.org/dev/generated/statsmodels.stats.outliers_influence.variance_inflation_factor.html
# https://www.statsmodels.org/stable/generated/statsmodels.stats.anova.anova_lm.html

# In [4]
# https://github.com/jonathan-taylor/ISLP/blob/master/ISLP/__init__.py
# https://github.com/jonathan-taylor/ISLP/blob/master/ISLP/models/__init__.py

# In [5]
names(Base)
names(Core)
varinfo(Base)
varinfo(Core)

# In [6]
a = [3, 5, 11]

# In [7]
sum(a)


## 3.6.2 Simple Linear Regression

# In [8]
# dataset description
# https://islp.readthedocs.io/en/latest/datasets/Boston.html
boston = Csv.read("./Boston.csv", Dfs.DataFrame);
Dfs.select!(boston, Dfs.Not(:Column1));
names(boston)

# In [9]
# lstat: lower status of the population (percent).
nRows, nCols = size(boston);
x = Dfs.DataFrame(Dict(
    "intercept" => ones(Flt, nRows),
    "lstat" => boston.lstat));
x[1:4, :]

# In [10-11]
# medv: median value of owner-occupied homes in $1000s.
x.medv = boston.medv
model = Glm.lm(Glm.@formula(medv ~ lstat), x)

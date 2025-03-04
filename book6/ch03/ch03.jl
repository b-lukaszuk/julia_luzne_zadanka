import CSV as Csv
import CairoMakie as Cmk
import DataFrames as Dfs
import GLM as Glm
import Statistics as St

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
varinfo()

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
x.medv = boston.medv # response variable
model = Glm.lm(Glm.@formula(medv ~ lstat), x)

### Using Transformations: Fit and Transform

# In [12-13]
design = Dfs.DataFrame(Dict(
    "intercept" => ones(Flt, nRows),
    "lstat" => boston.lstat));
first(design, 4)

# In [14]
Glm.coeftable(model)

# In [15]
for (cn, cv) in zip(Glm.coefnames(model), Glm.coef(model))
    println("$(rpad(cn, 15))$cv")
end

# In [16]
new_df = Dfs.DataFrame((lstat=[5, 10, 15]))

# In [17]
Glm.predict(model, new_df)

# In [18]
Glm.predict(model, new_df, interval=:confidence, level=0.95)
# interval=:confidence, 95% CI for predicted mean
# https://en.wikipedia.org/wiki/Confidence_interval

# In [19]
Glm.predict(model, new_df, interval=:prediction, level=0.95)
# interval=:prediction, 95% CI for predicted data points
# https://en.wikipedia.org/wiki/Prediction_interval

### Defining Functions

# In [20-21]
# use Cmk.ablines

# In [22]
fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1],
              title="Boston dataset",
              xlabel = "lower status of the population (percent)",
              ylabel = "medium value of owner occupied homes (in \$1000)");
Cmk.scatter!(ax, x.lstat, x.medv);
Cmk.ablines!(ax, Glm.coef(model)[1], Glm.coef(model)[2],
             linewidth=3);
fig

# In [23]
res = Glm.residuals(model)
pred = Glm.predict(model)
formula = string(Glm.formula(model))

fig = Cmk.Figure(size=(800, 800));
ax = Cmk.Axis(fig[1, 1],
              title="Residuals vs Fitted\n" * formula,
              xlabel="Fitted values", ylabel="Residuals");
Cmk.scatter!(ax, pred, res);
Cmk.hlines!(ax, 0, linestyle=:dash, color="gray");
fig

# In [24], not sure if that's entirely it, but it should do the trick
infl = Glm.cooksdistance(model)
quant = 0.99
cutoff = St.quantile(infl, quant)
outliers = infl[infl .> cutoff]
inds = collect(1:nRows)[infl .> cutoff]

fig = Cmk.Figure(size=(800, 800));
ax = Cmk.Axis(fig[1, 1],
              title="Leverage vs Index\n" * formula,
              xlabel="Index", ylabel="Leverage");
Cmk.scatter!(ax, 1:nRows, infl);
Cmk.hlines!(ax, cutoff, linestyle=:dash, color="red");
Cmk.text!(ax, 0, cutoff * 1.05, text="percentile = $(quant*100)");
Cmk.text!(ax, inds, outliers .* 1.05, text=string.(inds));
fig

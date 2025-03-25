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
bostonModel = Glm.lm(Glm.@formula(medv ~ lstat), x)

### Using Transformations: Fit and Transform

# In [12-13]
design = Dfs.DataFrame(Dict(
    "intercept" => ones(Flt, nRows),
    "lstat" => boston.lstat));
first(design, 4)

# In [14]
Glm.coeftable(bostonModel)

# In [15]
for (cn, cv) in zip(Glm.coefnames(bostonModel), Glm.coef(bostonModel))
    println("$(rpad(cn, 15))$cv")
end

# In [16]
new_df = Dfs.DataFrame((lstat=[5, 10, 15]))

# In [17]
Glm.predict(bostonModel, new_df)

# In [18]
Glm.predict(bostonModel, new_df, interval=:confidence, level=0.95)
# interval=:confidence, 95% CI for predicted mean
# https://en.wikipedia.org/wiki/Confidence_interval

# In [19]
Glm.predict(bostonModel, new_df, interval=:prediction, level=0.95)
# interval=:prediction, 95% CI for predicted data points
# https://en.wikipedia.org/wiki/Prediction_interval

### Defining Functions

# In [20-21]
# draws scatterplot (x, y) with simple linear regression line
function drawScatterPlotWithRegLine(
    df::Dfs.DataFrame, x::String, y::String,
    title::String, xlabel::String, ylabel::String)::Cmk.Figure

    model::Glm.StatsModels.TableRegressionModel = Glm.lm(
        Glm.term(y) ~ Glm.term(x), df)
    fig::Cmk.Figure = Cmk.Figure()
    ax::Cmk.Axis = Cmk.Axis(fig[1, 1],
                            title=title, xlabel = xlabel, ylabel = ylabel)
    Cmk.scatter!(ax, df[:, x], df[:, y])
    Cmk.ablines!(ax, Glm.coef(model)[1], Glm.coef(model)[2], linewidth=3)
    return fig

end

# In [22]
drawScatterPlotWithRegLine(x, "lstat", "medv",
                           "Boston dataset",
                           "lower status of the population (percent)",
                           "medium value of owner occupied homes (in \$1000)")

# In [23]
function drawResidualsVsFitted(
    model::Glm.StatsModels.TableRegressionModel)::Cmk.Figure

    res::Vec{Flt} = Glm.residuals(model)
    pred::Vec{Flt} = Glm.predict(model)
    formula::Str = string(Glm.formula(model))
    fig::Cmk.Figure = Cmk.Figure()
    ax::Cmk.Axis = Cmk.Axis(fig[1, 1], title="Residuals vs Fitted\n" * formula,
                            xlabel="Fitted values", ylabel="Residuals")
    Cmk.scatter!(ax, pred, res)
    Cmk.hlines!(ax, 0, linestyle=:dash, color="gray")
    return fig

end

drawResidualsVsFitted(bostonModel)


# In [24], not sure if that's entirely it, but it should do the trick
function drawLeverageVsIndex(
    model::Glm.StatsModels.TableRegressionModel,
    cutoffPercentile::Int=99)::Cmk.Figure

    @assert 0 <= cutoffPercentile <= 100
    infl::Vec{Flt} = Glm.cooksdistance(model)
    quant::Flt = cutoffPercentile / 100
    cutoff::Flt = St.quantile(infl, quant)
    outliers::Vec{Flt} = infl[infl .> cutoff]
    inds::Vec{Int} = collect(1:length(infl))
    indsOutliers::Vec{Int} = inds[infl .> cutoff]
    formula::Str = string(Glm.formula(model))
    fig::Cmk.Figure = Cmk.Figure()
    ax::Cmk.Axis = Cmk.Axis(fig[1, 1], title="Leverage vs Index\n" * formula,
                            xlabel="Index", ylabel="Leverage")
    Cmk.scatter!(ax, inds, infl)
    Cmk.hlines!(ax, cutoff, linestyle=:dash, color="red")
    Cmk.text!(ax, 0, cutoff * 1.05, text="percentile = $cutoffPercentile")
    Cmk.text!(ax, indsOutliers, outliers .* 1.05, text=string.(indsOutliers))
    return fig
end

drawLeverageVsIndex(bostonModel)

## 3.6.3 Multiple Linear Regression

# In [25]
x = boston[:, ["medv", "lstat", "age"]];
bostonModel1 = Glm.lm(Glm.term("medv") ~ sum(Glm.term.(["lstat", "age"])), x)

# In [26]
terms = names(boston, Dfs.Not("medv"));

# In [27]
bostonModel2 = Glm.lm(
    Glm.term("medv") ~ sum(Glm.term.(terms)), boston)

# In [28]
terms = names(boston, Dfs.Not("medv", "age"));
bostonModel3 = Glm.lm(
    Glm.term("medv") ~ sum(Glm.term.(terms)), boston)


## 3.6.4 Multiple Goodness of Fit

# In [29]
vif_df = Dfs.DataFrame(term=terms, vif=Glm.vif(bostonModel3))

# In [30] unnecessary, the code above did the trick, and did it well


## 3.6.5 Interaction Terms

# In [31]
x = boston[:, [:lstat, :age, :medv]]
bostonModel4 = Glm.lm(Glm.@formula(medv ~ lstat * age), x)

## 3.6.6 Non-linear Transformations of the Predictiors

# In [32]
x = boston[:, [:lstat, :age, :medv]]
# no orthogonal polynomials
bostonModel5 = Glm.lm(Glm.@formula(medv ~ lstat + lstat^2 + age), x)

# In [33]
Glm.ftest(bostonModel1.model, bostonModel5.model)

# In [34]
drawResidualsVsFitted(bostonModel5)

## 3.6.7 Qualitative Predictors
carseats = Csv.read("./Carseats.csv", Dfs.DataFrame);
names(carseats)

terms = setdiff(names(carseats), ["Sales"])
model = Glm.lm(
    Glm.term("Sales") ~ sum(Glm.term.(terms)) +
        Glm.term("Income")&Glm.term("Advertising") +
        Glm.term("Price")&Glm.term("Age"),
    carseats)
# or
model = Glm.lm(
    Glm.term("Sales") ~ sum(Glm.term.(terms)) +
        prod(Glm.term.(["Income", "Advertising"]))+
        prod(Glm.term.(["Price", "Age"])),
    carseats)

# Exercise 8
# simple linear regression on the Auto data set
auto = Csv.read("./Auto.csv", Dfs.DataFrame, missingstring="?");
names(auto)
Dfs.describe(auto)

# a) perform simple linear regression: mpg ~ horsepower
# i. is there a relationship between the predictor and response?
# ii. How strong is the relationship?
# iii. is the relationship positive or negative
# iv. what is the value of mpg with horsepower of 98, what are 95%
# confidence and prediction intervals?
automod = Glm.lm(Glm.@formula(mpg ~ horsepower), auto)
# i. yes; ii. -0.158; iii. negative;
# iv.
df = Dfs.DataFrame(Dict(:horsepower => [98]))
Glm.predict(automod, df)
Glm.predict(automod, df, interval=:confidence, level=0.95)
Glm.predict(automod, df, interval=:prediction, level=0.95)

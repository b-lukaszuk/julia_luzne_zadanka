import CSV as Csv
import CairoMakie as Cmk
import DataFrames as Dfs
import Distributions as Dsts
import Random as Rand
import Statistics as Stats
import StatsBase as Sb

# below a simple code
# not succinct, not error-proof, not optimized for speed, etc.

const Flt = Float64
const Int = Int64
const Str = String
const Vec = Vector

# 2.3 Lab: Introduction to Python

## 2.3.2 Basic Commands
println("Fit a model with ", 11, " variables") # In [1]
3+5 # In [3]
"hello" * " " * "world" # In [4]
x = [3, 4, 5] # In [5]

y = [4, 9, 7] # In [6]
# creates a copy of x and y
z = vcat(x, y) # In [6]

## 2.3.3 Introduction to Numerical Python
x = [3, 4, 5] # In [8]
y = [4, 9, 7] # In [8]
x .+ y # In [9]

x = [1 2; 3 4] # In [10]
ndims(x) # In [11]
typeof(x), typeof(x[1]) # In [12]

size(x) # In [16]
sum(x) # In [17]

# In [19]
x = collect(1:6)
x
x_reshaped = reshape(x, (2, 3)) # colum major, not row major
# currently v1.10.6, no change to row major possible
x_reshaped # be careful, changing x elts, changes x_reshaped
# so it acts similarily to python
x
x[2] = 10
x
x_reshaped

# elts of Matrix{T} are copies of v
function reshapeVec(v::Vec{T}, r::Int, c::Int, byRow::Bool)::Matrix{T} where T
    len::Int = length(v)
    @assert (len == r*c)
    m::Matrix{T} = Matrix{T}(undef, r, c)
    stepBegin::Int = 1
    stepSize::Int = (byRow ? c : r) - 1
    for i in 1:(byRow ? r : c)
        if byRow
            m[i, :] = v[stepBegin:(stepBegin+stepSize)]
        else
            m[:, i] = v[stepBegin:(stepBegin+stepSize)]
        end
        stepBegin += (stepSize + 1)
    end
    return m
end

reshapeVec(x, 2, 3, false)
x_reshaped
reshapeVec(x, 2, 3, true)

x_reshaped[1, 1]
x_reshaped[2, 3]

# In [23]
my_tuple = (3, 4, 5)
my_tuple[1] = 2 # error, tuples cannot be changed after created

sqrt.(x) # In [25]
x .^ 2 # In [26]
x .^ 0.5 # In [27]

# random numbers from N(0, 1)
x = Rand.rand(Dsts.Normal(), 50) # In [28]
y = x .+ Rand.rand(Dsts.Normal(50, 1), 50) # In [29]
Stats.cor(x, y) # In [30]

# In [31]
# diffrent random nums
Rand.rand(Dsts.Normal(0, 5), 2)
Rand.rand(Dsts.Normal(0, 5), 2)

# In [32]
# the same random nums
Rand.seed!(1303)
Rand.rand(Dsts.Normal(0, 5), 2)
Rand.seed!(1303)
Rand.rand(Dsts.Normal(0, 5), 2)

# In [33]
Rand.seed!(3)
y = Rand.rand(Dsts.Normal(), 10)

# In [34]
# Stats.var(y) == Stats.var(y, corrected=true)
Stats.var(y), Stats.std(y), Stats.mean(y)

# matrix
Rand.seed!(3)
y = Rand.rand(Dsts.Normal(), (10, 3))
y = [1 2 3; 4 5 6]
Stats.mean(y)
Stats.mean(y, dims=1) # col-major first
# In [37]
Stats.mean(y, dims=2) # row-major second

# 2.3.4 Graphics
# In [39-46]
x = Rand.rand(Dsts.Normal(), 100)
y = Rand.rand(Dsts.Normal(), 100)
fig = Cmk.Figure();
ax1 = Cmk.Axis(fig[1, 2],
               title="Plot of X vs Y",
               xlabel="this is the x-axis",
               ylabel="this is the y-axis");
Cmk.scatter!(ax1, x, y, marker=:circle);
ax2 = Cmk.Axis(fig[2, 3],
               title="Plot of X vs Y",
               xlabel="this is the x-axis",
               ylabel="this is the y-axis");
Cmk.scatter!(ax2, x, y, marker=:cross);
fig

# In [47]
#Cmk.save("figure.png", fig)
#Cmk.save("figure.pdf", fig)

# In [49]
# contourplots
x = range(-π, π, 50)
y = range(-π, π, 50)
# from: https://en.wikipedia.org/wiki/Outer_product
# outer product (≈ np.multiply.outer) of vectors x and y is: x *- y'
f = cos.(y) *- (1 ./ (1 .+ x.^2))'

# In [49] c.d.
# x and y axes are swapped compared to python
fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1]);
Cmk.contour!(ax, x, y, f);
fig

# In [50]
# x and y axes are swapped compared to python
fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1]);
Cmk.contour!(ax, f; levels=45);
fig

# In [51]
# x and y axes are swapped compared to python
fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1]);
Cmk.contourf!(ax, f; levels=100, colormap=:viridis);
fig

## 2.3.5 Sequences and Slice Notation
seq1 = 0:10 |> collect # In [52]
seq2 = 0:10 |> collect # In [53]

# In [54]
"hello world"[4:5]

## 2.3.6 Indexing Data
A = reshapeVec(0:15 |> collect, 4, 4, true) # In [56]

A[2, 3] # In [57]

### Indexing Rows, Columns, and Submatrices
A[[2, 4], :] # In [58]
A[:, [1, 3]] # In [59]
A[[2, 4], [1, 3]] # In [60] - In [63]
A[[2, 4], [1, 3, 4]] # In [64]
A[2:2:4, 1:2:3] # In [65]

### Boolean indexing
keep_rows = zeros(Bool, size(A)[1]) # In [66]
keep_rows[[2, 4]] .= true # In [67]
keep_rows # In [67]

# In [68]
all(keep_rows .== Vector{Int}([0, 1, 0, 1]))
all(keep_rows .== Vector{Bool}([true, false, true, false]))

# In [69]
A[Vector{Int}([0, 1, 0, 1])] # error, Julia is 1-indexed

A[keep_rows, :] # In [70]

# In [71]
keep_cols = zeros(Bool, size(A)[2])
keep_cols[[1, 3, 4]] .= true
A[keep_rows, keep_cols]

# In [72]
A[[2, 4], keep_cols]

## 2.3.7 Loading Data

### Reading in a Data Set

# In [73]
# dataset description
# https://islp.readthedocs.io/en/latest/datasets/Auto.html
auto = Csv.read("./Auto.csv", Dfs.DataFrame)
first(auto, 2)

# In [74]
# workaround, still, better to use *.csv
# delimiters are spaces (multiple) or tabs
auto = Csv.read(
    IOBuffer(replace(read("./Auto.data"), UInt8('\t') => UInt8(' '))),
    Dfs.DataFrame, delim=" ", ignorerepeated=true,
    types=[Flt, Int, Flt, Flt, Flt, Flt, Int, Int, Str])
first(auto, 2)

# In [74]
auto.horsepower # or
# auto[!, "horsepower"]

# In [76]
# unique(auto.horsepower)
show(stdout, "text/plain", unique(auto.horsepower))

# In [77]
auto = Csv.read("./Auto.csv", Dfs.DataFrame,
                types=[Flt, Int, Flt, Flt, Flt, Flt, Int, Int, Str],
                missingstring="?")
show(stdout, "text/plain", unique(auto.horsepower))
sum(auto.horsepower |> skipmissing)

# In [78]
size(auto)

# In [79]
auto_new = Dfs.dropmissing(auto)
size(auto_new)

### Basics of Selecting Rows and Columns

# In [80]
auto = auto_new
names(auto)

# In [81]
auto[1:3, :]

# In [82]
idx_80 = auto.year .> 80
auto[idx_80, :]

# In [83]
auto[!, ["mpg", "horsepower"]]

# In 84-86
# no index in DataFrames.jl

# In [87]
isOK(n) = n in ["amc rebel sst", "ford torino"]
auto[map(isOK, auto.name), :]
# or more enigmatic
auto[auto.name .∈ Ref(["amc rebel sst", "ford torino"]), :]

# In [88]
auto[[4, 5], :]

# In [89]
auto[:, [1, 3, 4]]
# auto[!, [1, 3, 4]]

# In [90]
auto[[4, 5], [1, 3, 4, 9]]

# In [91]
isOK(n) = n in ["ford galaxie 500"]
auto[map(isOK, auto.name), ["mpg", "origin", "name"]]
# or
auto[auto.name .== "ford galaxie 500", ["mpg", "origin", "name"]]

### More on Selecting Rows and Columns
# In [92-93]
auto[auto.year .> 80, ["weight", "origin"]]

# In [94]
auto[auto.year .> 80 .&& auto.mpg .> 30, ["weight", "origin", "mpg"]]

# In [95]
auto[auto.displacement .< 300 .&&
    contains.(auto.name, "ford") .||
    contains.(auto.name, "datsun"),
     ["displacement", "weight", "origin", "name"]]

## 2.3.8 For Loops

# In [96]
total = 0
for value in [3, 2, 19]
    total += value
end
println("Total is: $total")

# In [97]
total = 0
for value in [2, 3, 19]
    for weight in [3, 2, 1]
        total += value * weight
    end
end
println("Total is $total")

# In [98]
total = 0
for (value, weight ) in zip([2, 3, 19], [0.2, 0.3, 0.5])
    total += weight * value
end
println("Weighted average is: $total")

### String Formatting
# In [99]
Rand.seed!(1);
a = round.(Rand.randn(20, 5), digits=3);
getNum(rn) = rn < 0.8 ? 0 : missing;
m = getNum.(Rand.rand(size(a)...));
a += m;
df = Dfs.DataFrame(a, :auto);
Dfs.rename!(df, ["food", "bar", "pickle", "snack", "popcorn"]);
first(df, 5)

# In [100]
for cn in names(df)
    println("Column '$(cn)' has ",
            "$(ismissing.(df[!, cn]) |> Stats.mean)% ",
            "of missing values")
end

## 2.3.9 Additional Graphical and Numerical Summaries

# In [101]
# fig = Cmk.Figure()
# ax = Cmk.Axis(fig[1, 1])
# Cmk.scatter(horsepower, mpg) # produces error
# fig

# In [102]
Cmk.scatter(auto.horsepower, auto.mpg)


# In [103]
Cmk.scatter(auto.horsepower, auto.mpg, axis=(;title="Horsepower vs. MPG"))

# In [104]
#Cmk.save("horsepower_mpg.png", fig)

# In [105]
fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1], title="Horsepower vs. MPG");
Cmk.scatter!(ax, auto.horsepower, auto.mpg);
# other axes can be added at need
fig

# In [106-107]
fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1], xlabel="cylinders", ylabel="MPG", xticks=3:8);
Cmk.boxplot!(ax, auto.cylinders, auto.mpg, whiskerwidth=0.5);
fig

# In [108]
fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1],
              title="MPG distribution", xlabel="MPG", ylabel="Count");
Cmk.hist!(ax, auto.mpg, strokewidth=1);
fig

# In [109]
fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1],
              title="MPG distribution", xlabel="MPG", ylabel="Count");
Cmk.hist!(ax, auto.mpg, strokewidth=1, color=:red, bins=12);
fig

# In [110-111]
function drawScatterOrHist!(df::Dfs.DataFrame, fig!::Cmk.Figure,
                            row::Int, col::Int, rowName::Str, colName::Str)
    @assert (row > 0 && col > 0) "row and col need to be positive integers"
    if rowName == colName
        ax = Cmk.Axis(fig![row, col], xlabel=rowName, ylabel="Count",
                      xlabelsize=22, ylabelsize=22)
        Cmk.hist!(ax, df[!, rowName], strokewidth=1)
    else
        ax = Cmk.Axis(fig![row, col], xlabel=rowName, ylabel=colName,
                      xlabelsize=22, ylabelsize=22)
        Cmk.scatter!(ax, df[!, rowName], df[!, colName])
    end
    return nothing
end

function drawPairplot(df::Dfs.DataFrame, colNames::Vec{Str})::Cmk.Figure
    len::Int = length(colNames)
    colTypes::Vec{Type} = eltype.(eachcol(df[!, colNames]))
    numTypes::Vec{Bool} = [t in [Flt, Int] for t in colTypes]
    @assert (1 < len < 6) "can handle between 2 to 5 columns only"
    @assert all(numTypes) "all columns must be either Flt or Int"
    fig::Cmk.Figure = Cmk.Figure(size=(900 * len, 600 * len))
    for r in 1:len, c in 1:len
        drawScatterOrHist!(df, fig, r, c, colNames[r], colNames[c])
    end
    return fig
end

drawPairplot(auto, ["mpg", "displacement", "weight"])
drawPairplot(auto, ["cylinders", "mpg", "displacement", "weight"])

# In [112]
Dfs.describe(auto[!, ["mpg", "weight"]])

# In [113]
Dfs.describe(auto.cylinders)
Dfs.describe(auto.mpg)

# Applied

# Exercise 8
# a)-b) read in College.csv
# c) describe the data
# d) draw pair-plot for columns ["Top10perc", "Apps", "Enroll"]
# e) produce side by side box-plots of "Outstate" vs. "Private"
# f) create column "Elite"{"No", "Yes"} based on "Top10perc" (>50%)
# see how many top universities are there, draw box-plot for Outstate and Elite
# g) draw some histograms for the data

# 8 a)-b)
# dataset description
# https://islp.readthedocs.io/en/latest/datasets/College.html
college = Csv.read("./College.csv", Dfs.DataFrame);
Dfs.rename!(college, :Column1 => "College");
first(college, 2)
size(college)

# 8 c)
Dfs.describe(college); # trimmed output
show(stdout, "text/plain", Dfs.describe(college)) # full output

# 8 d)
drawPairplot(college, ["Top10perc", "Apps", "Enroll"])

# 8 e)
nrows, ncol = size(college);
privCategNames = college.Private |> unique; # returned ["Yes", "No"]
privCategVals = eachindex(privCategNames) |> reverse;
privateMap = Dict(zip(privCategNames, privCategVals));
xs = get.(Ref(privateMap), college.Private, 0);
ys = college.Outstate;

fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1], title="Out-of-state tuition per college type",
              xlabel="Private College",
              ylabel="Out-of-state tuition [thousands USD]",
              xticks=(privCategVals, privCategNames),
              yticks=(5000:5000:20000, string.(5:5:20))
);
Cmk.boxplot!(ax, xs, ys, whiskerwidth=0.5);
fig

# 8 f)
# Top10perc - new students from top 10% of high school class
college.Elite = ifelse.(college.Top10perc .> 50, "Yes", "No")
nrows, ncol = size(college);
eliteCategNames = college.Elite |> unique; # returned ["No", "Yes"]
eliteCategVals = eachindex(eliteCategNames);
eliteateMap = Dict(zip(eliteCategNames, eliteCategVals));
xs = get.(Ref(eliteateMap), college.Elite, 0);
ys = college.Outstate;

fig = Cmk.Figure();
ax = Cmk.Axis(fig[1, 1], title="Out-of-state tuition per college eliteness",
              xlabel="Elite College",
              ylabel="Out-of-state tuition [thousands USD]",
              xticks=(eliteCategVals, eliteCategNames),
              yticks=(0:5000:25000, string.(0:5:25))
);
Cmk.boxplot!(ax, xs, ys, whiskerwidth=0.5);
Cmk.ylims!(ax,0, 25000);
fig

# how many elite colleges are there
Sb.countmap(college.Elite)
Sb.proportionmap(college.Elite)

# 8 g)
fig = Cmk.Figure(size=(800*4, 500*4));
for (i, var) in enumerate(["Apps", "Accept", "Enroll", "Top10perc"])
    ax = Cmk.Axis(fig[i, 1],
                  title=var* " distribution",
                  xlabel=var, ylabel="Count",
                  titlesize=30,
                  xlabelsize=26, ylabelsize=26);
    Cmk.hist!(ax, college[!, var], strokewidth=1);
end
fig

# Exercise 9
# for auto data set
# b) determine range of values for each quantitative predictor
# c) determine mean and standard deviation for each quantitative predictor
# d) remove obs 10:85 and calculate, range, mean, std
# f) which vars could be useful in predicting gas mileage (mpg) based on plots?
auto = Csv.read("./Auto.csv", Dfs.DataFrame,
                types=[Flt, Int, Flt, Flt, Flt, Flt, Int, Int, Str],
                missingstring="?")
quantVars = ["mpg", "cylinders", "displacement", "horsepower", "weight",
             "acceleration", "year", "origin"]

# 9 b)
isPresent(val) = !ismissing(val)
removeNAs(vec) = vec[isPresent.(vec)]
getExtrema(vec) = removeNAs(vec) |> extrema
Dfs.combine(auto, quantVars .=> getExtrema)

# 9 c)
getMean(vec) = removeNAs(vec) |> Stats.mean
getStd(vec) = removeNAs(vec) |> Stats.std
Dfs.combine(auto, quantVars .=> getMean)
Dfs.combine(auto, quantVars .=> getStd)
# or together
Dfs.combine(auto, quantVars .=> [getMean getStd])

# 9 d)
auto2 = auto[setdiff(1:end, 10:85), :]
Dfs.combine(auto2, quantVars .=> getExtrema)
Dfs.combine(auto2, quantVars .=> getMean)
Dfs.combine(auto2, quantVars .=> getStd)

# 9 f)
preds = ["displacement", "horsepower", "weight", "acceleration", "year"]
len = length(preds)
fig = Cmk.Figure(size=(2000, 500 * len));
for (i, p) in enumerate(preds)
    ax = Cmk.Axis(fig[i, 1], xlabel=p, ylabel="mpg",
                  xlabelsize=30, ylabelsize=30);
    Cmk.scatter!(ax, auto[!, p], auto[!, "mpg"]);
end
fig

# Exercise 10
# use the Boston data set
# b) examine the data set (rows, cols, summary statistics)
# c) draw some pairwise scatter-plots
# e) do any of the suburbs of Boston appear to have particularly high:
# crime rates? tax rates? pupil-teacher ratios?
# h) which suburb of Boston has the lowest median value of owner occupied homes
# i) how many of the suburbs average more than:
# 7 rooms per dwelling?
# 8 rooms per dwelling?

# dataset description
# https://islp.readthedocs.io/en/latest/datasets/Boston.html
boston = Csv.read("./Boston.csv", Dfs.DataFrame);
Dfs.select!(boston, Dfs.Not(:Column1));

# 10 b)
first(boston, 2)
size(boston) # each row is a different suburb
Dfs.describe(boston)

# 10 c)
drawPairplot(boston, names(boston)[1:3])
drawPairplot(boston, names(boston)[4:6])
drawPairplot(boston, names(boston)[7:9])
drawPairplot(boston, names(boston)[10:13])

# e) do any of the suburbs of Boston appear to have particularly high:
# each row is a different suburb
function drawHist(df::Dfs.DataFrame, colName::Str)::Cmk.Figure
    fig = Cmk.Figure()
    drawScatterOrHist!(df, fig, 1, 1, colName, colName)
    return fig
end
getPercGT(vec, val) = Stats.mean(vec .> val)

# crime rates?
drawHist(boston, "crim") # by the eye: crim > 30
getPercGT(boston.crim, 30) # roughly 85 percentile
boston[boston.crim .> 30, :]
Stats.quantile(boston.crim, 0.99)
boston[boston.crim .>= 41.37, :]

# tax rates?
drawHist(boston, "tax") # by the eye: tax > 600
getPercGT(boston.tax, 600) # roughly 70 percentile
boston[boston.tax .> 600, :]
Stats.quantile(boston.tax, 0.99)
boston[boston.tax .>= 666, :]
boston[boston.tax .> 666, :]

# pupil-teacher ratios?
drawHist(boston, "ptratio") # by the eye: ptratio > 20
getPercGT(boston.ptratio, 20) # roughly 60 percentile
boston[boston.ptratio .> 20, :]
Stats.quantile(boston.ptratio, 0.99)
boston[boston.ptratio .>= 21.2, :]

# h) lowest median value of owner occupied homes
minMedv = minimum(boston.medv)
inds = findall(boston.medv .== minMedv)
boston[inds, :]

# i)
# 7 rooms per dwelling?
(boston.rm .> 7) |> sum
# 8 rooms per dwelling?
(boston.rm .> 8) |> sum

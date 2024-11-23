import CSV as Csv
import CairoMakie as Cmk
import DataFrames as Dfs
import Distributions as Dsts
import Random as Rand
import Statistics as Stats

const F64 = Float64
const I64 = Int64
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

# elts of Matrix{T} are copies of v
function reshapeVec(v::Vec{T}, r::I64, c::I64, byRow::Bool)::Matrix{T} where T
    len::I64 = length(v)
    @assert (len == r*c)
    m::Matrix{T} = Matrix{T}(undef, r, c)
    stepBegin::I64 = 1
    stepSize::I64 = (byRow ? c : r) - 1
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
auto = Csv.read("./Auto.csv", Dfs.DataFrame)
first(auto, 2)

# In [74]
# workaround, still, better to use *.csv
# delimiters are spaces (multiple) or tabs
auto = Csv.read(
    IOBuffer(replace(read("./Auto.data"), UInt8('\t') => UInt8(' '))),
    Dfs.DataFrame, delim=" ", ignorerepeated=true,
    types=[F64, I64, F64, F64, F64, F64, I64, I64, Str])
first(auto, 2)

# In [74]
auto.horsepower # or
# auto[!, "horsepower"]

# In [76]
# unique(auto.horsepower)
show(stdout, "text/plain", unique(auto.horsepower))

# In [77]
auto = Csv.read("./Auto.csv", Dfs.DataFrame,
                types=[F64, I64, F64, F64, F64, F64, I64, I64, Str],
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

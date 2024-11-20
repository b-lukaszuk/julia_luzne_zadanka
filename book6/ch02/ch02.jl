import CairoMakie as Cmk
import Distributions as Dsts
import Random as Rand
import Statistics as Stats

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
function reshapeVec(v::Vec{T}, r::Int, c::Int, byRow::Bool)::Matrix{T} where T
    len::Int = length(x)
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

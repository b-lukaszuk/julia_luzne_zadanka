import CairoMakie as Cmk
import Distributions as Dsts
import Random as Rand
import Statistics as Stats

const Vec = Vector

# 2.3 Lab: Introduction to Python

## 2.3.2 Basic Commands
println("Fit a model with ", 11, " variables")
3+5
"hello" * " " * "world"
x = [3, 4, 5]
y = [4, 9, 7]
z = vcat(x, y) # creates a copy of x and y

## 2.3.3 Introduction to Numerical Python
x = [3, 4, 5]
y = [4, 9, 7]
x .+ y

x = [1 2; 3 4]
ndims(x)
typeof(x)

typeof([1 2; 3.0 4])
Matrix{Float64}([1 2; 3 4])
size(x)
sum(x)

x = collect(1:6)
x
x_reshaped = reshape(x, (2, 3)) # colum major, not row major
# currently v1.10.5, no change to row major possible
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

x_reshaped[1, 1]
x_reshaped[2, 3]

my_tuple = (3, 4, 5)
my_tuple[1] = 2 # error, tuples cannot be changed after created

sqrt.(x)
x .^ 2
x .^ 0.5 # same as sqrt.(x)

# random numbers from N(0, 1)
x = Rand.rand(Dsts.Normal(), 50)
y = x .+ Rand.rand(Dsts.Normal(50, 1), 50)
Stats.cor(x, y)

# diffrent random nums
Rand.rand(Dsts.Normal(0, 5), 2)
Rand.rand(Dsts.Normal(0, 5), 2)

# the same random nums
Rand.seed!(1303)
Rand.rand(Dsts.Normal(0, 5), 2)
Rand.seed!(1303)
Rand.rand(Dsts.Normal(0, 5), 2)

Rand.seed!(3)
y = Rand.rand(Dsts.Normal(), 10)
# Stats.var(y) == Stats.var(y, corrected=true)
Stats.var(y), Stats.std(y), Stats.mean(y)

# matrix
Rand.seed!(3)
y = Rand.rand(Dsts.Normal(), (10, 3))
Stats.mean(y)
Stats.mean(y, dims=1) # col-major first
Stats.mean(y, dims=2) # row-major second

# 2.3.4 Graphics
x = Rand.rand(Dsts.Normal(), 100)
y = Rand.rand(Dsts.Normal(), 100)
fig = Cmk.Figure();
Cmk.scatter(fig[1, 2], x, y,
            marker=:circle,
            axis=(;title="Plot of X vs Y",
                  xlabel="this is the x-axis",
                  ylabel="this is the y-axis"));
Cmk.scatter(fig[2, 3], x, y, marker=:cross,
            axis=(;title="Plot of X vs Y",
                  xlabel="this is the x-axis",
                  ylabel="this is the y-axis")
            );
fig

#Cmk.save("figure.png", fig)
#Cmk.save("figure.pdf", fig)

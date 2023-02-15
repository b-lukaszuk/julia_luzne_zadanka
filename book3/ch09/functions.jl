import HypothesisTests as ht
import MultipleTesting as mt
import Pingouin as pg

function get_avg(vals::Vector{<:Number})::Float64
    return sum(vals) / length(vals)
end

function get_sd(vals::Vector{<:Number})::Float64
    avg::Float64 = get_avg(vals)
    diffs_squared::Vector{<:Float64} = [(v - avg)^2 for v in vals]
    return sqrt(sum(diffs_squared) / (length(vals) - 1))
end

function are_eql_vars(vals1::Vector{<:Number}, vals2::Vector{<:Number}; alpha::Float64=0.05)::Bool
    return ht.pvalue(ht.LeveneTest(vals1, vals2)) >= alpha
end

function are_all_norm_distributed(vals::Vector{<:Number}...; alpha::Float64=0.05)::Bool
    p_val::Float64 = 0
    for v in vals
        p_val = pg.normality(v).pval[1]
        if (p_val < alpha)
            return false
        end
    end
    return true
end

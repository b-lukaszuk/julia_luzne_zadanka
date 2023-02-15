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
    p_val::Float64 = 999.0
    for v in vals
        p_val = pg.normality(v).pval[1]
        if (p_val < alpha)
            return false
        end
    end
    return true
end

function compare2grs_get_p_val(vals1::Vector{<:Number}, vals2::Vector{<:Number})::Float64
    eq_vars::Bool = are_eql_vars(vals1, vals2)
    norm_dists::Bool = are_all_norm_distributed(vals1, vals2)
    if !norm_dists
        return ht.pvalue(ht.MannWhitneyUTest(vals1, vals2))
    elseif eq_vars
        return ht.pvalue(ht.EqualVarianceTTest(vals1, vals2))
    else
        return ht.pvalue(ht.UnequalVarianceTTest(vals1, vals2))
    end
end

function split_by_group(values::Vector{<:Number}, groups::Vector{String})::Dict{String,Vector{<:Number}}
    gr_names::Vector{String} = unique(groups)
    result::Dict{String,Vector{<:Number}} = Dict()
    for gr in gr_names
        result[gr] = values[findall(x -> x == gr, groups)]
    end
    return result
end

# runs unpaired tests
function run_pairwise_compars_get_p_vals(vals::Vector{<:Number}, grs::Vector{<:String},
    adjust::Bool=true, adjustment_mt=mt.BenjaminiHochberg
)::Dict{String,Float64}
    grouped::Dict{String,Vector{<:Number}} = split_by_group(vals, grs)
    groups::Vector{String} = collect(keys(grouped))
    comparisons::Vector{String} = []
    p_values::Vector{Float64} = []
    for i in eachindex(groups)
        for j in (i+1):length(groups)
            gi, gj = groups[i], groups[j]
            push!(comparisons, "$(gi) vs. $(gj)")
            push!(p_values, compare2grs_get_p_val(grouped[gi], grouped[gj]))
        end
    end
    if adjust
        p_values = mt.adjust(p_values, adjustment_mt())
    end
    return Dict(k => v for (k, v) in zip(comparisons, p_values))
end

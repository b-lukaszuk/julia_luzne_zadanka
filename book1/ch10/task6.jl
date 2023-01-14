### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 01906f90-8d1f-11ed-3a90-c99790f1daed
md"""# Task 6

## Original exercise number

Exercise 10-12

## Description

Two words “interlock” if taking alternating letters from each forms a new
word. For example, “shoe” and “cold” interlock to form “schooled”.

Credit: This exercise is inspired by an example at http://puzzlers.org.

### Part 1

Write a program that finds all pairs of words that interlock.

#### TIP

Don’t enumerate all pairs!

### Part 2

Can you find any words that are three-way interlocked; that is, every third
letter forms a word, starting from the first, second or third?
"""

# ╔═╡ 24230db1-da11-41cf-ae71-d66d4ef30db8
md"""## Solution"""

# ╔═╡ aec327c7-4bc5-4045-bb63-61129b53baec
md"""NO GUARANTEE THAT THE SOLUTION WILL WORK OR WORKS CORRECTLY! USE IT AT
YOUR OWN RISK!"""

# ╔═╡ 9b5a13b3-11fe-4d33-998b-e1f1a65f3316
md"""### Functions"""

# ╔═╡ 568282e1-c38c-449c-8d0b-13199f4d63da
function get_lines_from_file(path::String = "./words/words.txt"; how_many::Int = 1000)::Vector{String}
  lines::Vector{String} = []
  open(path) do file
      for (i, line) in enumerate(eachline(file))
          if i > how_many
            break
          end
          push!(lines, line)
      end
  end
  return lines
end

# ╔═╡ 80b27527-9b72-4e78-838c-d6e791469cb4
function vect_of_words_to_dict(words::Vector{String})::Dict{String, Int}
    result::Dict{String, Int} = Dict()
    for word in words
        result[word] = 1
    end
    return result
end

# ╔═╡ 6b767e85-5a27-46b1-bb09-17aacc330f4b
function interlock_words(word1::String, word2::String)::String
    return join(["$a$b" for (a, b) in zip(split(word1, ""), split(word2, ""))])
end

# ╔═╡ bf7d3a76-fb18-44e7-b398-efe5d49e8017
function get_interlocked_pairs(words::Vector{String})::Dict{String, Tuple{String, String}}
    words_dict::Dict{String, Int} = vect_of_words_to_dict(words)
    result::Dict{String, Tuple{String, String}} = Dict()
    for i in eachindex(words)
        for j in i+1:length(words)
            if length(words[i]) != length(words[j])
                continue
            end
            tmp1 = interlock_words(words[i], words[j])
            tmp2 = interlock_words(words[j], words[i])
            if haskey(words_dict, tmp1)
                result[tmp1] = (words[i], words[j])
            elseif haskey(words_dict, tmp2)
                result[tmp2] = (words[j], words[i])
            end
        end
    end
    return result
end

# ╔═╡ 768a5518-061f-4bd6-8771-2dadfa8cda40
md"""## Testing"""

# ╔═╡ 65d0842f-75d3-4b5f-89b5-74f3d32d09fe
get_interlocked_pairs(["shoe", "cold", "schooled"])

# ╔═╡ 98413374-18f6-4610-a3d7-9614d9d12edc
begin
    # the file contains 1 lowercase word per line
    words::Vector{String} = get_lines_from_file(how_many=7000)
    # the following line (or this code cell) executes in about 15 secs on my laptop
    rev_words = get_interlocked_pairs(words)
end

# ╔═╡ 4ddc832d-3da7-42ef-8ffd-a485040e86be
md"""## Conclusions

Since I expected that the task is computationally expensive I limited myself to
7000 words. Still, it took about 15 secs to execute the code in the cell above.

The result seem to be valid:
- [aahs](https://en.wiktionary.org/wiki/aahs)
- [baas](https://dictionary.cambridge.org/dictionary/dutch-english/baas)

Since finding the three way interlocked word seems to be equally or more
computationally expensive then I will not do Part 2 of the Task 6"""

# ╔═╡ Cell order:
# ╟─01906f90-8d1f-11ed-3a90-c99790f1daed
# ╟─24230db1-da11-41cf-ae71-d66d4ef30db8
# ╟─aec327c7-4bc5-4045-bb63-61129b53baec
# ╟─9b5a13b3-11fe-4d33-998b-e1f1a65f3316
# ╠═568282e1-c38c-449c-8d0b-13199f4d63da
# ╠═80b27527-9b72-4e78-838c-d6e791469cb4
# ╠═6b767e85-5a27-46b1-bb09-17aacc330f4b
# ╠═bf7d3a76-fb18-44e7-b398-efe5d49e8017
# ╟─768a5518-061f-4bd6-8771-2dadfa8cda40
# ╠═65d0842f-75d3-4b5f-89b5-74f3d32d09fe
# ╠═98413374-18f6-4610-a3d7-9614d9d12edc
# ╟─4ddc832d-3da7-42ef-8ffd-a485040e86be

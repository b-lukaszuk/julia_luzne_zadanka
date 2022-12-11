### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 6a76de26-e15f-4044-b1f7-e705fd5caa9e
using PlutoUI

# ╔═╡ c31f4a72-7948-11ed-20e0-e9f801b99c2a
md"""# Task 3

## Title

Multiple Word Palindromes

(Part 1, Exercise 73 from the book)

## Description

Write a program that checks if a string is a [palindrome](https://en.wikipedia.org/wiki/Palindrome). The program should ignore spaces and interpunction characters. It should also treat upper- and lowercase letters as equivalent, e.g.

$(html"<blockquote>
go dog</br>
Flee to me remote elf</br>
Some men interpret nine memos.
</blockquote>")


Are all multiple word palindromes.
"""

# ╔═╡ c3ca7b8c-bbfc-4605-b7c2-d5e13a66660b
md"""## Solution
NO GUARANTEE IT WILL WORK OR WORK CORRECTLY! USE IT AT YOUR OWN RISK!
"""

# ╔═╡ 90f4a016-cc7b-46f5-8dd0-5af592441173
function is_palindrome(word::String)::Bool
	cleaned_word::String = lowercase(word) |> x -> replace(x, r"[^a-z]" => "")
	cleaned_word == cleaned_word[end:-1:1]
end

# ╔═╡ 9c664fd7-c4f6-4222-88cf-95ca9941b4c4
test_words::Array{String} = ["go dog", "just a word", "Flee to me remote elf",
	"Some men interpret nine memos", "coconut", "coco", "cococ"]

# ╔═╡ cd477b3e-f0f3-417d-a96f-ba109b0e598e
with_terminal() do
	for tested_word in test_words
		println(repeat("-", 5))
		println("tested phrase: '$tested_word'")
		println("is palindrome? $(is_palindrome(tested_word))")
	end
end

# ╔═╡ Cell order:
# ╟─c31f4a72-7948-11ed-20e0-e9f801b99c2a
# ╟─c3ca7b8c-bbfc-4605-b7c2-d5e13a66660b
# ╠═6a76de26-e15f-4044-b1f7-e705fd5caa9e
# ╠═90f4a016-cc7b-46f5-8dd0-5af592441173
# ╠═9c664fd7-c4f6-4222-88cf-95ca9941b4c4
# ╠═cd477b3e-f0f3-417d-a96f-ba109b0e598e

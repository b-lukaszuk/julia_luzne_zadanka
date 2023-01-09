# Chapter 10. Arrays.

[Chapter 10, and its exercises](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html#_exercises_12) from the book.

---

# Table of contents

1. [Task 1](#task-1)

---

# Task 1

[Go to: Table of contents](#table-of-contents)

## Original exercise number

Exercise 10-1

## Description

Write a function called `nestedsum` that takes an array of arrays of integers and adds up the elements from all of the nested arrays. For example:

<pre>
julia> t = [[1, 2], [3], [4, 5, 6]];

julia> nestedsum(t)
21
</pre>

## Exemplary usage

Created with [Pluto.jl](https://plutojl.org/), running notebook

``` julia
using Pluto
Pluto.run()
```


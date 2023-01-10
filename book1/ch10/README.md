# Chapter 10. Arrays.

[Chapter 10, and its exercises](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html#_exercises_12) from the book.

---

# Table of contents

1. [Task 1](#task-1)
2. [Task 2](#task-2)
3. [Task 3](#task-3)

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

# Task 2

[Go to: Table of contents](#table-of-contents)

## Original exercise number

Exercise 10-5

## Description

Write a function called `issort` that takes an array as a parameter and returns `true` if the array is sorted in ascending order and `false` otherwise. For example:

<pre>
julia> issort([1, 2, 2])
true
julia> issort(['b', 'a'])
false
</pre>

## Exemplary usage

Created with [Pluto.jl](https://plutojl.org/), running notebook

``` julia
using Pluto
Pluto.run()
```

# Task 3

[Go to: Table of contents](#table-of-contents)

## Original exercise number

Exercise 10-8

## Description

This exercise pertains to the so-called Birthday Paradox, which you can read about at https://en.wikipedia.org/wiki/Birthday_paradox.

If there are 23 students in your class, what are the chances that two of you have the same birthday? You can estimate this probability by generating random samples of 23 birthdays and checking for matches.

### TIP

You can generate random birthdays with rand(1:365).

## Exemplary usage

Created with [Pluto.jl](https://plutojl.org/), running notebook

``` julia
using Pluto
Pluto.run()
```

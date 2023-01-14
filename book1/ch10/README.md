# Chapter 10. Arrays.

[Chapter 10, and its exercises](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html#_exercises_12) from the book.

---

# Table of contents

1. [Task 1](#task-1)
2. [Task 2](#task-2)
3. [Task 3](#task-3)
4. [Task 4](#task-4)
5. [Task 5](#task-5)
6. [Task 6](#task-6)

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

# Task 4

[Go to: Table of contents](#table-of-contents)

## Original exercise number

Exercise 10-9

## Description

Write a function that reads the file `words.txt` and builds an array with one element per word. Write two versions of this function, one using `push!` and the other using the idiom `t = [t..., x]`. Which one takes longer to run? Why?

## My notes

[words.txt](https://github.com/BenLauwens/ThinkJulia.jl/blob/master/data/words.txt) from Ben Lauwens GitHub (here I will not inclede it here, in my repo).

## Exemplary usage

Created with [Pluto.jl](https://plutojl.org/), running notebook

``` julia
using Pluto
Pluto.run()
```

# Task 5

[Go to: Table of contents](#table-of-contents)

## Original exercise number

Exercise 10-11

## Description

Two words are a “reverse pair” if each is the reverse of the other. Write a program reversepairs that finds all the reverse pairs in the word array.

## My notes

[words.txt](https://github.com/BenLauwens/ThinkJulia.jl/blob/master/data/words.txt) from Ben Lauwens GitHub (here I will not inclede it here, in my repo).

## Exemplary usage

Created with [Pluto.jl](https://plutojl.org/), running notebook

``` julia
using Pluto
Pluto.run()
```

# Task 6

[Go to: Table of contents](#table-of-contents)

## Original exercise number

Exercise 10-12

## Description

Two words “interlock” if taking alternating letters from each forms a new word. For example, “shoe” and “cold” interlock to form “schooled”.

Credit: This exercise is inspired by an example at http://puzzlers.org.

### Part 1

Write a program that finds all pairs of words that interlock.

#### TIP

Don’t enumerate all pairs!

### Part 2

Can you find any words that are three-way interlocked; that is, every third letter forms a word, starting from the first, second or third?

## My notes

[words.txt](https://github.com/BenLauwens/ThinkJulia.jl/blob/master/data/words.txt) from Ben Lauwens GitHub (here I will not inclede it here, in my repo).

## Exemplary usage

Created with [Pluto.jl](https://plutojl.org/), running notebook

``` julia
using Pluto
Pluto.run()
```


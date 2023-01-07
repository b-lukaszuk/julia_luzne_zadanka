# Chapter 9. Case Study: Word Play.

[Chapter 9, and its exercises](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html#chap09) from the book.

[words.txt](https://github.com/BenLauwens/ThinkJulia.jl/blob/master/data/words.txt) from Ben Lauwens GitHub (here I will not inclede it here).

---

# Table of contents

1. [Task 1](#task-1)
2. [Task 2](#task-2)
3. [Task 3](#task-3)
4. [Task 4](#task-4)
5. [Task 5](#task-5)

---

# Task 1

[Go to: Table of contents](#table-of-contents)

## Original exercise number

Exercise 9-1

## Description

Write a program that reads words.txt and prints only the words with more than 20 characters (not counting whitespace).

## Exemplary usage

Created with [Pluto.jl](https://plutojl.org/), running notebook

``` julia
using Pluto
Pluto.run()
```

# Task 2

[Go to: Table of contents](#table-of-contents)

## Original exercise number

Exercise 9-2

## Description

Write a function called `hasno_e` that returns `true` if the given word doesn’t have the letter `e` in it.

Modify your program from the previous section to print only the words that have no `e` and compute the percentage of the words in the list that have no `e`.

## Exemplary usage

Created with [Pluto.jl](https://plutojl.org/), running notebook

``` julia
using Pluto
Pluto.run()
```

# Task 3

[Go to: Table of contents](#table-of-contents)

## Original exercise number

Exercise 9-3

## Description

Write a function named `avoids` that takes a word and a string of forbidden letters, and that returns true if the word doesn’t use any of the forbidden letters.

## Exemplary usage

Created with [Pluto.jl](https://plutojl.org/), running notebook

``` julia
using Pluto
Pluto.run()
```

# Task 4

[Go to: Table of contents](#table-of-contents)

## Original exercise number

Exercise 9-6

## Description

Write a function called `isabecedarian` that returns `true` if the letters in a word appear in alphabetical order (double letters are ok). How many abecedarian words are there?

## Exemplary usage

Created with [Pluto.jl](https://plutojl.org/), running notebook

``` julia
using Pluto
Pluto.run()
```

# Task 5

[Go to: Table of contents](#table-of-contents)

## Original exercise number

Exercise 9-7

## Description

This question is based on a Puzzler that was broadcast on the radio program Car Talk (https://www.cartalk.com/puzzler/browse):

Give me a word with three consecutive double letters. I’ll give you a couple of words that almost qualify, but don’t. For example, the word committee, c-o-m-m-i-t-t-e-e. It would be great except for the i that sneaks in there. Or Mississippi: M-i-s-s-i-s-s-i-p-p-i. If you could take out those i’s it would work. But there is a word that has three consecutive pairs of letters and to the best of my knowledge this may be the only word. Of course there are probably 500 more but I can only think of one. What is the word?

Write a program to find it.

## Exemplary usage

Created with [Pluto.jl](https://plutojl.org/), running notebook

``` julia
using Pluto
Pluto.run()
```


# Julia - first encounter {#sec:julia_first_encounter}

This book is not intended to be a comprehensive introduction to Julia programming. If you are looking for one try, e.g. [Think Julia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html).

Still, we need to cover some selected basics of the language in order to use it later. The rest of it we will catch 'on the fly'.
Without further ado let's get our hands dirty.

## Installation {#sec:julia_installation}

In order to use Julia we need to install it first. So, now is the time to go to [julialang.org](https://julialang.org/), click 'Download' and choose the version suitable for your machine's OS.

To check the installation open the [Terminal](https://en.wikipedia.org/wiki/Terminal_emulator) and type:

```bash
julia --version
```

At the time of writing this words I'm using:

```jl
s = """
VERSION
"""
sco(s)
```

For starters I recommend [Pluto.jl](https://github.com/fonsp/Pluto.jl) as a minimalist and user friendly code editor for Julia. Here, I paste the link to [YouTube video](https://www.youtube.com/watch?v=OOjKEgbt8AI) (copied from the Pluto.jl's web page) with instructions of how to install it. From now on you'll be able to use it to interactively to run some Julia code from this book. If you need it feel free to watch more videos about Pluto.jl.

## Running Pluto Notebook {#sec:julia_running_pluto_notebook}

Let's start to write some simple programs in Julia. You may follow along by running a Pluto.jl notebook.

As an example, here is how I run it on my laptop (OS: Linux Mint):

1. Open terminal/shell (shortcut: `Ctrl+Alt+T`)

2. Run Julia-REPL by typing

```bash
julia
```
3. Import Pluto.jl by typing

```julia-repl
julia> import Pluto
```

4. Wait until the last command executes, and then type

```julia-repl
julia> Pluto.run()
```

This will open a Pluto notebook in your default web browser. You can write some code now (like the one in the next sub-chapters). Have fun!

## Language Constructs {#sec:julia_language_constructs}

Let's start by looking at some language features, namely:

1. Variables
2. Functions
3. Decision making
4. Repetition

## Variables {#sec:julia_language_variables}

The way I see it a variable is a box to store some value.

Type

```jl
s = """
x = 1
"""
sc(s)
```

and press `Ctrl+Enter` to execute the cell and open a new cell below.

This creates a variable (box) named `x` (x is a label on the box) that contains the value `1`. The `=` operator assigns `1` (right side) to `x` (left side) [puts `1` into the box].

Now, in the cell below type and execute

```jl
s = """
x = 2
"""
sc(s)
```

You may see that Pluto disabled the cell above (the one with `x = 1`) and defined variable `x` in the new cell (to prevent you from accidentally overriding variable `x`).

Now, open a new cell, type and execute

```jl
s = """
y = 2.2
y = 3.3
"""
sc(s)
```

You should get the warning like:

> Multiple expressions in one cell.

> How would you like to fix it?

> Split this cell into 2 cells, or

> Wrap all code in a begin ... end block.

> ...

Click the 'begin .. end' hyperlink so that Pluto can fix it for you (again, Pluto tries to protect you from putting more than one logical piece of code into a cell which sometimes may cause problems). Lastly, you should get:

```jl
s = """
begin
	y = 2.2
	y = 3.3
end
"""
sc(s)
```

Here, you defined variable `y` with a value `2.2` and reassigned it right away to `3.3`. So the current value in the box is `3.3` (you can see it at the top of the cell or by typing y in the cell below and executing it).

Sometimes you may see variables written like that

```jl
s = """
z::Int = 4
"""
sc(s)
```

or

```jl
s = """
zz::Float64 = 4.4
"""
sc(s)
```

The `::Int` part informs Julia that you will be storing only [integers](https://en.wikipedia.org/wiki/Integer) (like: ..., -1, 0, 1, ...) in this box. Whereas by typing `::Float64` we declare to store only [floats](https://en.wikipedia.org/wiki/Floating-point_arithmetic) (like: ..., 1.1, 1.0, 0.0, 2.2, 3.14, ...) in that box.

### Optional type declaration {#sec:julia_optional_type_declaration}

**Note the difference.** If you use variable without type definition you can freely reassign values even of different types (*note: in the code below `#` and all the text to the right of it is a comment, the part that is ignored by a computer but read by a human*)

```jl
s = """
begin
	a = 1 # type is not declared
	a = 2.2 # can assign any other type
	# the "Hello" below is a string (a text in a form readable by Julia)
	a = "Hello"
end
"""
sc(s)
```

But you cannot assign a different type to variable than the one you declared (you must keep your promises).
Look at the code below.

This is OK

```jl
s = """
begin
	b::Int = 1 # type integer declared
	b = 2 # type integer delivered
end
"""
sc(s)
```

But this is not OK (it's wrong! it's wroooong!)

<pre>
begin
	c::Int = 1 # type integer declared
	c = 3.3 # broke the promise, float delivered, will produce error
end
</pre>

Now a question arises. Why would you want to use type declaration (like `::Int` or `Float64`) at all? Well, sometimes it makes more sense to use say integer  instead of string (we add `3` to `3` not `"three"` to `"three"`). So you would like a guarding angel that watches over you and protects you from evil (especially in large programs). Additionally declaring types can make your code run faster.

A few more points of notice.

### Meaningful variable names {#sec:julia_meaningful_variable_names}

**Name your variables well**. The variable names I used before are horrible (*mea culpa, mea culpa, mea maxima culpa*). We use named variables (like `x = 1`) instead of loose variables (you can type `1` alone in the Pluto's cell and execute it) to use them later.

You can use them later in time (reading and editing your code tomorrow or next month/year) or in space (using it 30 code cells below). If so, the names need to be memorable (actually just meaningful will do :P). So whenever possible use: `studentAge = 19`, `bookTitle = "Dune"` instead of `x = 19`, `y = "Dune"`.

You may want to check [Julia Docs](https://docs.julialang.org/en/v1/) for [allowed variable names](https://docs.julialang.org/en/v1/manual/variables/#man-allowed-variable-names) and their [stylistic conventions](https://docs.julialang.org/en/v1/manual/variables/#Stylistic-Conventions). Still, I prefer to use [camelCaseStyle](https://en.wikipedia.org/wiki/Camel_case) so this is what you gonna see here.

### Floats comparisons {#sec:julia_float_comparisons}

**Be careful with `=` sign**. In mathematics `=` means `equal to` and `≠` means `not equal to`. In programming `=` is usually an assignment operator.
If you want to compare for equality you should use `==` (for `equal to`) and (`!=` for `not equal to`), examples:

```jl
s = """
1 == 1
"""
sco(s)
```

---

```jl
s = """
2 == 1
"""
sco(s)
```
---

```jl
s = """
2.0 != 1.0
"""
sco(s)
```
---

```jl
s = """
1.0 != 1
"""
sco(s)
```
---

```jl
s = """
2 != 2
"""
sco(s)
```

Be careful though since comparing two floats is tricky, e.g.

```jl
s = """
(0.1 * 3) == 0.3
"""
sco(s)
```

It is `false` since float numbers cannot be represented exactly in binary (see [this StackOverflow's thread](https://stackoverflow.com/questions/8604196/why-0-1-3-0-3)). This is how `0.1 * 3` looks for computer


```jl
s = """
0.1 * 3
"""
sco(s)
```

The same caution applies to other comparison operators, like `>` (`is greater than`), `>=` (`is greater than or equal to`), `<` (`is less than`), `<=` (`is less than or equal to`)

### Other types {#sec:julia_other_types}

There are also other types (see [Julia Docs](https://docs.julialang.org/en/v1/manual/types/)) but we will use mostly those mentioned in this chapter, i.e.:

- [floats](https://en.wikipedia.org/wiki/Floating-point_arithmetic)
- [integers](https://en.wikipedia.org/wiki/Integer)
- [strings](https://en.wikipedia.org/wiki/String_(computer_science))
- [booleans](https://en.wikipedia.org/wiki/Boolean_data_type)


The briefly mentioned strings are denoted by `::String` and you type them with quotations (`"any text"`).

The last of the mentioned types is denoted as `::Bool` and can take only two values: `true` or `false` (see the results of the comparison operations above).

### Collections {#sec:julia_collections}

Not only do variables store single value but they can also store their collections. The collection type that we will discuss here is `Vector`.

```jl
s = """
myMathGrades::Vector{Float64} = [3.5, 3.0, 3.5, 2.0, 4.0, 5.0, 3.0]
"""
sco(s)
```

Here I declared a variable that stores my mock grades. The `{Float64}` part indicates that each element is of type `Float64`.
Just like with the variables declared before also here the type declaration is optional. I could declare the variable without `{Float64}` or `::Vector{Float64}` part.
The variable contains `jl length(myMathGrades)` grades in it, which you can check by typing `length(myMathGrades)` in a Pluto's cell.

You can retrieve a single element of the vector by typing `myMathGrades[i]` where `i` is some integer. E.g.

```jl
s = """
myMathGrades[3] # returns 3rd element
"""
sco(s)
```

---

```jl
s = """
myMathGrades[end] # returns last grade
# the above is equivalent to: myMathGrades[7]
"""
sco(s)
```

Or you can get a slice of the vector by typing

```jl
s = """
myMathGrades[2:3] # returns Vector with two grades (2nd and 3rd)
# the slicing is [inclusive:inclusive]
"""
sco(s)
```

Be careful though, if You type an none existing index like: `myMathGrades[-1]`, `myMathGrades[0]` or `myMathGrades[10]` you will get an error (e.g. `BoundsError: attempt to access 7-element Vector{Int64} at index [0]`).

So I guess you can think about a vector as a [rectangular cuboid](https://en.wikipedia.org/wiki/Cuboid#Rectangular_cuboid) box with drawers (smaller [cube](https://en.wikipedia.org/wiki/Cube) shaped boxes).

One last remark, You can change the elements that are in the vector like this.

```jl
s = """
myMathGrades[1] = 2.0
myMathGrades
"""
sco(s)
```

or like that

```jl
s = """
myMathGrades[2:3] = [5.0, 5.0]
myMathGrades
"""
sco(s)
```

Again, remember about proper indexing, and that what you put inside should be compatible with indexing on the left (`myMathGrades[2:3] = [2.0, 2.0, 2.0]` will produce an error).

OK, enough about the variables, we will learn more about them as we discuss other topics throughout the book.

## Functions {#sec:julia_language_functions}

Functions are doers, i.e encapsulated pieces of code that do things for you. Optimally, a function should be single minded, i.e. doing one thing only and doing it well. Moreover since they do stuff they names should contain [verbs](https://en.wikipedia.org/wiki/Verb) (whereas variables' names should be composed of [nouns](https://en.wikipedia.org/wiki/Noun)).

We already met one Julia function (see @sec:julia_is_simple), namely `println`. As the name suggests it prints something (like a text) to the [standard output](https://en.wikipedia.org/wiki/Standard_streams#Standard_output_(stdout)). This is one of many Julia build in functions (for more information see [Julia Docs](https://docs.julialang.org/en/v1/)).

### Mathematical functions {#sec:mathematical_functions}

But we can also define some functions on our own:

```jl
s = """
function getRectangleArea(lenSideA::Number, lenSideB::Number)::Number
	return lenSideA * lenSideB
end
"""
sco(s)
```

Here I declared Julia's version of a [mathematical function](https://en.wikipedia.org/wiki/Function_(mathematics)). It is called `getRectangleArea` and it calculates (surprise, surprise, the [area of a rectangle](https://en.wikipedia.org/wiki/Rectangle#Formulae)). To do that I used a keyword `function`. The `function` keyword is followed by the name of the function. Inside the parenthesis are arguments of the function. The function accepts two arguments `lenSideA` (length of one side) and `lenSideB` (length of the other side) and calculates the area of a rectangle. Both `lenSideA` and `lenSideB` are of type `Number` (any numeric type in Julia, it encompasses `Int` and `Float64` that we encountered before). The ending of the first line, `)::Number`, signifies that the function will return a value of type `Number`. The stuff that function returns is preceded by the `return` keyword. The function ends with the `end` keyword.

Note, that you did not need to embed the function in the `begin ... end` tags, since this definition is a single logical piece of code then Pluto is OK with that. Time to run our function and see how it works.

```jl
s = """
getRectangleArea(3, 4)
"""
sco(s)
```

Hmm, and how about the [area of a square](https://en.wikipedia.org/wiki/Square#Perimeter_and_area). You got it.

```jl
s = """
function getSquareArea(lenSideA::Number)::Number
	return getRectangleArea(lenSideA, lenSideA)
end
"""
sco(s)
```

Notice that I reused previously defined `getRectangleArea` (so, functions can use other functions). Let's see how it works.

```jl
s = """
getSquareArea(3)
"""
sco(s)
```

Appears to be working just fine.

### Functions with generics {#sec:functions_with_generics}

Now, let's say I want a function `getFirstElt` that accepts a vector and returns its first element (vectors and indexing were briefly discussed in @sec:julia_collections).

```jl
s = """
function getFirstElt(vect::Vector{Int})::Int
	return vect[1]
end
"""
sc(s)
```

It looks OK (test it in Pluto.jl, e.g. `getFirstElt([1, 2, 3]`). However, the problem is it works only with integers (or maybe not, test it out).
How to make it work with any type, like `getFirstElt(["Eve", "Tom", "Alex"])` or `getFirstElt([1.1, 2.2, 3.3])`?

One way is to declare separate versions of the functions for different type of inputs, i.e.

```jl
s = """
begin
	function getFirstElt(vect::Vector{Int})::Int
		return vect[1]
	end

	function getFirstElt(vect::Vector{Float64})::Float64
		return vect[1]
	end

	function getFirstElt(vect::Vector{String})::String
		return vect[1]
	end
end
"""
sco(s)
```

But that is too much of typing (I retyped a few times virtually the same code). The other way is to use no type declarations.

```jl
s = """
function getFirstEltVer2(vect)
	return vect[1]
end
"""
sc(s)
```

Yet another way is to use so called generic types, like

```jl
s = """
function getFirstEltVer3(vect::Vector{T})::T where T
	return vect[1]
end
"""
sc(s)
```

Here we said that the vector is composed of elements of type `T` (`Vector{T}`) and that the function will return type `T` (see `)::T`). At end we said that this `T` is a custom type (not a Julia build in type) and it can be any type at all (see `where T`). Replace `T` with any other letter of the alphabet (`A`, `D`, or whatever) and check if the code still works (it should). One last remark, it is customary to write generic types with a single capital letter. Notice that in comparison to the function with no type declarations (`getFirstEltVer2`) the version with generics (`getFirstEltVer3`) is more informative. You know that the function accepts vector of some elements, and you know that it returns some value of the same type as the type of the elements that build that vector.

Note that the last function we wrote for fun (it was fun for me, how about you?). In reality Julia already got `first`, a function with a similar functionality (see [this part of Julia Docs](https://docs.julialang.org/en/v1/base/collections/#Base.first)).

### Functions modifying arguments {#sec:functions_modifying_arguments}

Previously (see @sec:julia_collections) we said that you can change elements of the vector. So, let's try to write a function that changes the first element.

```jl
s = """
function replaceFirstElt!(vect::Vector{T}, newElt:: T) where T
	vect[1] = newElt
	return nothing
end
"""
sc(s)
```

First thing to notice, the functions name ends with `!` (exclamation mark). This is one of the Julia's conventions. In general, you should try to write a function that does not modify its arguments (it often causes errors in big programs). However, such modifications are sometimes useful, therefore Julia allows you to do so, but you should always be explicit about it. That is why it is customary to end the name of the function with `!` (exclamation mark draws attention). Notice that here `T` can still be any type, but we require `newElt` to be of the same type as the elements in `vect`. Additionally, we also signal the modification of the function's arguments by writing `replaceFirstElt!(vect::Vector{T}, newElt::T)` instead of `replaceFirstElt!(vect::Vector{T}, newElt::T)::T` (we removed the declaration of the returned type by the function, i.e. `)::T`). Additionally, although not required, we wrote `return nothing` to be even more open that the function does not return a value. Ok, let's see it in action.

First `getFirstEltVer3`:

```jl
s = """
x = [1, 2, 3]
y = getFirstEltVer3(x)
(x, y)
"""
sco(s)
```

and now `replaceFirstElt!`.

```jl
s = """
x = [1, 2, 3]
y = replaceFirstElt!(x, 4)
(x, y)
"""
sco(s)
```

The `(x, y)` returns `Tuple` and it is there is to show both `x` and `y` in one line. You may think of `Tuple` as something similar to `Vector` but written with parenthesis `()` instead of square brackets `[]`. Additionally, you cannot modify elements of a tuple after it was created (so, if you got `z = (1, 2, 3)`, then `z[2]`) will work just OK, but `z[2] = 8` will produce an error).

### Side Effects vs Returned Values {#sec:side_effects_vs_returned_values}

Notice that so far we encountered two types of Julia functions:

- those that are used for their side effects (like `println`)
- those that return some results (like `getRectangleArea`)

The difference between the two may not be that obvious while using Pluto (although). To make it more obvious let's put them to the script like so:

<pre>
# file: sideEffsVsReturnVals.jl

println("Hello World!")

# you need to define function before you call it
function getRectangleArea(lenSideA::Number, lenSideB::Number)::Number
    return lenSideA * lenSideB
end

getRectangleArea(3, 2) # calling the function
</pre>

After running the code from terminal:

```bash
cd folder_with_the_sideEffsVsReturnVals.jl/
julia sideEffsVsReturnVals.jl
```

I got printed on the screen:

<pre>
Hello World!
</pre>

That's it. I got only one line of output, the rectangle area seems to be missing. We must remember that a computer does only what we tell it to do, nothing more, nothing less.
Here we said:

- print "Hello World!" to the screen (actually [standard output](https://en.wikipedia.org/wiki/Standard_streams#Standard_output_(stdout)))
- calculate and return the area of the rectangle but we did nothing with it

It the second case the result went into the void (If a tree falls in a forest and no one's there to see it. Did it really made sound?)

If we want to print both information on the screen we should modify our script to look like:

<pre>
# file: sideEffsVsReturnVals.jl

# you need to define function before you call it
function getRectangleArea(lenSideA::Number, lenSideB::Number)::Number
    return lenSideA * lenSideB
end

println("Hello World!")
# println takes 0 or more arguments (separated by commas)
# if necessary arguments are converted to strings and printed
println("Rectangle area = ", getRectangleArea(3, 2), "[cm^2]")
</pre>

Now You get:

<pre>
Hello World!
Rectangle area = 6 [cm^2]
</pre>

By default Pluto (v0.19.22) prints the return value at the top of the cell with the code and prints stuff in a mini terminal in the cell below.

More information about functions can be found, e.g. [in this section of Julia Docs](https://docs.julialang.org/en/v1/manual/functions/).

If You ever encounter a build in function that you don't know, you may always search [the docs](https://docs.julialang.org/en/v1/) (search box is on top left corner of the page).

## Decision Making {#sec:julia_language_decision_making}

In everyday life people have to make decisions and so do computer programs. This is the job for `if ... elseif ... else` constructs.

### If ..., or Else ... {#sec:julia_language_if_else}

To demonstrate decision making in action let's say I want to write a function that accepts an integer as an argument and returns a its textual representation. Here we go.

```jl
s = """
function int2string(num::Int)::String
	if num == 0
		return "zero"
	elseif num == 1
		return "one"
	elseif num == 2
		return "two"
	else
		return "three or above"
	end
end

(int2string(0), int2string(2), int2string(5)) # a tuple with results
"""
sco(s)
```

The general structure of the construct goes like this:

<pre>
# pseudocode, don't run this snippet
if (condition_that_returns_Bool)
	what_to_do
elseif (another_condition_that_returns_Bool)
	what_to_do
elseif (another condition that returns Bool)
	what_to_do
else
	what_to_do
end
</pre>

As mentioned in @sec:julia_other_types `Bool` type can have two values `true` or `false`. The code inside `if`/`elseif` clause runs only when the condition is `true`.
You can have any number of `elseif` clauses inside. If none of the previous claues matches (they are bring `false`) the code in `else` block is executed.
Only `if` and `end` keywords are obligatory, the rest is not, so you may use

<pre>
# pseudocode, don't run this snippet
if (condition_that_returns_Bool)
	what_to_do
end
</pre>

or

<pre>
# pseudocode, don't run this snippet
if (condition_that_returns_Bool)
	what_to_do
else
	what_to_do
end
</pre>

or

<pre>
# pseudocode, don't run this snippet
if (condition_that_returns_Bool)
	what_to_do
elseif (condition_that_returns_Bool)
	what_to_do
else
	what_to_do
end
</pre>

or ..., nevermind, I think You got the point.

Another example of a function using `if/elseif/else` construct to remember it better.

```jl
s = """
function getMin(vect::Vector{Int}, isSortedAsc::Bool)::Int
	if isSortedAsc
		return vect[1]
	else
		sortedVect::Vector{Int} = sort(vect)
		return sortedVect[1]
	end
end

x = [1, 2, 3, 4]
y = [3, 4, 1, 2]

(getMin(x, true), getMin(y, false))
"""
sco(s)
```

Here I wrote a function that finds minimal value in a vector of integers. If the vector is sorted in the ascending order it returns the first element.
If it is not, it sorts the vector using build in [sort](https://docs.julialang.org/en/v1/base/sort/#Base.sort) function and then returns its first element.
Note that the `else` block contains two lines of code (it could contain more if necessary, and so could `if` block). I did this for demonstative purposes.
Alternatively instead those two lines one could write `return sort(vect)[1]` and it would work just fine.

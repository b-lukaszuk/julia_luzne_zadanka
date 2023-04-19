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

You may want to check [Julia Docs](https://docs.julialang.org/en/v1/) for [allowed variable names](https://docs.julialang.org/en/v1/manual/variables/#man-allowed-variable-names) and their [stylistic conventions](https://docs.julialang.org/en/v1/manual/variables/#Stylistic-Conventions). I prefer to use [camelCaseStyle](https://en.wikipedia.org/wiki/Camel_case) so this is what you gonna see here.

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
myChemistryGrades::Vector{Float64} = [3.5, 3.0, 3.5, 2.0, 4.0, 5.0, 3.0]
"""
sco(s)
```

Here I declared a variable that stores my mock grades. The `{Float64}` part indicates that each element is of type `Float64`.
Just like with the variables declared before also here the type declaration is optional. I could declare the variable without `{Float64}` or `::Vector{Float64}` part.
The variable contains `jl length(myChemistryGrades)` grades in it, which you can check by typing `length(myChemistryGrades)` in a Pluto's cell.

You can retrieve a single element of the vector by typing `myChemistryGrades[i]` where `i` is some integer. E.g.

```jl
s = """
myChemistryGrades[3] # returns 3rd element
"""
sco(s)
```

---

```jl
s = """
myChemistryGrades[end] # returns last grade
# the above is equivalent to: myChemistryGrades[7]
"""
sco(s)
```

Or you can get a slice of the vector by typing

```jl
s = """
myChemistryGrades[2:3] # returns Vector with two grades (2nd and 3rd)
# the slicing is [inclusive:inclusive]
"""
sco(s)
```

Be careful though, if You type an none existing index like: `myChemistryGrades[-1]`, `myChemistryGrades[0]`, `myChemistryGrades[10]` you will get an error.

OK, enough about the variables, we will learn more about them as we discuss other topics throughout the book.

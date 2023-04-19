# Julia - first encounter {#sec:julia_first_encounter}

This book is not intended to be a comprehensive introduction to Julia programming. If you are looking for one try, e.g. [Think Julia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html).

Still, we need to cover some basics of the language in order to use it later.
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

For starters I recommend [Pluto.jl](https://github.com/fonsp/Pluto.jl) as a minimalist and user friendly code editor for Julia. Here, I paste the link to [YouTube video](https://www.youtube.com/watch?v=OOjKEgbt8AI) (copied from the Pluto.jl's web page) with instructions of how to install it. From now on you'll be able to use it to interactively to run some Julia code from this book.

## Running Pluto Notebook {#sec:julia_running_pluto_notebook}

Let's start to write some simple programs in Julia. You may follow allong by running a Pluto.jl notebook.

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

This will open a Pluto notebook in your default web browser. You can write some code now (like the one in the next subchapters). Have fun!

## Language Constructs {#sec:julia_language_constructs}

Let's start by looking at some language features, namely:

1. Variables
2. Functions
3. Decision making
4. Repetition

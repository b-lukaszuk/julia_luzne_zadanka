# Julia - first encounter {#sec:julia_first_encounter}

This book is not intended to be a comprehensive introduction to Julia programming. If you are looking for one try, e.g. [Think Julia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html).

Still, we need to cover some basics of the language in order to use it later.
Without further ado let's get our hands dirty.

## Installation

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

For starters I recommend [Pluto.jl](https://github.com/fonsp/Pluto.jl) as a minimalist and user friendly code editor for Julia. Here, I paste the link to [YouTube video](https://www.youtube.com/watch?v=OOjKEgbt8AI) (copied from the page above) with instructions of how to install it. From now on you'll be able to use it to interactively run some Julia code from this book.

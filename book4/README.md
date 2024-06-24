# Description

Selected bits/tasks from ["Think Bayes"](https://allendowney.github.io/ThinkBayes2/index.html) by Allen B. Downey used for educational purposes.

[The book's GitHub repository](https://github.com/AllenDowney/ThinkBayes2/).

For training I will solve them with [Julia](https://julialang.org/), despite the fact that the code examples from the book are written in [Python](https://www.python.org/).

Probably I will use [Pluto.jl](https://plutojl.org/) or [Jupyter](https://jupyter.org/) notebooks.

# Usage example

## Pluto.jl notebook

``` bash
ls
# output: README.md ch01.jl
head -2 ch01.jl
# output: ### A Pluto.jl notebook ###
# output: # v0.19.19
julia
```

<pre>
julia> using Pluto
julia> Pluto.run() # opens notebook in a default browser
</pre>

## Jupyter notebook

``` bash
ls
# output: README.md ch01.ipynb
jupyter notebook # opens notebook in a default browser
```

## Pure julia file

```bash
julia ch01.jl
```

Or even better, open the file in interactive mode (with REPL) in VSCode or Emacs.

# Additional info

**Zawartość niniejszego katalogu może być nieprawidłowa, błędna czy szkodliwa. Używaj na własne ryzyko.**

**The content of this folder may be incorrect, erroneous and/or harmful. Use it at Your own risk.**

![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/logo/dark/fmijl_logo_640_320.png?raw=true "FMI.jl Logo")

# Structure

Examples can be found in the [examples folder in the examples branch](https://github.com/ThummeTo/FMI.jl/tree/examples/examples) or the [examples section of the documentation](https://thummeto.github.io/FMI.jl/dev/examples/overview/). All examples are available as Julia-Script (*.jl*), Jupyter-Notebook (*.ipynb*) and Markdown (*.md*).


# Getting Started

## Install Jupyter in Visual Studio Code
The Jupyter Notebooks extension for Visual Studio Code can be [here](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter).

## Add Julia Kernel to Jupyter
To run Julia as kernel in a jupyter notebook it is necessary to add the **IJulia** package.

1. Start the Julia REPL.

    ```
    julia
    ```

2. Select your environment.
    ```julia
    using Pkg
    Pkg.activate("Your Env")
    ```
 
3. Add and build the IJulia package by typing inside the Julia REPL.

    ```julia
    using Pkg
    Pkg.add("IJulia")
    Pkg.build("IJulia")
    ```

4. Now you should be able to choose a Julia kernel in a Jupyter notebook.


More information can be found [here](https://towardsdatascience.com/how-to-best-use-julia-with-jupyter-82678a482677).

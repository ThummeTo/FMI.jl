# Examples
In the  `examples` folder of this branch various examples of applications of the FMI.jl library can be found. A Julia file is accompanied to a Jupyter Notebook and a Markdown file. The Jupyter Notebook contains a detailed explanation of the individual steps from the Julia file and resembles a tutorial. The Markdown file contains the whole content of the Jupyter Notebook. This file is for documentation and users who do not have Jupyter installed. In contrast, the Julia file contains only the pure code with comments without the detailed explanations.


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

![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/logo/fmijl_logo_640_320.png "FMI.jl Logo")
# FMI.jl

## What is FMI.jl?
FMI.jl is a free-to-use software library for the Julia programming language, which offers two major features:
- FMI in Julia: load, instantiate, parameterize and simulate FMUs seamlessly inside the Julia programming language
- NeuralFMUs: place FMUs simply inside any feed-forward NN topology and still keep the resulting hybrid model trainable with a standard AD training process 

## How can I use FMI.jl?
1. open a Julia-Command-Window, activate your prefered environemnt
1. goto package manager using ```]```
1. type ```add "https://github.com/ThummeTo/FMI.jl"```
1. the repository includes binaries, the repository folder and subfolders need at least permission ```101``` (read and execute)

## What is currently supported in FMI.jl?
- simulation / plotting of CS- and ME-FMUs
- building and training ME-NeuralFMUs with the default Flux-Front-End (CS-NeuralFMUs untested)
- event-handling for discontinuous ME-FMUs
- the full FMI command set (except ```getFMUState``` and ```setFMUState```)
- ...

## What is under development in FMI.jl?
- Linux support
- documentation (as document)
- more examples
- support for ```getFMUState``` and ```setFMUState```
- ...

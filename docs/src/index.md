
# Documentation 
This section is intended to familiarise users with the documentation environment and to provide a first detailed insight into the FMI.jl library.

## Documentation Overview
### 1. Introduction
The [Introduction]() is intended to provide an initial `overview of the structure` of the documentation. Thereby the most `important terms` are briefly explained for a better understanding of the functionalities of the library. In addition, the characteristic `features and functions of our FMI.jl library` are specifically described to answer users initial questions before using the library for the first time.  

### 2. Tutorials
Guidance on how to use the library correctly is provided in the [Tutorial]() sections. Various topics are `explained step by step` and `illustrated` with the help of `code snippets`.  

Until now, tutorials have been organized on the following topics:
- [Get Started]()
- [load and upload]()
- [simulate]()
- 

### 3. Examples
By using [Examples](), the use of the library can be shown best. Here, `short and easy` to understand `code blocks` are explained which should make the use of the functions a little easier.


### 4. Libary Funktions
The [Library Functions]() sections contains all the documentation to the functions provided by this library.  




### 5. Related Publications
If you are interested in [related publications](), you can browse through the list of references and gather more information. 

## Prior knowledge(@id Prior knowledge)

### Julia Programming Language


### FMI 
The Functional Mock-up Interface (FMI) is an open standard for the tool-independent exchange and integration of track models from different manufactures. FMI simplifies the use of the best tools for specific modeling tasks and the consistent reuse of models in different development phases and across departmental boundaries.

```@eval
file = "FMI-Specification-2.0.3.pdf"
url = "https://github.com/adribrune/FMI.jl/blob/main/docs/src/assets/$(file).pdf"
import Markdown
Markdown.parse("""
!!! note
    More detailed information about the Mock-up Interface (FMI) can be found on the following website [fmi-standard.org](http://fmi-standard.org/)
    The documentation is also available in PDF format: [$file]($url).
""")
```  

An exported model container that fulfills the FMI requirements is referred to as a Functional Mock-up Unit (FMU).They can be applied in diverse simulation environments and sometimes even in entire co-simulations. So FMUs can be divided into two main application classes: model-exchange and co-simulation.

## Library FMI.jl
Models within closed simulation tools complicate hybrid modeling, because for training purposes of data-driven model parts the loss gradient must be determined by neural networks (NN) and the model itself is required. Nevertheless, the structural integration of models in NNs is a sought-after field of research in which some approaches have already been made. For example, progress by integrating alogiritmic numerical solvers for ordenary differential equations (ODEs) in NNs. Another approach was to integrate physical models into mashine learning processes, where physical models are evaluated during training as part of the loss fuction. Besides, the focus here is not only on cost function but above all on the structural intergration of FMUs. For this purpose, the combination of physical and data-driven models is suitable as an overall industrial tool, which so far cannot be implemented in reality. By exporting the models to a more suitable environment, a alternative can be created, which serves as an approach to this freely usable library. 
As @Proir knowllage points out, the common standard in both business and research is the usage of FMI, in our application this serves as an excellent candidate. By providing the library, it should now be possible to make the subject area of neuronalODEs more attractive for industrial applications and introduce the state of the art of mashine learning techniques closer to production.  
FMI.jl: load, instantiate, parameterize and simulate FMUs seamlessly inside the Julia programming language!


## What is currently supported in FMI.jl?
- simulation / plotting of CS- and ME-FMUs
- event-handling for discontinuous ME-FMUs
- the full FMI command set

## What is under development in FMI.jl?
- FMI 3.0 and SSP 1.0 support
- FMI Cross Checks
- more examples
- ...

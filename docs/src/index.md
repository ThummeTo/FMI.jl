
# [Documentation](@id Doc)
This section is intended to familiarise users with the documentation environment and to provide a first detailed insight into the FMI.jl library.

## Documentation Overview
### 1. Introduction
The [Introduction]() is intended to provide an initial overview of the structure of the documentation. Thereby the most important terms are briefly explained for a better understanding of the functionalities of the library. In addition, the characteristic features and functions of our FMI.jl library` are specifically described to answer users initial questions before using the library for the first time.  

### 2. Tutorials
Guidance on how to use the library correctly is provided in the [`Tutorial`](@ref) sections. Various topics are explained step by step and illustrated with the help of code snippets.  

Until now, tutorials have been organized on the following topics:
- [`Get Started`](@ref)
- [`load and upload'](@ref)
- [`simulate`](@ref)
- 

### 3. Examples
By using [`Examples`](@ref), the use of the library can be shown best. Here, short and easy to understand code blocks are explained which should make the use of the functions a little easier.


### 4. Libary Funktions
The [`Library Functions`](@ref) sections contains all the documentation to the functions provided by this library.  




### 5. Related Publications
If you are interested in [`related publications`](@ref), you can browse through the list of references and gather more information. 

## [Prior knowledge](@id prior_knowledge)

### Julia Programming Language


```@eval
file = "NeuralFMU_ Towards Structural Integration of FMUs into Neural Networks.pdf"
url = "https://github.com/adribrune/FMI.jl/blob/main/docs/src/assets/$(file).pdf"
import Markdown
Markdown.parse("""
!!! note
    More detailed information about the FMI.jl can be found in the paper [NeuralFMU: Towards Structural Integration of FMUs into Neural Networks](https://arxiv.org/abs/2109.04351)
    The documentation is also available in PDF format: [$file]($url).
""")
```  

### [FMI](@id FMI) 
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

An exported model container that fulfils the FMI requirements is referred to as a Functional Mock-up Unit (FMU). They can be applied in diverse simulation environments and sometimes even in entire co-simulations. So, FMUs can be divided into two main application classes: model-exchange(ME) and co-simulation(CS).

- <ins>model-exchange(ME)</ins>:  ME-FMUs provide an interface to the system dynamics, allowing a system state derivative of a system state to be calculated. Then, outside the FMU, the next system state can be derived by numerical integration. In most applications, ME-FMUs should be the first choice, as this offers a wide range of possibilities when it comes to learning a dynamic system.

- <ins>co-simulation(CS)</ins>:  The inclusion of a numerical solver for ordinary differential equations (ODEs) simplifies the simulation considerably and also prevents further manipulation before numerical integration.



## Library FMI.jl
Models within closed simulation tools complicate hybrid modelling, because for training purposes of data-driven model parts the loss gradient must be determined by neural networks (NN) and the model itself is required. Nevertheless, the structural integration of models in NNs is a sought-after field of research in which some approaches have already been made. For example, progress by integrating algorithmic numerical solvers for ordinary differential equations (ODEs) in NNs. Another approach was to integrate physical models into machine learning processes, where physical models are evaluated during training as part of the loss function. Besides, the focus here is not only on cost function but above all on the structural integration of FMUs. For this purpose, the combination of physical and data-driven models is suitable as an overall industrial tool, which so far cannot be implemented in reality. By exporting the models to a more suitable environment, a alternative can be created, which serves as an approach to this freely usable library.As [prior knowledge](@ref prior_knowledge) points out, the common standard in both business and research is the usage of FMI, in our application this serves as an excellent candidate. With the extension fmiflix.jl and the provision of providing fmi.jl, it should now be possible to make the subject area of neuronalODEs more attractive for industrial applications and bring the state of the art of machine learning techniques closer to production.

- <ins>FMI.jl</ins>: load, instantiate, parameterize and simutale FMUs seamlessly inside the Julia prgramming langurage

- <ins>FMIFlux.jl</ins>: place FMUs simply inside any feedforward NN topology and still keep the resulting hybrid model trainable with a standard automatic Differentiation (AD) training process

```@eval
import Markdown
Markdown.parse("""
!!! note
    f you want to know more about the extension fmiflix.jl of this library, visit the[documentation](https://github.com/ThummeTo/FMIFlux.jl) 
""")
```  

<!---Modelling physical systems is often based on a simplification that excludes the parameterization of all physical aspects. For example, friction is neglected in many modelling of mechanical, electrical or hydraulic systems. Even when friction models are used, the parameterization is very fragile. This is where the hybrid modelling technique comes in, where a general representation of the parameterization of the friction model is to be learned over time, through measurements on the example system.
```@eval
import Markdown
Markdown.parse("""
!!! note
    In chapter 4 of this paper, the advantages are described in more detail using a simple example. [NeuralFMU: Towards Structural Integration of FMUs into Neural Networks](https://arxiv.org/abs/2109.04351)
""")
```--->

The Julia library provides a number of useful commands for use. Among the main applications is the unpacking, assigning, parameterizing and simulating of entire FMUs with additional display of the results.
Because FMI is under development, a version-independent FMU simulation with the same user interface must be ensured. In addition, the aim is to ensure a pleasant user experience for any user, which is why small but high-level Julia command sets are provided as well as low-level commands defined by the FMI standard. 

```@eval
file = "NeuralFMU_ Towards Structural Integration of FMUs into Neural Networks.pdf"
url = "https://github.com/adribrune/FMI.jl/blob/main/docs/src/assets/$(file).pdf"
import Markdown
Markdown.parse("""
!!! note
    More detailed information about the FMI.jl can be found in the paper [NeuralFMU: Towards Structural Integration of FMUs into Neural Networks](https://arxiv.org/abs/2109.04351)
    The documentation is also available in PDF format: [$file]($url).
""")
```  

<!---## What is currently supported in FMI.jl?
- simulation / plotting of CS- and ME-FMUs
- event-handling for discontinuous ME-FMUs
- the full FMI command set

## What is under development in FMI.jl?
- FMI 3.0 and SSP 1.0 support
- FMI Cross Checks
- more examples
- ... --->

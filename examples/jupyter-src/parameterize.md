# Parameterize a FMU
Tutorial by Tobias Thummerer, Johannes Stoljar

Last update: 09.08.2023

🚧 This tutorial is under revision and will be replaced by an up-to-date version soon 🚧

## License


```julia
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.
```

## Introduction
This example shows how to parameterize a FMU. We will show to possible ways to parameterize: The default option using the parameterization feature of `fmiSimulate`, `fmiSimulateME` or `fmiSimulateCS`. Second, a custom parameterization routine for advanced users. 

## Other formats
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameterize.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameterize.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameterize.md) corresponding to the notebook.  

## Code section

To run the example, the previously installed packages must be included. 


```julia
# imports
using FMI
using FMIZoo
```

    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mCircular dependency detected. Precompilation will be skipped for:
    [33m[1m│ [22m[39m  NonlinearSolveBaseSparseMatrixColoringsExt [e3ecd195-ca82-5397-9546-f380c1e34951]
    [33m[1m│ [22m[39m  DiffEqBaseChainRulesCoreExt [b00db79b-61e3-50fb-b26f-2d35b2d9e4ed]
    [33m[1m│ [22m[39m  Transducers [28d57a85-8fef-5791-bfe6-a80928e7c999]
    [33m[1m│ [22m[39m  NonlinearSolve [8913a72c-1f9b-4ce2-8d82-65094dcecaec]
    [33m[1m│ [22m[39m  OrdinaryDiffEq [1dea7af3-3e70-54e6-95c3-0bf5283fa5ed]
    [33m[1m│ [22m[39m  DifferentialEquationsFMIExt [232470a1-1d28-551b-8e3b-d6141e70703a]
    [33m[1m│ [22m[39m  NonlinearSolveBaseForwardDiffExt [63d416d0-6995-5965-81e0-55251226d976]
    [33m[1m│ [22m[39m  Folds [41a02a25-b8f0-4f67-bc48-60067656b558]
    [33m[1m│ [22m[39m  LineSearchLineSearchesExt [8d20b31a-8b56-511a-b573-0bef60e8c8c7]
    [33m[1m│ [22m[39m  NonlinearSolveBandedMatricesExt [8800daa3-e725-5fa8-982f-091420a833d6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFunctionMap [d3585ca7-f5d3-4ba6-8057-292ed1abd90f]
    [33m[1m│ [22m[39m  LinearSolveEnzymeExt [133222a9-3015-5ee0-8b28-65fc8ed13c28]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLinear [521117fe-8c41-49f8-b3b6-30780b3f0fb5]
    [33m[1m│ [22m[39m  OrdinaryDiffEqTsit5 [b1df2697-797e-41e3-8120-5422d3b24e4a]
    [33m[1m│ [22m[39m  TestExt [62af87b3-b810-57d2-b7eb-8929911df373]
    [33m[1m│ [22m[39m  OrdinaryDiffEqBDF [6ad6398a-0878-4a85-9266-38940aa047c8]
    [33m[1m│ [22m[39m  StaticArraysExt [6207fee4-2535-5e24-a3ba-6518da1c7d2a]
    [33m[1m│ [22m[39m  SparseDiffTools [47a9eef4-7e08-11e9-0b38-333d64bd3804]
    [33m[1m│ [22m[39m  OrdinaryDiffEqPRK [5b33eab2-c0f1-4480-b2c3-94bc1e80bda1]
    [33m[1m│ [22m[39m  OrdinaryDiffEqDefault [50262376-6c5a-4cf5-baba-aaf4f84d72d7]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqShooting [ed55bfe0-3725-4db6-871e-a1dc9f42a757]
    [33m[1m│ [22m[39m  OrdinaryDiffEqRosenbrock [43230ef6-c299-4910-a778-202eb28ce4ce]
    [33m[1m│ [22m[39m  JumpProcesses [ccbc3e58-028d-4f4c-8cd5-9ae44345cda5]
    [33m[1m│ [22m[39m  SteadyStateDiffEq [9672c7b4-1e72-59bd-8a11-6ac3964bc41f]
    [33m[1m│ [22m[39m  OrdinaryDiffEqAdamsBashforthMoulton [89bda076-bce5-4f1c-845f-551c83cdda9a]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExplicitRK [9286f039-9fbf-40e8-bf65-aa933bdc4db0]
    [33m[1m│ [22m[39m  OrdinaryDiffEqCore [bbf590c4-e513-4bbe-9b18-05decba2e5d8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqCoreEnzymeCoreExt [ca1c724a-f4aa-55ef-b8e4-2f05449449ac]
    [33m[1m│ [22m[39m  OrdinaryDiffEqPDIRK [5dd0a6cf-3d4b-4314-aa06-06d4e299bc89]
    [33m[1m│ [22m[39m  MATExt [5e726ecd-5b00-51ec-bc99-f7ee9de03178]
    [33m[1m│ [22m[39m  NonlinearSolveNLsolveExt [ae262b1c-8c8a-50b1-9ef3-b8fcfb893e74]
    [33m[1m│ [22m[39m  OrdinaryDiffEqStabilizedRK [358294b1-0aab-51c3-aafe-ad5ab194a2ad]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSSPRK [669c94d9-1f4b-4b64-b377-1aa079aa2388]
    [33m[1m│ [22m[39m  DelayDiffEq [bcd4f6db-9728-5f36-b5f7-82caef46ccdb]
    [33m[1m│ [22m[39m  DifferentialEquations [0c46a032-eb83-5123-abaf-570d42b7fbaa]
    [33m[1m│ [22m[39m  NonlinearSolveBaseSparseArraysExt [8494477e-8a74-521a-b11a-5a22161b1bc8]
    [33m[1m│ [22m[39m  PlotsExt [e73c9e8f-3556-58c3-b67e-c4596fa67ff1]
    [33m[1m│ [22m[39m  LinearSolveBandedMatricesExt [9522afde-9e86-5396-abc8-24b7312356fe]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqFIRK [85d9eb09-370e-4000-bb32-543851f73618]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqMIRK [1a22d4ce-7765-49ea-b6f2-13c8438986a6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqRKN [af6ede74-add8-4cfd-b1df-9a4dbb109d7a]
    [33m[1m│ [22m[39m  LinearSolve [7ed4a6bd-45f5-4d41-b270-4a48e9bafcae]
    [33m[1m│ [22m[39m  OrdinaryDiffEqQPRK [04162be5-8125-4266-98ed-640baecc6514]
    [33m[1m│ [22m[39m  RecursiveArrayToolsForwardDiffExt [14203109-85fb-5f77-af23-1cb7d9032242]
    [33m[1m│ [22m[39m  DiffEqBaseSparseArraysExt [4131c53f-b1d6-5635-a7a3-57f6f930b644]
    [33m[1m│ [22m[39m  TransducersLazyArraysExt [cdbecb60-77cf-500a-86c2-8d8bbf22df88]
    [33m[1m│ [22m[39m  NonlinearSolveBaseBandedMatricesExt [f3d6eb4f-59b9-5696-a638-eddf66c7554e]
    [33m[1m│ [22m[39m  NonlinearSolveFirstOrder [5959db7a-ea39-4486-b5fe-2dd0bf03d60d]
    [33m[1m│ [22m[39m  SciMLOperatorsStaticArraysCoreExt [a2df0a61-553a-563b-aed7-0ce21874eb58]
    [33m[1m│ [22m[39m  Sundials [c3572dad-4567-51f8-b174-8c6c989267f4]
    [33m[1m│ [22m[39m  RecursiveArrayToolsFastBroadcastExt [42296aa8-c874-5f57-b5c1-8d6f5ebd5400]
    [33m[1m│ [22m[39m  SciMLBase [0bca4576-84f4-4d90-8ffe-ffa030f20462]
    [33m[1m│ [22m[39m  ForwardDiffExt [92c717c9-c1e5-53c1-ac59-0de8aab6796e]
    [33m[1m│ [22m[39m  LinearSolveFastAlmostBandedMatricesExt [f94f2e43-4c39-5f8d-ab9c-7017feb07ff4]
    [33m[1m│ [22m[39m  OrdinaryDiffEqHighOrderRK [d28bc4f8-55e1-4f49-af69-84c1a99f0f58]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLowStorageRK [b0944070-b475-4768-8dec-fb6eb410534d]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSymplecticRK [fa646aed-7ef9-47eb-84c4-9443fc8cbfa8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqStabilizedIRK [e3e12d00-db14-5390-b879-ac3dd2ef6296]
    [33m[1m│ [22m[39m  FMIImport [9fcbc62e-52a0-44e9-a616-1359a0008194]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLowOrderRK [1344f307-1e59-4825-a18e-ace9aa3fa4c6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExponentialRK [e0540318-69ee-4070-8777-9e2de6de23de]
    [33m[1m│ [22m[39m  OrdinaryDiffEqDifferentiation [4302a76b-040a-498a-8c04-15b101fed76b]
    [33m[1m│ [22m[39m  OrdinaryDiffEqNonlinearSolve [127b3ac7-2247-4354-8eb6-78cf4e7c58e8]
    [33m[1m│ [22m[39m  SparseDiffToolsPolyesterExt [9f049cbb-7c7d-5dfe-91f7-cf323d5306ff]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSDIRK [2d112036-d095-4a1e-ab9a-08536f3ecdbf]
    [33m[1m│ [22m[39m  LinearAlgebraExt [ef8e1453-9c17-56fe-886b-405471570bc8]
    [33m[1m│ [22m[39m  LineSearch [87fe0de2-c867-4266-b59a-2f0a94fc965b]
    [33m[1m│ [22m[39m  SciMLBaseChainRulesCoreExt [4676cac9-c8e0-5d6e-a4e0-e3351593cdf5]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExtrapolation [becaefa8-8ca2-5cf9-886d-c06f3d2bd2c4]
    [33m[1m│ [22m[39m  OrdinaryDiffEqVerner [79d7bb75-1356-48c1-b8c0-6832512096c2]
    [33m[1m│ [22m[39m  SimpleNonlinearSolveChainRulesCoreExt [073a8d7d-86ee-5d75-9348-f9bf6155b014]
    [33m[1m│ [22m[39m  DiffEqCallbacks [459566f4-90b8-5000-8ac3-15dfb0a30def]
    [33m[1m│ [22m[39m  FMI [14a09403-18e3-468f-ad8a-74f8dda2d9ac]
    [33m[1m│ [22m[39m  BangBang [198e06fe-97b7-11e9-32a5-e1d131e6ad66]
    [33m[1m│ [22m[39m  DiffEqBaseDistributionsExt [24f3332a-0dc5-5d65-94b6-25e75cab9690]
    [33m[1m│ [22m[39m  SciMLOperators [c0aeaf25-5076-4817-a8d5-81caf7dfa961]
    [33m[1m│ [22m[39m  FMIBase [900ee838-d029-460e-b485-d98a826ceef2]
    [33m[1m│ [22m[39m  RecursiveArrayTools [731186ca-8d62-57ce-b412-fbd966d074cd]
    [33m[1m│ [22m[39m  FMIExport [31b88311-cab6-44ed-ba9c-fe5a9abbd67a]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqCore [56b672f2-a5fe-4263-ab2d-da677488eb3a]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFeagin [101fe9f7-ebb6-4678-b671-3a81e7194747]
    [33m[1m│ [22m[39m  StochasticDiffEq [789caeaf-c7a9-5a7d-9973-96adeb23e2a0]
    [33m[1m│ [22m[39m  DiffEqBase [2b5f629d-d688-5b77-993f-72d75c75574e]
    [33m[1m│ [22m[39m  BangBangStaticArraysExt [a9f1882a-14fa-573e-a12d-824431257a23]
    [33m[1m│ [22m[39m  FMIZooExt [0fe4e21f-c175-5a0f-899f-abb2d776b1a2]
    [33m[1m│ [22m[39m  RecursiveArrayToolsSparseArraysExt [73e54eaf-3344-511d-b088-1ac5413eca63]
    [33m[1m│ [22m[39m  BangBangChainRulesCoreExt [47e8a63d-7df8-5da4-81a4-8f5796ea640c]
    [33m[1m│ [22m[39m  LinearSolveRecursiveArrayToolsExt [04950c4b-5bc4-5740-952d-02d2c1eb583a]
    [33m[1m│ [22m[39m  TransducersReferenceablesExt [befac7fd-b390-5150-b72a-6269c65d7e1f]
    [33m[1m│ [22m[39m  SciMLJacobianOperators [19f34311-ddf3-4b8b-af20-060888a46c0e]
    [33m[1m│ [22m[39m  NonlinearSolveBaseLineSearchExt [a65b7766-7c26-554a-8b8d-165d7f96f890]
    [33m[1m│ [22m[39m  DiffEqNoiseProcess [77a26b50-5914-5dd7-bc55-306e6241c503]
    [33m[1m│ [22m[39m  TransducersAdaptExt [9144d9d9-84fa-5f34-a63a-3acddca89462]
    [33m[1m│ [22m[39m  DiffEqBaseUnitfulExt [aeb06bb4-539b-5a1b-8332-034ed9f8ca66]
    [33m[1m│ [22m[39m  UnitfulExt [8d0556db-720e-519a-baed-0b9ed79749be]
    [33m[1m│ [22m[39m  NonlinearSolveBaseLinearSolveExt [3d4538b4-647b-544e-b0c2-b52d0495c932]
    [33m[1m│ [22m[39m  OrdinaryDiffEqNordsieck [c9986a66-5c92-4813-8696-a7ec84c806c8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFIRK [5960d6e9-dd7a-4743-88e7-cf307b64f125]
    [33m[1m│ [22m[39m  NonlinearSolveBaseDiffEqBaseExt [a0bd8381-04c7-5287-82b0-0bf1e59008be]
    [33m[1m│ [22m[39m  SimpleNonlinearSolve [727e6d20-b764-4bd8-a329-72de5adea6c7]
    [33m[1m│ [22m[39m  NonlinearSolveBase [be0214bd-f91f-a760-ac4e-3421ce2b2da0]
    [33m[1m│ [22m[39m  OrdinaryDiffEqIMEXMultistep [9f002381-b378-40b7-97a6-27a27c83f129]
    [33m[1m│ [22m[39m  MicroCollections [128add7d-3638-4c79-886c-908ea0c25c34]
    [33m[1m│ [22m[39m  SymbolicIndexingInterface [2efcf032-c050-4f8e-a9bb-153293bab1f5]
    [33m[1m│ [22m[39m  DatesExt [0361c7f5-3687-5641-8bd2-a1de0c64d1ed]
    [33m[1m│ [22m[39m  SciMLOperatorsSparseArraysExt [9985400b-97ec-5583-b534-4f70b643bcf7]
    [33m[1m│ [22m[39m  BoundaryValueDiffEq [764a87c0-6b3e-53db-9096-fe964310641d]
    [33m[1m│ [22m[39m  BangBangTablesExt [476361b5-ac10-5c09-8bec-30d098a22a5b]
    [33m[1m└ [22m[39m[90m@ Pkg.API C:\hostedtoolcache\windows\julia\1.10.7\x64\share\julia\stdlib\v1.10\Pkg\src\API.jl:1279[39m
    

    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mPrecompiling FMI [14a09403-18e3-468f-ad8a-74f8dda2d9ac]
    

    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mModule DatesExt with build ID ffffffff-ffff-ffff-0000-00eb96972459 is missing from the cache.
    [33m[1m│ [22m[39mThis may mean DatesExt [0361c7f5-3687-5641-8bd2-a1de0c64d1ed] does not support precompilation but is imported by a module that does.
    [33m[1m└ [22m[39m[90m@ Base loading.jl:2011[39m
    

    [91m[1m┌ [22m[39m[91m[1mError: [22m[39mError during loading of extension DatesExt of Accessors, use `Base.retry_load_extensions()` to retry.
    [91m[1m│ [22m[39m  exception =
    [91m[1m│ [22m[39m   [0m1-element ExceptionStack:
    [91m[1m│ [22m[39m   Declaring __precompile__(false) is not allowed in files that are being precompiled.
    [91m[1m│ [22m[39m   Stacktrace:
    [91m[1m│ [22m[39m     [1] [0m[1m_require[22m[0m[1m([22m[90mpkg[39m::[0mBase.PkgId, [90menv[39m::[0mNothing[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:2015[24m[39m
    [91m[1m│ [22m[39m     [2] [0m[1m__require_prelocked[22m[0m[1m([22m[90muuidkey[39m::[0mBase.PkgId, [90menv[39m::[0mNothing[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1875[24m[39m
    [91m[1m│ [22m[39m     [3] [0m[1m#invoke_in_world#3[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:926[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m     [4] [0m[1minvoke_in_world[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:923[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m     [5] [0m[1m_require_prelocked[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mloading.jl:1866[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m     [6] [0m[1m_require_prelocked[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mloading.jl:1865[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m     [7] [0m[1mrun_extension_callbacks[22m[0m[1m([22m[90mextid[39m::[0mBase.ExtensionId[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1358[24m[39m
    [91m[1m│ [22m[39m     [8] [0m[1mrun_extension_callbacks[22m[0m[1m([22m[90mpkgid[39m::[0mBase.PkgId[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1393[24m[39m
    [91m[1m│ [22m[39m     [9] [0m[1mrun_package_callbacks[22m[0m[1m([22m[90mmodkey[39m::[0mBase.PkgId[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1218[24m[39m
    [91m[1m│ [22m[39m    [10] [0m[1m__require_prelocked[22m[0m[1m([22m[90muuidkey[39m::[0mBase.PkgId, [90menv[39m::[0mString[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1882[24m[39m
    [91m[1m│ [22m[39m    [11] [0m[1m#invoke_in_world#3[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:926[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m    [12] [0m[1minvoke_in_world[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:923[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m    [13] [0m[1m_require_prelocked[22m[0m[1m([22m[90muuidkey[39m::[0mBase.PkgId, [90menv[39m::[0mString[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1866[24m[39m
    [91m[1m│ [22m[39m    [14] [0m[1mmacro expansion[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mloading.jl:1853[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m    [15] [0m[1mmacro expansion[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mlock.jl:267[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m    [16] [0m[1m__require[22m[0m[1m([22m[90minto[39m::[0mModule, [90mmod[39m::[0mSymbol[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1816[24m[39m
    [91m[1m│ [22m[39m    [17] [0m[1m#invoke_in_world#3[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:926[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m    [18] [0m[1minvoke_in_world[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:923[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m    [19] [0m[1mrequire[22m[0m[1m([22m[90minto[39m::[0mModule, [90mmod[39m::[0mSymbol[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1809[24m[39m
    [91m[1m│ [22m[39m    [20] [0m[1minclude[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mBase.jl:495[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m    [21] [0m[1minclude_package_for_output[22m[0m[1m([22m[90mpkg[39m::[0mBase.PkgId, [90minput[39m::[0mString, [90mdepot_path[39m::[0mVector[90m{String}[39m, [90mdl_load_path[39m::[0mVector[90m{String}[39m, [90mload_path[39m::[0mVector[90m{String}[39m, [90mconcrete_deps[39m::[0mVector[90m{Pair{Base.PkgId, UInt128}}[39m, [90msource[39m::[0mString[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:2285[24m[39m
    [91m[1m│ [22m[39m    [22] top-level scope
    [91m[1m│ [22m[39m   [90m    @[39m [90m[4mstdin:3[24m[39m
    [91m[1m│ [22m[39m    [23] [0m[1meval[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mboot.jl:385[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m    [24] [0m[1minclude_string[22m[0m[1m([22m[90mmapexpr[39m::[0mtypeof(identity), [90mmod[39m::[0mModule, [90mcode[39m::[0mString, [90mfilename[39m::[0mString[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:2139[24m[39m
    [91m[1m│ [22m[39m    [25] [0m[1minclude_string[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mloading.jl:2149[24m[39m[90m [inlined][39m
    [91m[1m│ [22m[39m    [26] [0m[1mexec_options[22m[0m[1m([22m[90mopts[39m::[0mBase.JLOptions[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mclient.jl:321[24m[39m
    [91m[1m│ [22m[39m    [27] [0m[1m_start[22m[0m[1m([22m[0m[1m)[22m
    [91m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mclient.jl:557[24m[39m
    [91m[1m└ [22m[39m[90m@ Base loading.jl:1364[39m
    

    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mCircular dependency detected. Precompilation will be skipped for:
    [33m[1m│ [22m[39m  NonlinearSolveBaseSparseMatrixColoringsExt [e3ecd195-ca82-5397-9546-f380c1e34951]
    [33m[1m│ [22m[39m  DiffEqBaseChainRulesCoreExt [b00db79b-61e3-50fb-b26f-2d35b2d9e4ed]
    [33m[1m│ [22m[39m  Transducers [28d57a85-8fef-5791-bfe6-a80928e7c999]
    [33m[1m│ [22m[39m  NonlinearSolve [8913a72c-1f9b-4ce2-8d82-65094dcecaec]
    [33m[1m│ [22m[39m  OrdinaryDiffEq [1dea7af3-3e70-54e6-95c3-0bf5283fa5ed]
    [33m[1m│ [22m[39m  DifferentialEquationsFMIExt [232470a1-1d28-551b-8e3b-d6141e70703a]
    [33m[1m│ [22m[39m  NonlinearSolveBaseForwardDiffExt [63d416d0-6995-5965-81e0-55251226d976]
    [33m[1m│ [22m[39m  Folds [41a02a25-b8f0-4f67-bc48-60067656b558]
    [33m[1m│ [22m[39m  LineSearchLineSearchesExt [8d20b31a-8b56-511a-b573-0bef60e8c8c7]
    [33m[1m│ [22m[39m  NonlinearSolveBandedMatricesExt [8800daa3-e725-5fa8-982f-091420a833d6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFunctionMap [d3585ca7-f5d3-4ba6-8057-292ed1abd90f]
    [33m[1m│ [22m[39m  LinearSolveEnzymeExt [133222a9-3015-5ee0-8b28-65fc8ed13c28]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLinear [521117fe-8c41-49f8-b3b6-30780b3f0fb5]
    [33m[1m│ [22m[39m  OrdinaryDiffEqTsit5 [b1df2697-797e-41e3-8120-5422d3b24e4a]
    [33m[1m│ [22m[39m  TestExt [62af87b3-b810-57d2-b7eb-8929911df373]
    [33m[1m│ [22m[39m  OrdinaryDiffEqBDF [6ad6398a-0878-4a85-9266-38940aa047c8]
    [33m[1m│ [22m[39m  StaticArraysExt [6207fee4-2535-5e24-a3ba-6518da1c7d2a]
    [33m[1m│ [22m[39m  SparseDiffTools [47a9eef4-7e08-11e9-0b38-333d64bd3804]
    [33m[1m│ [22m[39m  OrdinaryDiffEqPRK [5b33eab2-c0f1-4480-b2c3-94bc1e80bda1]
    [33m[1m│ [22m[39m  OrdinaryDiffEqDefault [50262376-6c5a-4cf5-baba-aaf4f84d72d7]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqShooting [ed55bfe0-3725-4db6-871e-a1dc9f42a757]
    [33m[1m│ [22m[39m  OrdinaryDiffEqRosenbrock [43230ef6-c299-4910-a778-202eb28ce4ce]
    [33m[1m│ [22m[39m  JumpProcesses [ccbc3e58-028d-4f4c-8cd5-9ae44345cda5]
    [33m[1m│ [22m[39m  SteadyStateDiffEq [9672c7b4-1e72-59bd-8a11-6ac3964bc41f]
    [33m[1m│ [22m[39m  OrdinaryDiffEqAdamsBashforthMoulton [89bda076-bce5-4f1c-845f-551c83cdda9a]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExplicitRK [9286f039-9fbf-40e8-bf65-aa933bdc4db0]
    [33m[1m│ [22m[39m  OrdinaryDiffEqCore [bbf590c4-e513-4bbe-9b18-05decba2e5d8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqCoreEnzymeCoreExt [ca1c724a-f4aa-55ef-b8e4-2f05449449ac]
    [33m[1m│ [22m[39m  OrdinaryDiffEqPDIRK [5dd0a6cf-3d4b-4314-aa06-06d4e299bc89]
    [33m[1m│ [22m[39m  MATExt [5e726ecd-5b00-51ec-bc99-f7ee9de03178]
    [33m[1m│ [22m[39m  NonlinearSolveNLsolveExt [ae262b1c-8c8a-50b1-9ef3-b8fcfb893e74]
    [33m[1m│ [22m[39m  OrdinaryDiffEqStabilizedRK [358294b1-0aab-51c3-aafe-ad5ab194a2ad]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSSPRK [669c94d9-1f4b-4b64-b377-1aa079aa2388]
    [33m[1m│ [22m[39m  DelayDiffEq [bcd4f6db-9728-5f36-b5f7-82caef46ccdb]
    [33m[1m│ [22m[39m  DifferentialEquations [0c46a032-eb83-5123-abaf-570d42b7fbaa]
    [33m[1m│ [22m[39m  NonlinearSolveBaseSparseArraysExt [8494477e-8a74-521a-b11a-5a22161b1bc8]
    [33m[1m│ [22m[39m  PlotsExt [e73c9e8f-3556-58c3-b67e-c4596fa67ff1]
    [33m[1m│ [22m[39m  LinearSolveBandedMatricesExt [9522afde-9e86-5396-abc8-24b7312356fe]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqFIRK [85d9eb09-370e-4000-bb32-543851f73618]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqMIRK [1a22d4ce-7765-49ea-b6f2-13c8438986a6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqRKN [af6ede74-add8-4cfd-b1df-9a4dbb109d7a]
    [33m[1m│ [22m[39m  LinearSolve [7ed4a6bd-45f5-4d41-b270-4a48e9bafcae]
    [33m[1m│ [22m[39m  OrdinaryDiffEqQPRK [04162be5-8125-4266-98ed-640baecc6514]
    [33m[1m│ [22m[39m  RecursiveArrayToolsForwardDiffExt [14203109-85fb-5f77-af23-1cb7d9032242]
    [33m[1m│ [22m[39m  DiffEqBaseSparseArraysExt [4131c53f-b1d6-5635-a7a3-57f6f930b644]
    [33m[1m│ [22m[39m  TransducersLazyArraysExt [cdbecb60-77cf-500a-86c2-8d8bbf22df88]
    [33m[1m│ [22m[39m  NonlinearSolveBaseBandedMatricesExt [f3d6eb4f-59b9-5696-a638-eddf66c7554e]
    [33m[1m│ [22m[39m  NonlinearSolveFirstOrder [5959db7a-ea39-4486-b5fe-2dd0bf03d60d]
    [33m[1m│ [22m[39m  SciMLOperatorsStaticArraysCoreExt [a2df0a61-553a-563b-aed7-0ce21874eb58]
    [33m[1m│ [22m[39m  Sundials [c3572dad-4567-51f8-b174-8c6c989267f4]
    [33m[1m│ [22m[39m  RecursiveArrayToolsFastBroadcastExt [42296aa8-c874-5f57-b5c1-8d6f5ebd5400]
    [33m[1m│ [22m[39m  SciMLBase [0bca4576-84f4-4d90-8ffe-ffa030f20462]
    [33m[1m│ [22m[39m  ForwardDiffExt [92c717c9-c1e5-53c1-ac59-0de8aab6796e]
    [33m[1m│ [22m[39m  LinearSolveFastAlmostBandedMatricesExt [f94f2e43-4c39-5f8d-ab9c-7017feb07ff4]
    [33m[1m│ [22m[39m  OrdinaryDiffEqHighOrderRK [d28bc4f8-55e1-4f49-af69-84c1a99f0f58]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLowStorageRK [b0944070-b475-4768-8dec-fb6eb410534d]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSymplecticRK [fa646aed-7ef9-47eb-84c4-9443fc8cbfa8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqStabilizedIRK [e3e12d00-db14-5390-b879-ac3dd2ef6296]
    [33m[1m│ [22m[39m  FMIImport [9fcbc62e-52a0-44e9-a616-1359a0008194]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLowOrderRK [1344f307-1e59-4825-a18e-ace9aa3fa4c6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExponentialRK [e0540318-69ee-4070-8777-9e2de6de23de]
    [33m[1m│ [22m[39m  OrdinaryDiffEqDifferentiation [4302a76b-040a-498a-8c04-15b101fed76b]
    [33m[1m│ [22m[39m  OrdinaryDiffEqNonlinearSolve [127b3ac7-2247-4354-8eb6-78cf4e7c58e8]
    [33m[1m│ [22m[39m  SparseDiffToolsPolyesterExt [9f049cbb-7c7d-5dfe-91f7-cf323d5306ff]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSDIRK [2d112036-d095-4a1e-ab9a-08536f3ecdbf]
    [33m[1m│ [22m[39m  LinearAlgebraExt [ef8e1453-9c17-56fe-886b-405471570bc8]
    [33m[1m│ [22m[39m  LineSearch [87fe0de2-c867-4266-b59a-2f0a94fc965b]
    [33m[1m│ [22m[39m  SciMLBaseChainRulesCoreExt [4676cac9-c8e0-5d6e-a4e0-e3351593cdf5]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExtrapolation [becaefa8-8ca2-5cf9-886d-c06f3d2bd2c4]
    [33m[1m│ [22m[39m  OrdinaryDiffEqVerner [79d7bb75-1356-48c1-b8c0-6832512096c2]
    [33m[1m│ [22m[39m  SimpleNonlinearSolveChainRulesCoreExt [073a8d7d-86ee-5d75-9348-f9bf6155b014]
    [33m[1m│ [22m[39m  DiffEqCallbacks [459566f4-90b8-5000-8ac3-15dfb0a30def]
    [33m[1m│ [22m[39m  FMI [14a09403-18e3-468f-ad8a-74f8dda2d9ac]
    [33m[1m│ [22m[39m  BangBang [198e06fe-97b7-11e9-32a5-e1d131e6ad66]
    [33m[1m│ [22m[39m  DiffEqBaseDistributionsExt [24f3332a-0dc5-5d65-94b6-25e75cab9690]
    [33m[1m│ [22m[39m  SciMLOperators [c0aeaf25-5076-4817-a8d5-81caf7dfa961]
    [33m[1m│ [22m[39m  FMIBase [900ee838-d029-460e-b485-d98a826ceef2]
    [33m[1m│ [22m[39m  RecursiveArrayTools [731186ca-8d62-57ce-b412-fbd966d074cd]
    [33m[1m│ [22m[39m  FMIExport [31b88311-cab6-44ed-ba9c-fe5a9abbd67a]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqCore [56b672f2-a5fe-4263-ab2d-da677488eb3a]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFeagin [101fe9f7-ebb6-4678-b671-3a81e7194747]
    [33m[1m│ [22m[39m  StochasticDiffEq [789caeaf-c7a9-5a7d-9973-96adeb23e2a0]
    [33m[1m│ [22m[39m  DiffEqBase [2b5f629d-d688-5b77-993f-72d75c75574e]
    [33m[1m│ [22m[39m  BangBangStaticArraysExt [a9f1882a-14fa-573e-a12d-824431257a23]
    [33m[1m│ [22m[39m  FMIZooExt [0fe4e21f-c175-5a0f-899f-abb2d776b1a2]
    [33m[1m│ [22m[39m  RecursiveArrayToolsSparseArraysExt [73e54eaf-3344-511d-b088-1ac5413eca63]
    [33m[1m│ [22m[39m  BangBangChainRulesCoreExt [47e8a63d-7df8-5da4-81a4-8f5796ea640c]
    [33m[1m│ [22m[39m  LinearSolveRecursiveArrayToolsExt [04950c4b-5bc4-5740-952d-02d2c1eb583a]
    [33m[1m│ [22m[39m  TransducersReferenceablesExt [befac7fd-b390-5150-b72a-6269c65d7e1f]
    [33m[1m│ [22m[39m  SciMLJacobianOperators [19f34311-ddf3-4b8b-af20-060888a46c0e]
    [33m[1m│ [22m[39m  NonlinearSolveBaseLineSearchExt [a65b7766-7c26-554a-8b8d-165d7f96f890]
    [33m[1m│ [22m[39m  DiffEqNoiseProcess [77a26b50-5914-5dd7-bc55-306e6241c503]
    [33m[1m│ [22m[39m  TransducersAdaptExt [9144d9d9-84fa-5f34-a63a-3acddca89462]
    [33m[1m│ [22m[39m  DiffEqBaseUnitfulExt [aeb06bb4-539b-5a1b-8332-034ed9f8ca66]
    [33m[1m│ [22m[39m  UnitfulExt [8d0556db-720e-519a-baed-0b9ed79749be]
    [33m[1m│ [22m[39m  NonlinearSolveBaseLinearSolveExt [3d4538b4-647b-544e-b0c2-b52d0495c932]
    [33m[1m│ [22m[39m  OrdinaryDiffEqNordsieck [c9986a66-5c92-4813-8696-a7ec84c806c8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFIRK [5960d6e9-dd7a-4743-88e7-cf307b64f125]
    [33m[1m│ [22m[39m  NonlinearSolveBaseDiffEqBaseExt [a0bd8381-04c7-5287-82b0-0bf1e59008be]
    [33m[1m│ [22m[39m  SimpleNonlinearSolve [727e6d20-b764-4bd8-a329-72de5adea6c7]
    [33m[1m│ [22m[39m  NonlinearSolveBase [be0214bd-f91f-a760-ac4e-3421ce2b2da0]
    [33m[1m│ [22m[39m  OrdinaryDiffEqIMEXMultistep [9f002381-b378-40b7-97a6-27a27c83f129]
    [33m[1m│ [22m[39m  MicroCollections [128add7d-3638-4c79-886c-908ea0c25c34]
    [33m[1m│ [22m[39m  SymbolicIndexingInterface [2efcf032-c050-4f8e-a9bb-153293bab1f5]
    [33m[1m│ [22m[39m  DatesExt [0361c7f5-3687-5641-8bd2-a1de0c64d1ed]
    [33m[1m│ [22m[39m  SciMLOperatorsSparseArraysExt [9985400b-97ec-5583-b534-4f70b643bcf7]
    [33m[1m│ [22m[39m  BoundaryValueDiffEq [764a87c0-6b3e-53db-9096-fe964310641d]
    [33m[1m│ [22m[39m  BangBangTablesExt [476361b5-ac10-5c09-8bec-30d098a22a5b]
    [33m[1m└ [22m[39m[90m@ Pkg.API C:\hostedtoolcache\windows\julia\1.10.7\x64\share\julia\stdlib\v1.10\Pkg\src\API.jl:1279[39m
    

    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mPrecompiling MATExt [5e726ecd-5b00-51ec-bc99-f7ee9de03178]
    

    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mCircular dependency detected. Precompilation will be skipped for:
    [33m[1m│ [22m[39m  NonlinearSolveBaseSparseMatrixColoringsExt [e3ecd195-ca82-5397-9546-f380c1e34951]
    [33m[1m│ [22m[39m  DiffEqBaseChainRulesCoreExt [b00db79b-61e3-50fb-b26f-2d35b2d9e4ed]
    [33m[1m│ [22m[39m  Transducers [28d57a85-8fef-5791-bfe6-a80928e7c999]
    [33m[1m│ [22m[39m  NonlinearSolve [8913a72c-1f9b-4ce2-8d82-65094dcecaec]
    [33m[1m│ [22m[39m  OrdinaryDiffEq [1dea7af3-3e70-54e6-95c3-0bf5283fa5ed]
    [33m[1m│ [22m[39m  DifferentialEquationsFMIExt [232470a1-1d28-551b-8e3b-d6141e70703a]
    [33m[1m│ [22m[39m  NonlinearSolveBaseForwardDiffExt [63d416d0-6995-5965-81e0-55251226d976]
    [33m[1m│ [22m[39m  Folds [41a02a25-b8f0-4f67-bc48-60067656b558]
    [33m[1m│ [22m[39m  LineSearchLineSearchesExt [8d20b31a-8b56-511a-b573-0bef60e8c8c7]
    [33m[1m│ [22m[39m  NonlinearSolveBandedMatricesExt [8800daa3-e725-5fa8-982f-091420a833d6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFunctionMap [d3585ca7-f5d3-4ba6-8057-292ed1abd90f]
    [33m[1m│ [22m[39m  LinearSolveEnzymeExt [133222a9-3015-5ee0-8b28-65fc8ed13c28]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLinear [521117fe-8c41-49f8-b3b6-30780b3f0fb5]
    [33m[1m│ [22m[39m  OrdinaryDiffEqTsit5 [b1df2697-797e-41e3-8120-5422d3b24e4a]
    [33m[1m│ [22m[39m  TestExt [62af87b3-b810-57d2-b7eb-8929911df373]
    [33m[1m│ [22m[39m  OrdinaryDiffEqBDF [6ad6398a-0878-4a85-9266-38940aa047c8]
    [33m[1m│ [22m[39m  StaticArraysExt [6207fee4-2535-5e24-a3ba-6518da1c7d2a]
    [33m[1m│ [22m[39m  SparseDiffTools [47a9eef4-7e08-11e9-0b38-333d64bd3804]
    [33m[1m│ [22m[39m  OrdinaryDiffEqPRK [5b33eab2-c0f1-4480-b2c3-94bc1e80bda1]
    [33m[1m│ [22m[39m  OrdinaryDiffEqDefault [50262376-6c5a-4cf5-baba-aaf4f84d72d7]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqShooting [ed55bfe0-3725-4db6-871e-a1dc9f42a757]
    [33m[1m│ [22m[39m  OrdinaryDiffEqRosenbrock [43230ef6-c299-4910-a778-202eb28ce4ce]
    [33m[1m│ [22m[39m  JumpProcesses [ccbc3e58-028d-4f4c-8cd5-9ae44345cda5]
    [33m[1m│ [22m[39m  SteadyStateDiffEq [9672c7b4-1e72-59bd-8a11-6ac3964bc41f]
    [33m[1m│ [22m[39m  OrdinaryDiffEqAdamsBashforthMoulton [89bda076-bce5-4f1c-845f-551c83cdda9a]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExplicitRK [9286f039-9fbf-40e8-bf65-aa933bdc4db0]
    [33m[1m│ [22m[39m  OrdinaryDiffEqCore [bbf590c4-e513-4bbe-9b18-05decba2e5d8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqCoreEnzymeCoreExt [ca1c724a-f4aa-55ef-b8e4-2f05449449ac]
    [33m[1m│ [22m[39m  OrdinaryDiffEqPDIRK [5dd0a6cf-3d4b-4314-aa06-06d4e299bc89]
    [33m[1m│ [22m[39m  MATExt [5e726ecd-5b00-51ec-bc99-f7ee9de03178]
    [33m[1m│ [22m[39m  NonlinearSolveNLsolveExt [ae262b1c-8c8a-50b1-9ef3-b8fcfb893e74]
    [33m[1m│ [22m[39m  OrdinaryDiffEqStabilizedRK [358294b1-0aab-51c3-aafe-ad5ab194a2ad]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSSPRK [669c94d9-1f4b-4b64-b377-1aa079aa2388]
    [33m[1m│ [22m[39m  DelayDiffEq [bcd4f6db-9728-5f36-b5f7-82caef46ccdb]
    [33m[1m│ [22m[39m  DifferentialEquations [0c46a032-eb83-5123-abaf-570d42b7fbaa]
    [33m[1m│ [22m[39m  NonlinearSolveBaseSparseArraysExt [8494477e-8a74-521a-b11a-5a22161b1bc8]
    [33m[1m│ [22m[39m  PlotsExt [e73c9e8f-3556-58c3-b67e-c4596fa67ff1]
    [33m[1m│ [22m[39m  LinearSolveBandedMatricesExt [9522afde-9e86-5396-abc8-24b7312356fe]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqFIRK [85d9eb09-370e-4000-bb32-543851f73618]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqMIRK [1a22d4ce-7765-49ea-b6f2-13c8438986a6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqRKN [af6ede74-add8-4cfd-b1df-9a4dbb109d7a]
    [33m[1m│ [22m[39m  LinearSolve [7ed4a6bd-45f5-4d41-b270-4a48e9bafcae]
    [33m[1m│ [22m[39m  OrdinaryDiffEqQPRK [04162be5-8125-4266-98ed-640baecc6514]
    [33m[1m│ [22m[39m  RecursiveArrayToolsForwardDiffExt [14203109-85fb-5f77-af23-1cb7d9032242]
    [33m[1m│ [22m[39m  DiffEqBaseSparseArraysExt [4131c53f-b1d6-5635-a7a3-57f6f930b644]
    [33m[1m│ [22m[39m  TransducersLazyArraysExt [cdbecb60-77cf-500a-86c2-8d8bbf22df88]
    [33m[1m│ [22m[39m  NonlinearSolveBaseBandedMatricesExt [f3d6eb4f-59b9-5696-a638-eddf66c7554e]
    [33m[1m│ [22m[39m  NonlinearSolveFirstOrder [5959db7a-ea39-4486-b5fe-2dd0bf03d60d]
    [33m[1m│ [22m[39m  SciMLOperatorsStaticArraysCoreExt [a2df0a61-553a-563b-aed7-0ce21874eb58]
    [33m[1m│ [22m[39m  Sundials [c3572dad-4567-51f8-b174-8c6c989267f4]
    [33m[1m│ [22m[39m  RecursiveArrayToolsFastBroadcastExt [42296aa8-c874-5f57-b5c1-8d6f5ebd5400]
    [33m[1m│ [22m[39m  SciMLBase [0bca4576-84f4-4d90-8ffe-ffa030f20462]
    [33m[1m│ [22m[39m  ForwardDiffExt [92c717c9-c1e5-53c1-ac59-0de8aab6796e]
    [33m[1m│ [22m[39m  LinearSolveFastAlmostBandedMatricesExt [f94f2e43-4c39-5f8d-ab9c-7017feb07ff4]
    [33m[1m│ [22m[39m  OrdinaryDiffEqHighOrderRK [d28bc4f8-55e1-4f49-af69-84c1a99f0f58]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLowStorageRK [b0944070-b475-4768-8dec-fb6eb410534d]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSymplecticRK [fa646aed-7ef9-47eb-84c4-9443fc8cbfa8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqStabilizedIRK [e3e12d00-db14-5390-b879-ac3dd2ef6296]
    [33m[1m│ [22m[39m  FMIImport [9fcbc62e-52a0-44e9-a616-1359a0008194]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLowOrderRK [1344f307-1e59-4825-a18e-ace9aa3fa4c6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExponentialRK [e0540318-69ee-4070-8777-9e2de6de23de]
    [33m[1m│ [22m[39m  OrdinaryDiffEqDifferentiation [4302a76b-040a-498a-8c04-15b101fed76b]
    [33m[1m│ [22m[39m  OrdinaryDiffEqNonlinearSolve [127b3ac7-2247-4354-8eb6-78cf4e7c58e8]
    [33m[1m│ [22m[39m  SparseDiffToolsPolyesterExt [9f049cbb-7c7d-5dfe-91f7-cf323d5306ff]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSDIRK [2d112036-d095-4a1e-ab9a-08536f3ecdbf]
    [33m[1m│ [22m[39m  LinearAlgebraExt [ef8e1453-9c17-56fe-886b-405471570bc8]
    [33m[1m│ [22m[39m  LineSearch [87fe0de2-c867-4266-b59a-2f0a94fc965b]
    [33m[1m│ [22m[39m  SciMLBaseChainRulesCoreExt [4676cac9-c8e0-5d6e-a4e0-e3351593cdf5]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExtrapolation [becaefa8-8ca2-5cf9-886d-c06f3d2bd2c4]
    [33m[1m│ [22m[39m  OrdinaryDiffEqVerner [79d7bb75-1356-48c1-b8c0-6832512096c2]
    [33m[1m│ [22m[39m  SimpleNonlinearSolveChainRulesCoreExt [073a8d7d-86ee-5d75-9348-f9bf6155b014]
    [33m[1m│ [22m[39m  DiffEqCallbacks [459566f4-90b8-5000-8ac3-15dfb0a30def]
    [33m[1m│ [22m[39m  FMI [14a09403-18e3-468f-ad8a-74f8dda2d9ac]
    [33m[1m│ [22m[39m  BangBang [198e06fe-97b7-11e9-32a5-e1d131e6ad66]
    [33m[1m│ [22m[39m  DiffEqBaseDistributionsExt [24f3332a-0dc5-5d65-94b6-25e75cab9690]
    [33m[1m│ [22m[39m  SciMLOperators [c0aeaf25-5076-4817-a8d5-81caf7dfa961]
    [33m[1m│ [22m[39m  FMIBase [900ee838-d029-460e-b485-d98a826ceef2]
    [33m[1m│ [22m[39m  RecursiveArrayTools [731186ca-8d62-57ce-b412-fbd966d074cd]
    [33m[1m│ [22m[39m  FMIExport [31b88311-cab6-44ed-ba9c-fe5a9abbd67a]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqCore [56b672f2-a5fe-4263-ab2d-da677488eb3a]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFeagin [101fe9f7-ebb6-4678-b671-3a81e7194747]
    [33m[1m│ [22m[39m  StochasticDiffEq [789caeaf-c7a9-5a7d-9973-96adeb23e2a0]
    [33m[1m│ [22m[39m  DiffEqBase [2b5f629d-d688-5b77-993f-72d75c75574e]
    [33m[1m│ [22m[39m  BangBangStaticArraysExt [a9f1882a-14fa-573e-a12d-824431257a23]
    [33m[1m│ [22m[39m  FMIZooExt [0fe4e21f-c175-5a0f-899f-abb2d776b1a2]
    [33m[1m│ [22m[39m  RecursiveArrayToolsSparseArraysExt [73e54eaf-3344-511d-b088-1ac5413eca63]
    [33m[1m│ [22m[39m  BangBangChainRulesCoreExt [47e8a63d-7df8-5da4-81a4-8f5796ea640c]
    [33m[1m│ [22m[39m  LinearSolveRecursiveArrayToolsExt [04950c4b-5bc4-5740-952d-02d2c1eb583a]
    [33m[1m│ [22m[39m  TransducersReferenceablesExt [befac7fd-b390-5150-b72a-6269c65d7e1f]
    [33m[1m│ [22m[39m  SciMLJacobianOperators [19f34311-ddf3-4b8b-af20-060888a46c0e]
    [33m[1m│ [22m[39m  NonlinearSolveBaseLineSearchExt [a65b7766-7c26-554a-8b8d-165d7f96f890]
    [33m[1m│ [22m[39m  DiffEqNoiseProcess [77a26b50-5914-5dd7-bc55-306e6241c503]
    [33m[1m│ [22m[39m  TransducersAdaptExt [9144d9d9-84fa-5f34-a63a-3acddca89462]
    [33m[1m│ [22m[39m  DiffEqBaseUnitfulExt [aeb06bb4-539b-5a1b-8332-034ed9f8ca66]
    [33m[1m│ [22m[39m  UnitfulExt [8d0556db-720e-519a-baed-0b9ed79749be]
    [33m[1m│ [22m[39m  NonlinearSolveBaseLinearSolveExt [3d4538b4-647b-544e-b0c2-b52d0495c932]
    [33m[1m│ [22m[39m  OrdinaryDiffEqNordsieck [c9986a66-5c92-4813-8696-a7ec84c806c8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFIRK [5960d6e9-dd7a-4743-88e7-cf307b64f125]
    [33m[1m│ [22m[39m  NonlinearSolveBaseDiffEqBaseExt [a0bd8381-04c7-5287-82b0-0bf1e59008be]
    [33m[1m│ [22m[39m  SimpleNonlinearSolve [727e6d20-b764-4bd8-a329-72de5adea6c7]
    [33m[1m│ [22m[39m  NonlinearSolveBase [be0214bd-f91f-a760-ac4e-3421ce2b2da0]
    [33m[1m│ [22m[39m  OrdinaryDiffEqIMEXMultistep [9f002381-b378-40b7-97a6-27a27c83f129]
    [33m[1m│ [22m[39m  MicroCollections [128add7d-3638-4c79-886c-908ea0c25c34]
    [33m[1m│ [22m[39m  SymbolicIndexingInterface [2efcf032-c050-4f8e-a9bb-153293bab1f5]
    [33m[1m│ [22m[39m  DatesExt [0361c7f5-3687-5641-8bd2-a1de0c64d1ed]
    [33m[1m│ [22m[39m  SciMLOperatorsSparseArraysExt [9985400b-97ec-5583-b534-4f70b643bcf7]
    [33m[1m│ [22m[39m  BoundaryValueDiffEq [764a87c0-6b3e-53db-9096-fe964310641d]
    [33m[1m│ [22m[39m  BangBangTablesExt [476361b5-ac10-5c09-8bec-30d098a22a5b]
    [33m[1m└ [22m[39m[90m@ Pkg.API C:\hostedtoolcache\windows\julia\1.10.7\x64\share\julia\stdlib\v1.10\Pkg\src\API.jl:1279[39m
    

    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mPrecompiling StaticArraysExt [6207fee4-2535-5e24-a3ba-6518da1c7d2a]
    

    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mCircular dependency detected. Precompilation will be skipped for:
    [33m[1m│ [22m[39m  NonlinearSolveBaseSparseMatrixColoringsExt [e3ecd195-ca82-5397-9546-f380c1e34951]
    [33m[1m│ [22m[39m  DiffEqBaseChainRulesCoreExt [b00db79b-61e3-50fb-b26f-2d35b2d9e4ed]
    [33m[1m│ [22m[39m  Transducers [28d57a85-8fef-5791-bfe6-a80928e7c999]
    [33m[1m│ [22m[39m  NonlinearSolve [8913a72c-1f9b-4ce2-8d82-65094dcecaec]
    [33m[1m│ [22m[39m  OrdinaryDiffEq [1dea7af3-3e70-54e6-95c3-0bf5283fa5ed]
    [33m[1m│ [22m[39m  DifferentialEquationsFMIExt [232470a1-1d28-551b-8e3b-d6141e70703a]
    [33m[1m│ [22m[39m  NonlinearSolveBaseForwardDiffExt [63d416d0-6995-5965-81e0-55251226d976]
    [33m[1m│ [22m[39m  Folds [41a02a25-b8f0-4f67-bc48-60067656b558]
    [33m[1m│ [22m[39m  LineSearchLineSearchesExt [8d20b31a-8b56-511a-b573-0bef60e8c8c7]
    [33m[1m│ [22m[39m  NonlinearSolveBandedMatricesExt [8800daa3-e725-5fa8-982f-091420a833d6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFunctionMap [d3585ca7-f5d3-4ba6-8057-292ed1abd90f]
    [33m[1m│ [22m[39m  LinearSolveEnzymeExt [133222a9-3015-5ee0-8b28-65fc8ed13c28]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLinear [521117fe-8c41-49f8-b3b6-30780b3f0fb5]
    [33m[1m│ [22m[39m  OrdinaryDiffEqTsit5 [b1df2697-797e-41e3-8120-5422d3b24e4a]
    [33m[1m│ [22m[39m  TestExt [62af87b3-b810-57d2-b7eb-8929911df373]
    [33m[1m│ [22m[39m  OrdinaryDiffEqBDF [6ad6398a-0878-4a85-9266-38940aa047c8]
    [33m[1m│ [22m[39m  StaticArraysExt [6207fee4-2535-5e24-a3ba-6518da1c7d2a]
    [33m[1m│ [22m[39m  SparseDiffTools [47a9eef4-7e08-11e9-0b38-333d64bd3804]
    [33m[1m│ [22m[39m  OrdinaryDiffEqPRK [5b33eab2-c0f1-4480-b2c3-94bc1e80bda1]
    [33m[1m│ [22m[39m  OrdinaryDiffEqDefault [50262376-6c5a-4cf5-baba-aaf4f84d72d7]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqShooting [ed55bfe0-3725-4db6-871e-a1dc9f42a757]
    [33m[1m│ [22m[39m  OrdinaryDiffEqRosenbrock [43230ef6-c299-4910-a778-202eb28ce4ce]
    [33m[1m│ [22m[39m  JumpProcesses [ccbc3e58-028d-4f4c-8cd5-9ae44345cda5]
    [33m[1m│ [22m[39m  SteadyStateDiffEq [9672c7b4-1e72-59bd-8a11-6ac3964bc41f]
    [33m[1m│ [22m[39m  OrdinaryDiffEqAdamsBashforthMoulton [89bda076-bce5-4f1c-845f-551c83cdda9a]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExplicitRK [9286f039-9fbf-40e8-bf65-aa933bdc4db0]
    [33m[1m│ [22m[39m  OrdinaryDiffEqCore [bbf590c4-e513-4bbe-9b18-05decba2e5d8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqCoreEnzymeCoreExt [ca1c724a-f4aa-55ef-b8e4-2f05449449ac]
    [33m[1m│ [22m[39m  OrdinaryDiffEqPDIRK [5dd0a6cf-3d4b-4314-aa06-06d4e299bc89]
    [33m[1m│ [22m[39m  MATExt [5e726ecd-5b00-51ec-bc99-f7ee9de03178]
    [33m[1m│ [22m[39m  NonlinearSolveNLsolveExt [ae262b1c-8c8a-50b1-9ef3-b8fcfb893e74]
    [33m[1m│ [22m[39m  OrdinaryDiffEqStabilizedRK [358294b1-0aab-51c3-aafe-ad5ab194a2ad]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSSPRK [669c94d9-1f4b-4b64-b377-1aa079aa2388]
    [33m[1m│ [22m[39m  DelayDiffEq [bcd4f6db-9728-5f36-b5f7-82caef46ccdb]
    [33m[1m│ [22m[39m  DifferentialEquations [0c46a032-eb83-5123-abaf-570d42b7fbaa]
    [33m[1m│ [22m[39m  NonlinearSolveBaseSparseArraysExt [8494477e-8a74-521a-b11a-5a22161b1bc8]
    [33m[1m│ [22m[39m  PlotsExt [e73c9e8f-3556-58c3-b67e-c4596fa67ff1]
    [33m[1m│ [22m[39m  LinearSolveBandedMatricesExt [9522afde-9e86-5396-abc8-24b7312356fe]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqFIRK [85d9eb09-370e-4000-bb32-543851f73618]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqMIRK [1a22d4ce-7765-49ea-b6f2-13c8438986a6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqRKN [af6ede74-add8-4cfd-b1df-9a4dbb109d7a]
    [33m[1m│ [22m[39m  LinearSolve [7ed4a6bd-45f5-4d41-b270-4a48e9bafcae]
    [33m[1m│ [22m[39m  OrdinaryDiffEqQPRK [04162be5-8125-4266-98ed-640baecc6514]
    [33m[1m│ [22m[39m  RecursiveArrayToolsForwardDiffExt [14203109-85fb-5f77-af23-1cb7d9032242]
    [33m[1m│ [22m[39m  DiffEqBaseSparseArraysExt [4131c53f-b1d6-5635-a7a3-57f6f930b644]
    [33m[1m│ [22m[39m  TransducersLazyArraysExt [cdbecb60-77cf-500a-86c2-8d8bbf22df88]
    [33m[1m│ [22m[39m  NonlinearSolveBaseBandedMatricesExt [f3d6eb4f-59b9-5696-a638-eddf66c7554e]
    [33m[1m│ [22m[39m  NonlinearSolveFirstOrder [5959db7a-ea39-4486-b5fe-2dd0bf03d60d]
    [33m[1m│ [22m[39m  SciMLOperatorsStaticArraysCoreExt [a2df0a61-553a-563b-aed7-0ce21874eb58]
    [33m[1m│ [22m[39m  Sundials [c3572dad-4567-51f8-b174-8c6c989267f4]
    [33m[1m│ [22m[39m  RecursiveArrayToolsFastBroadcastExt [42296aa8-c874-5f57-b5c1-8d6f5ebd5400]
    [33m[1m│ [22m[39m  SciMLBase [0bca4576-84f4-4d90-8ffe-ffa030f20462]
    [33m[1m│ [22m[39m  ForwardDiffExt [92c717c9-c1e5-53c1-ac59-0de8aab6796e]
    [33m[1m│ [22m[39m  LinearSolveFastAlmostBandedMatricesExt [f94f2e43-4c39-5f8d-ab9c-7017feb07ff4]
    [33m[1m│ [22m[39m  OrdinaryDiffEqHighOrderRK [d28bc4f8-55e1-4f49-af69-84c1a99f0f58]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLowStorageRK [b0944070-b475-4768-8dec-fb6eb410534d]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSymplecticRK [fa646aed-7ef9-47eb-84c4-9443fc8cbfa8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqStabilizedIRK [e3e12d00-db14-5390-b879-ac3dd2ef6296]
    [33m[1m│ [22m[39m  FMIImport [9fcbc62e-52a0-44e9-a616-1359a0008194]
    [33m[1m│ [22m[39m  OrdinaryDiffEqLowOrderRK [1344f307-1e59-4825-a18e-ace9aa3fa4c6]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExponentialRK [e0540318-69ee-4070-8777-9e2de6de23de]
    [33m[1m│ [22m[39m  OrdinaryDiffEqDifferentiation [4302a76b-040a-498a-8c04-15b101fed76b]
    [33m[1m│ [22m[39m  OrdinaryDiffEqNonlinearSolve [127b3ac7-2247-4354-8eb6-78cf4e7c58e8]
    [33m[1m│ [22m[39m  SparseDiffToolsPolyesterExt [9f049cbb-7c7d-5dfe-91f7-cf323d5306ff]
    [33m[1m│ [22m[39m  OrdinaryDiffEqSDIRK [2d112036-d095-4a1e-ab9a-08536f3ecdbf]
    [33m[1m│ [22m[39m  LinearAlgebraExt [ef8e1453-9c17-56fe-886b-405471570bc8]
    [33m[1m│ [22m[39m  LineSearch [87fe0de2-c867-4266-b59a-2f0a94fc965b]
    [33m[1m│ [22m[39m  SciMLBaseChainRulesCoreExt [4676cac9-c8e0-5d6e-a4e0-e3351593cdf5]
    [33m[1m│ [22m[39m  OrdinaryDiffEqExtrapolation [becaefa8-8ca2-5cf9-886d-c06f3d2bd2c4]
    [33m[1m│ [22m[39m  OrdinaryDiffEqVerner [79d7bb75-1356-48c1-b8c0-6832512096c2]
    [33m[1m│ [22m[39m  SimpleNonlinearSolveChainRulesCoreExt [073a8d7d-86ee-5d75-9348-f9bf6155b014]
    [33m[1m│ [22m[39m  DiffEqCallbacks [459566f4-90b8-5000-8ac3-15dfb0a30def]
    [33m[1m│ [22m[39m  FMI [14a09403-18e3-468f-ad8a-74f8dda2d9ac]
    [33m[1m│ [22m[39m  BangBang [198e06fe-97b7-11e9-32a5-e1d131e6ad66]
    [33m[1m│ [22m[39m  DiffEqBaseDistributionsExt [24f3332a-0dc5-5d65-94b6-25e75cab9690]
    [33m[1m│ [22m[39m  SciMLOperators [c0aeaf25-5076-4817-a8d5-81caf7dfa961]
    [33m[1m│ [22m[39m  FMIBase [900ee838-d029-460e-b485-d98a826ceef2]
    [33m[1m│ [22m[39m  RecursiveArrayTools [731186ca-8d62-57ce-b412-fbd966d074cd]
    [33m[1m│ [22m[39m  FMIExport [31b88311-cab6-44ed-ba9c-fe5a9abbd67a]
    [33m[1m│ [22m[39m  BoundaryValueDiffEqCore [56b672f2-a5fe-4263-ab2d-da677488eb3a]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFeagin [101fe9f7-ebb6-4678-b671-3a81e7194747]
    [33m[1m│ [22m[39m  StochasticDiffEq [789caeaf-c7a9-5a7d-9973-96adeb23e2a0]
    [33m[1m│ [22m[39m  DiffEqBase [2b5f629d-d688-5b77-993f-72d75c75574e]
    [33m[1m│ [22m[39m  BangBangStaticArraysExt [a9f1882a-14fa-573e-a12d-824431257a23]
    [33m[1m│ [22m[39m  FMIZooExt [0fe4e21f-c175-5a0f-899f-abb2d776b1a2]
    [33m[1m│ [22m[39m  RecursiveArrayToolsSparseArraysExt [73e54eaf-3344-511d-b088-1ac5413eca63]
    [33m[1m│ [22m[39m  BangBangChainRulesCoreExt [47e8a63d-7df8-5da4-81a4-8f5796ea640c]
    [33m[1m│ [22m[39m  LinearSolveRecursiveArrayToolsExt [04950c4b-5bc4-5740-952d-02d2c1eb583a]
    [33m[1m│ [22m[39m  TransducersReferenceablesExt [befac7fd-b390-5150-b72a-6269c65d7e1f]
    [33m[1m│ [22m[39m  SciMLJacobianOperators [19f34311-ddf3-4b8b-af20-060888a46c0e]
    [33m[1m│ [22m[39m  NonlinearSolveBaseLineSearchExt [a65b7766-7c26-554a-8b8d-165d7f96f890]
    [33m[1m│ [22m[39m  DiffEqNoiseProcess [77a26b50-5914-5dd7-bc55-306e6241c503]
    [33m[1m│ [22m[39m  TransducersAdaptExt [9144d9d9-84fa-5f34-a63a-3acddca89462]
    [33m[1m│ [22m[39m  DiffEqBaseUnitfulExt [aeb06bb4-539b-5a1b-8332-034ed9f8ca66]
    [33m[1m│ [22m[39m  UnitfulExt [8d0556db-720e-519a-baed-0b9ed79749be]
    [33m[1m│ [22m[39m  NonlinearSolveBaseLinearSolveExt [3d4538b4-647b-544e-b0c2-b52d0495c932]
    [33m[1m│ [22m[39m  OrdinaryDiffEqNordsieck [c9986a66-5c92-4813-8696-a7ec84c806c8]
    [33m[1m│ [22m[39m  OrdinaryDiffEqFIRK [5960d6e9-dd7a-4743-88e7-cf307b64f125]
    [33m[1m│ [22m[39m  NonlinearSolveBaseDiffEqBaseExt [a0bd8381-04c7-5287-82b0-0bf1e59008be]
    [33m[1m│ [22m[39m  SimpleNonlinearSolve [727e6d20-b764-4bd8-a329-72de5adea6c7]
    [33m[1m│ [22m[39m  NonlinearSolveBase [be0214bd-f91f-a760-ac4e-3421ce2b2da0]
    [33m[1m│ [22m[39m  OrdinaryDiffEqIMEXMultistep [9f002381-b378-40b7-97a6-27a27c83f129]
    [33m[1m│ [22m[39m  MicroCollections [128add7d-3638-4c79-886c-908ea0c25c34]
    [33m[1m│ [22m[39m  SymbolicIndexingInterface [2efcf032-c050-4f8e-a9bb-153293bab1f5]
    [33m[1m│ [22m[39m  DatesExt [0361c7f5-3687-5641-8bd2-a1de0c64d1ed]
    [33m[1m│ [22m[39m  SciMLOperatorsSparseArraysExt [9985400b-97ec-5583-b534-4f70b643bcf7]
    [33m[1m│ [22m[39m  BoundaryValueDiffEq [764a87c0-6b3e-53db-9096-fe964310641d]
    [33m[1m│ [22m[39m  BangBangTablesExt [476361b5-ac10-5c09-8bec-30d098a22a5b]
    [33m[1m└ [22m[39m[90m@ Pkg.API C:\hostedtoolcache\windows\julia\1.10.7\x64\share\julia\stdlib\v1.10\Pkg\src\API.jl:1279[39m
    

    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mPrecompiling FMIZooExt [0fe4e21f-c175-5a0f-899f-abb2d776b1a2]
    

### Simulation setup

Next, the start time and end time of the simulation are set.


```julia
tStart = 0.0
tStop = 1.0
tSave = collect(tStart:tStop)
```




    2-element Vector{Float64}:
     0.0
     1.0



### Import FMU

In the next lines of code the FMU model from *FMIZoo.jl* is loaded and the information about the FMU is shown.


```julia
# we use an FMU from the FMIZoo.jl
# just replace this line with a local path if you want to use your own FMU
pathToFMU = get_model_filename("IO", "Dymola", "2022x")

fmu = loadFMU(pathToFMU)
info(fmu)
```

    #################### Begin information for FMU ####################
    	Model name:			IO
    	FMI-Version:			2.0
    	GUID:				{889089a6-481b-41a6-a282-f6ce02a33aa6}
    	Generation tool:		Dymola Version 2022x (64-bit), 2021-10-08
    	Generation time:		2022-05-19T06:53:52Z
    	Var. naming conv.:		structured
    	Event indicators:		4
    	Inputs:				3

    
    		352321536 ["u_real"]
    		352321537 ["u_boolean"]
    		352321538 ["u_integer"]
    	Outputs:			3
    		335544320 ["y_real"]
    		335544321 ["y_boolean"]
    		335544322 ["y_integer"]
    	States:				0
    	Parameters:			5
    		16777216 ["p_real"]
    		16777217 ["p_integer"]
    		16777218 ["p_boolean"]
    		16777219 ["p_enumeration"]
    		134217728 ["p_string"]
    	Supports Co-Simulation:		true
    		Model identifier:	IO
    		Get/Set State:		true
    		Serialize State:	true
    		Dir. Derivatives:	true
    		Var. com. steps:	true
    		Input interpol.:	true
    		Max order out. der.:	1
    	Supports Model-Exchange:	true
    		Model identifier:	IO
    		Get/Set State:		true
    		Serialize State:	true
    		Dir. Derivatives:	true
    ##################### End information for FMU #####################
    

### Option A: Integrated parameterization feature of *FMI.jl*
If you are using the commands for simulation integrated in *FMI.jl*, the parameters and initial conditions are set at the correct locations during the initialization process of your FMU. This is the recommended way of parameterizing your model, if you don't have very uncommon requirements regarding initialization.


```julia
dict = Dict{String, Any}()
dict
```




    Dict{String, Any}()



### Option B: Custom parameterization routine
If you have special requirements for initialization and parameterization, you can write your very own parameterization routine.

### Instantiate and Setup FMU

Next it is necessary to create an instance of the FMU. This is achieved by the command `fmiInstantiate!()`.


```julia
c = fmi2Instantiate!(fmu; loggingOn=true)
```




    FMU:            IO
        InstanceName:   IO
        Address:        Ptr{Nothing} @0x000001db0c96c420
        State:          0
        Logging:        true
        FMU time:       -Inf
        FMU states:     nothing



In the following code block, start and end time for the simulation is set by the `fmiSetupExperiment()` command.


```julia
fmi2SetupExperiment(c, tStart, tStop)
```




    0x00000000



### Parameterize FMU

In this example, for each data type (`real`, `boolean`, `integer` and `string`) a corresponding input or parameter is selected. From here on, the inputs and parameters will be referred to as parameters for simplicity.


```julia
params = ["p_real", "p_boolean", "p_integer", "p_string"]
```




    4-element Vector{String}:
     "p_real"
     "p_boolean"
     "p_integer"
     "p_string"



At the beginning we want to display the initial state of these parameters, for which the FMU must be in initialization mode. The next function `fmiEnterInitializationMode()` informs the FMU to enter the initialization mode. Before calling this function, the variables can be set. Furthermore, `fmiSetupExperiment()` must be called at least once before calling `fmiEnterInitializationMode()`, in order that the start time is defined.


```julia
fmi2EnterInitializationMode(c)
```




    0x00000000



The initial state of these parameters are displayed with the function `getValue()`.


```julia
getValue(c, params)
```




    4-element Vector{Any}:
     0.0
     0
     0
      "Hello World!"



The initialization mode is terminated with the function `fmi2ExitInitializationMode()`. (For the model exchange FMU type, this function switches off all initialization equations, and enters the event mode implicitly.)


```julia
fmi2ExitInitializationMode(c)
```




    0x00000000



In the next step, a function is defined that generates a random value for each parameter. For the parameter `p_string` a random number is inserted into the string. All parameters are combined to a tuple and output.


```julia
function generateRandomNumbers()
    rndReal = 100 * rand()
    rndBoolean = rand() > 0.5
    rndInteger = round(Integer, 100 * rand())
    rndString = "Random number $(100 * rand())!"

    return rndReal, rndBoolean, rndInteger, rndString
end
```




    generateRandomNumbers (generic function with 1 method)



The previously defined function is called and the results are displayed in the console.


```julia
paramsVal = generateRandomNumbers()
```




    (99.71195395748381, true, 49, "Random number 27.25374833040084!")



#### First variant

To show the first variant, it is necessary to terminate and reset the FMU instance. Then, as before, the setup command must be called for the FMU. 


```julia
fmi2Terminate(c)
fmi2Reset(c)
fmi2SetupExperiment(c, tStart, tStop)
```




    0x00000000



In the next step it is possible to set the parameters for the FMU. With the first variant it is quickly possible to set all parameters at once. Even different data types can be set with only one command. The command `setValue()` selects itself which function is chosen for which data type.  As long as the output of the function gives the status code 0, setting the parameters has worked.


```julia
setValue(c, params, collect(paramsVal))
```




    4-element Vector{UInt32}:
     0x00000000
     0x00000000
     0x00000000
     0x00000000



After setting the parameters, it can be checked whether the corresponding parameters were set correctly. For this the function `getValue()` can be used as above. To be able to call the function `getValue()` the FMU must be in initialization mode.


```julia
fmi2EnterInitializationMode(c)
# getValue(c, params)
fmi2ExitInitializationMode(c)
```




    0x00000000



Now the FMU has been initialized correctly, the FMU can be simulated. The `simulate()` command is used for this purpose. It must be pointed out that the keywords `instantiate=false`, `setup=false` must be set. The keyword `instantiate=false` prevents the simulation command from creating a new FMU instance, otherwise our parameterization will be lost. The keyword `setup=false` prevents the FMU from calling the initialization mode again. The additionally listed keyword `freeInstance=false` prevents that the instance is removed after the simulation. This is only needed in this example, because we want to continue working on the created instance. Another keyword is the `recordValues=parmas[1:3]`, which saves: `p_real`, `p_boolean` and `p_integer` as output. It should be noted that the `simulate()` function is not capable of outputting string values, so `p_string` is omitted.


```julia
simData = simulate(c, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false, freeInstance=false, terminate=false, reset=false)
```




    Model name:
    	IO
    Success:
    	true
    f(x)-Evaluations:
    	In-place: 0
    	Out-of-place: 0
    Jacobian-Evaluations:
    	∂ẋ_∂p: 0
    	∂ẋ_∂x: 0
    	∂ẋ_∂u: 0
    	∂y_∂p: 0
    	∂y_∂x: 0
    	∂y_∂u: 0
    	∂e_∂p: 0
    	∂e_∂x: 0
    	∂e_∂u: 0
    	∂xr_∂xl: 0
    Gradient-Evaluations:
    	∂ẋ_∂t: 0
    	∂y_∂t: 0
    	∂e_∂t: 0
    Callback-Evaluations:
    	Condition (event-indicators): 0
    	Time-Choice (event-instances): 0
    	Affect (event-handling): 0
    	Save values: 0
    	Steps completed: 0
    Values [2]:
    	0.0	(99.71195395748381, 1.0, 49.0)
    	1.0	(99.71195395748381, 1.0, 49.0)
    Events [0]:
    



#### Second variant

To show the second variant, it is necessary to terminate and reset the FMU instance. Then, as before, the setup command must be called for the FMU. 


```julia
fmi2Terminate(c)
fmi2Reset(c)
fmi2SetupExperiment(c, tStart, tStop)
```




    0x00000000



To make sure that the functions work it is necessary to generate random numbers again. As shown already, we call the defined function `generateRandomNumbers()` and output the values.


```julia
rndReal, rndBoolean, rndInteger, rndString = generateRandomNumbers()
```




    (63.821182015235024, true, 98, "Random number 38.18358553733713!")



In the second variant, the value for each data type is set separately by the corresponding command. By this variant one has the maximum control and can be sure that also the correct data type is set. 


```julia
fmi2SetReal(c, "p_real", rndReal)
fmi2SetBoolean(c, "p_boolean", rndBoolean)
fmi2SetInteger(c, "p_integer", rndInteger)
fmi2SetString(c, "p_string", rndString)
```




    0x00000000



To illustrate the functionality of the parameterization with the separate functions, the corresponding get function can be also called separately for each data type:
* `fmi2SetReal()` &#8660; `fmi2GetReal()`
* `fmi2SetBoolean()` &#8660; `fmi2GetBoolean()`
* `fmi2SetInteger()` &#8660; `fmi2GetInteger()`
* `fmi2SetString()` &#8660; `fmi2GetString()`.

As before, the FMU must be in initialization mode.


```julia
fmi2EnterInitializationMode(c)
# fmi2GetReal(c, "u_real")
# fmi2GetBoolean(c, "u_boolean")
# fmi2GetInteger(c, "u_integer")
# fmi2GetString(c, "p_string")
fmi2ExitInitializationMode(c)
```




    0x00000000



From here on, you may want to simulate the FMU. Please note, that with the default `executionConfig`, it is necessary to prevent a new instantiation using the keyword `instantiate=false`. Otherwise, a new instance is allocated for the simulation-call and the parameters set for the previous instance are not transfered.


```julia
simData = simulate(c, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false)
```




    Model name:
    	IO
    Success:
    	true
    f(x)-Evaluations:
    	In-place: 0
    	Out-of-place: 0
    Jacobian-Evaluations:
    	∂ẋ_∂p: 0
    	∂ẋ_∂x: 0
    	∂ẋ_∂u: 0
    	∂y_∂p: 0
    	∂y_∂x: 0
    	∂y_∂u: 0
    	∂e_∂p: 0
    	∂e_∂x: 0
    	∂e_∂u: 0
    	∂xr_∂xl: 0
    Gradient-Evaluations:
    	∂ẋ_∂t: 0
    	∂y_∂t: 0
    	∂e_∂t: 0
    Callback-Evaluations:
    	Condition (event-indicators): 0
    	Time-Choice (event-instances): 0
    	Affect (event-handling): 0
    	Save values: 0
    	Steps completed: 0
    Values [2]:
    	0.0	(63.821182015235024, 1.0, 98.0)
    	1.0	(63.821182015235024, 1.0, 98.0)
    Events [0]:
    



### Unload FMU

The FMU will be unloaded and all unpacked data on disc will be removed.


```julia
unloadFMU(fmu)
```

### Summary

Based on this tutorial it can be seen that there are two different variants to set and get parameters.These examples should make it clear to the user how parameters can also be set with different data types. As a small reminder, the sequence of commands for the manual parameterization of an FMU is summarized again. 

`loadFMU()` &#8594; `fmiInstantiate!()` &#8594; `fmiSetupExperiment()` &#8594; `fmiSetXXX()` &#8594; `fmiEnterInitializationMode()` &#8594; `fmiGetXXX()` &#8594; `fmiExitInitializationMode()` &#8594; `simualte()` &#8594; `unloadFMU()`

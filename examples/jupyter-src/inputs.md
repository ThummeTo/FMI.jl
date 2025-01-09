# Simulate an FMU with inputs
Tutorial by Tobias Thummerer

🚧 This tutorial is under revision and will be replaced by an up-to-date version soon 🚧

## License


```julia
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.
```

## Introduction to the example
This example shows how to add custom inputs to a FMU, that are used during simulation.

## Other formats
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/inputs.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/inputs.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/inputs.md) corresponding to the notebook.  

## Code section


```julia
# imports
using FMI
using FMIZoo
using Plots
using DifferentialEquations
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
    

    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mModule DatesExt with build ID ffffffff-ffff-ffff-0000-00c0f07be09d is missing from the cache.
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
    

    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mPrecompiling PlotsExt [e73c9e8f-3556-58c3-b67e-c4596fa67ff1]
    

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
    

    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mPrecompiling DifferentialEquations [0c46a032-eb83-5123-abaf-570d42b7fbaa]
    

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
    

    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mPrecompiling DifferentialEquationsFMIExt [232470a1-1d28-551b-8e3b-d6141e70703a]
    

### Simulation setup

Next, the start time and end time of the simulation are set. Finally, a step size is specified to store the results of the simulation at these time steps.


```julia
tStart = 0.0
tStep = 0.01
tStop = 8.0
tSave = tStart:tStep:tStop
```




    0.0:0.01:8.0



### Import FMU

Next, the FMU model from *FMIZoo.jl* is loaded.


```julia
# we use an FMU from the FMIZoo.jl
fmu = loadFMU("SpringPendulumExtForce1D", "Dymola", "2022x"; type=:ME) # load FMU in ME-Mode ("Model Exchange")
```




    Model name:	SpringPendulumExtForce1D
    Type:		0



#### Simulate as Model-Exchange

In the function `simulate()` the FMU is simulated with an adaptive step size but with fixed save points `tSave`. In addition, the start and end time are specified. Note, that the dynamics of the input variables are not considered by the steps ize control of the solver, so it is highly recommended to limit the solver step size with the keyword argument `dtmax` if the input is more dynamic than the system.


```julia
# input function format "t", dependent on `t` (time)
function extForce_t(t::Real, u::AbstractArray{<:Real})
    u[1] = sin(t)
end 

# simulate while setting inputs
data_extForce_t = simulate(fmu, (tStart, tStop);                 # FMU, start and stop time
                          solver = Tsit5(),
                          saveat=tSave,                         # timepoints for the ODE solution to be saved
                          inputValueReferences=["extForce"],    # the value references that should be set (inputs)
                          inputFunction=extForce_t,             # the input function to be used
                          dtmax=1e-2,                           # limit max step size to capture inputs
                          showProgress=false)                   # disable progress bar
plot(data_extForce_t)
```




    
![svg](inputs_files/inputs_9_0.svg)
    




```julia
# input function format "cxt", dependent on `c` (component), `x` (state) and `t` (time)
function extForce_cxt(c::Union{FMU2Component, Nothing}, x::Union{AbstractArray{<:Real}, Nothing}, t::Real, u::AbstractArray{<:Real})
    x1 = 0.0
    if x != nothing # this check is important, because inputs may be needed before the system state is known
        x1 = x[1] 
    end
    u[1] = sin(t) * x1
    nothing
end 

# simulate while setting inputs
data_extForce_cxt = simulate(fmu, (tStart, tStop); saveat=tSave, inputValueReferences=["extForce"], inputFunction=extForce_cxt, dtmax=1e-2, showProgress=false)
plot(data_extForce_cxt)
```




    
![svg](inputs_files/inputs_10_0.svg)
    



### Unload FMU

After plotting the data, the FMU is unloaded and all unpacked data on disc is removed.


```julia
unloadFMU(fmu)
```
#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
IN PROGRESS:
The mutable struct representing an FMU in the FMI 3.0 Standard.
Also contains the paths to the FMU and ZIP folder as well als all the FMI 3.0 function pointers
"""
mutable struct FMU3

    # Constructor
    fmu3() = new()
end

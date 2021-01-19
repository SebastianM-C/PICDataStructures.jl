# PICDataStructures

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://SebastianM-C.github.io/PICDataStructures.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://SebastianM-C.github.io/PICDataStructures.jl/dev)
[![Build Status](https://github.com/SebastianM-C/PICDataStructures.jl/workflows/CI/badge.svg)](https://github.com/SebastianM-C/PICDataStructures.jl/actions)
[![Coverage](https://codecov.io/gh/SebastianM-C/PICDataStructures.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SebastianM-C/PICDataStructures.jl)
![https://www.tidyverse.org/lifecycle/#experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)

This pakage provides data structures (and corresponding traits) useful when dealing with Particle-in-Cell (PIC) simulations.
In simple terms, in these kind of simulations we solve Maxwell's equations for an electromagnetic field coupled with the equations of motion for a large number of particles in a self-consistent way.

When dealing with field and particle quantities we have scalar quantities (e.g. number density) or vector quantities (e.g. electric field). This is expressed in this package with the `scalarness` trait.

In a large majority of PIC codes, the Maxwell equations are solved using a FDTD method which
discretizes the electric and magnetic fields on a lattice grid (such as the Yee method which uses a staggered grid). Due this fact we have the fields defined only on specific positions on the grid (and interpolations are used in the solvers in order to get intermediary values).
This gives us an `Array{T,N}`-like structure for the fields, with `N` being 1,2,3 depending on the
diumensionality of the simulation.
In contrast, the particle trajectories are given by the solutions of an ODE system and thus they are continuous in the simulation domain. Thus we have a `Vector{T}`-like structure (one dimensional regardless of the dimensinoality of the simulation) for the data associated to the particles (e.g. linear momenta).
In this package this distinction is given by the `domain_discretization` trait.

The package provides the `ScalarField, ScalarVariable, VectorField, VectorVariable` types
which can be useful when storing data from PIC simulations.

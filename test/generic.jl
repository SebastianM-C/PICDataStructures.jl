using Test
using PICDataStructures
using LookingGlass: module_recursive_globals_names

@test isempty(detect_ambiguities(PICDataStructures))

@test all(isempty.(values(module_recursive_globals_names(
    PICDataStructures,
    constness=:nonconst,
    mutability=:all)
)))

using PICDataStructures
using Documenter

makedocs(;
    modules=[PICDataStructures],
    authors="Sebastian Micluța-Câmpeanu <m.c.sebastian95@gmail.com> and contributors",
    repo="https://github.com/SebastianM-C/PICDataStructures.jl/blob/{commit}{path}#L{line}",
    sitename="PICDataStructures.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://SebastianM-C.github.io/PICDataStructures.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/SebastianM-C/PICDataStructures.jl",
)

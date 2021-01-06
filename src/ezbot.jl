module ezbot

using Dates
using Formatting
using Indicators
using IterTools
using PyCall
using PyPlot
using ScikitLearn

const urllib3 = PyNULL()

function __init__()
    copy!(urllib3, pyimport("urllib3"))
end

urllib3.disable_warnings()

include("marketoverview.jl")
include("toplevel.jl")
include("midlevel.jl")
include("lowlevel.jl")

export client, ibtc, overlook, look, play

end




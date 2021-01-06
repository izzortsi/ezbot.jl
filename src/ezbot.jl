module ezbot

using Dates
using Formatting
using Indicators
using IterTools
using PyCall
using PyPlot
using ScikitLearn

const urllib3 = PyNULL()

include("marketoverview.jl")
include("toplevel.jl")
include("midlevel.jl")
include("lowlevel.jl")

function __init__()
    copy!(urllib3, pyimport("urllib3"))
    urllib3.disable_warnings()
end

export client, ibtc, overlook, look, play

end




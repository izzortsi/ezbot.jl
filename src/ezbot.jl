module ezbot

using Dates
using Formatting
using Indicators
using IterTools
using PyCall
using PyPlot
using ScikitLearn

const urllib3 = PyNULL()
#const client = PyNULL()
global client
const bnc = PyNULL()
const bws = PyNULL()
const ben = PyNULL()

function __init__()
    copy!(urllib3, pyimport("urllib3"))
    urllib3.disable_warnings()
    
    copy!(bnc, pyimport("binance.client"))
    copy!(bws, pyimport("binance.websockets"))
    copy!(ben, pyimport("binance.enums"))
end

include("marketoverview.jl")
include("toplevel.jl")
include("midlevel.jl")
include("lowlevel.jl")

export initialize, overlook, look, play

end




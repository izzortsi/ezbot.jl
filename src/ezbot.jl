module ezbot

using Dates
using Formatting
using Indicators
using IterTools
using PyCall
using PyPlot
using ScikitLearn

@sk_import preprocessing:MinMaxScaler
@sk_import neural_network:BernoulliRBM
@sk_import manifold:SpectralEmbedding

@pyimport binance.client as bnc
@pyimport binance.websockets as bws
@pyimport binance.enums as ben 

@pyimport urllib3

include("marketoverview.jl")
include("toplevel.jl")
include("midlevel.jl")
include("lowlevel.jl")

export client, ibtc, overlook, look, play

end




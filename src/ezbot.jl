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
urllib3.disable_warnings()

include("marketoverview.jl")
include("toplevel.jl")
include("midlevel.jl")
include("lowlevel.jl")

api_key = ""
api_secret = ""

#global ibtc, client
ibtc = 0.0012
client = bnc.Client(api_key, api_secret, Dict([:"verify" => false, :"timeout" => 90]))

pygui(true)

export client, ibtc, overlook, look, play

end




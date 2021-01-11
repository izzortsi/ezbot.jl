__precompile__(false)

module ezbot

    include("marketoverview.jl")
    include("toplevel.jl")
    include("midlevel.jl")
    include("lowlevel.jl")


    using Indicators
    using PyCall
    using Formatting
    using IterTools
    using ScikitLearn
    using PyPlot
    using Dates

    #ScikitLearn.Skcore.import_sklearn() = PyCall.pyimport_conda("sklearn", "scikit-learn")

    @sk_import preprocessing: MinMaxScaler
    @sk_import neural_network: BernoulliRBM
    @sk_import manifold: SpectralEmbedding

    @pyimport urllib3

    urllib3.disable_warnings()

    @pyimport binance.client as bnc
    @pyimport binance.websockets as bws
    @pyimport binance.enums as ben

    const client = PyNULL()

    global api_key, api_secret, initial_btc

    pygui(true)

    export init, client, initial_btc, olook, look, play

end

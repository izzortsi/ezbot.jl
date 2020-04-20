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

    ScikitLearn.Skcore.import_sklearn() = PyCall.pyimport_conda("sklearn", "scikit-learn")

    @sk_import preprocessing: MinMaxScaler
    @sk_import neural_network: BernoulliRBM
    @sk_import manifold: SpectralEmbedding


    @pyimport binance.client as bnc
    @pyimport binance.websockets as bws
    @pyimport binance.enums as ben

    api_key = ""
    api_secret = ""

    global ibtc, client
    ibtc= 0.0012
    client = bnc.Client(api_key, api_secret, Dict([:"verify" => false, :"timeout" =>90]))

    pygui(true)

    export client, ibtc, overlook, look, play




end

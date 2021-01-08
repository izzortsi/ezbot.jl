"""
function init(; key = "", secret = "", ibtc=0.0012)

inicia o client, opcionalmente com a API key e secret, que são necessárias pra acesso aos endpoints privados da API (i.e., pra fazer operações)
`ibtc` é quanto dinheiro (em bitcoins) você tá disposto a perder. o valor default é o mínimo da binance
"""
function init(; key = "", secret = "", ibtc=0.0012)

    #key, secret, ibtc = api_key, api_secret, initial_btc

    
    global initial_btc, api_key, api_secret

    api_key, api_secret, initial_btc = key, secret, ibtc

    copy!(client, bnc.Client(api_key, api_secret, Dict([:"verify" => false, :"timeout" =>90])))

end

"""
function look(; coin="ETHBTC", candlesize::String="5m", candlesize_::Int64=5, num::Int64=450, qty::Int64=1)
    calcula e mostra coisas de `coin`. `candlesize` é uma string cujos possiveis valores são

    1m
    3m
    5m
    15m
    30m
    1h
    2h
    4h
    6h
    8h
    12h
    1d
    3d
    1w
    1M
    
    com
    
    m -> minutes; h -> hours; d -> days; w -> weeks; M -> months

    `candlesize_` é um inteiro com o valor, em minutos, disso

    `num` é o numero de candles. na epoca que escrevi, tinha um máximo de 500 por request. então pra mais de 500 candles, ce deixa `num` em algum valor e pega multiplos desse valor com `qty`, ie, com `num` = 300 e `qty` = 2 ce vai pegar as 600 ultimas candles

"""
function look(; coin::String="ETHBTC", candlesize::String="5m", candlesize_::Int64=5, num=450, qty=1)

    BRBM, BRBMExtract, SpeClust, SpeClustLabels, X, data = train(coin=coin, candlesize=candlesize, candlesize_=candlesize_,num=num,qty=qty )

    specembd=(SpeClustLabels[:, 1]+SpeClustLabels[:, 2])./2
    factors =(SpeClustLabels[:, 1] - SpeClustLabels[:, 2])
    rsis14 = X[:, 5]./100

    #PyPlot.subplot()

    data_length = num*qty

    Mticks_interval = data_length ÷ 10
    #println(data_length," ", Mticks_interval)
    mticks_interval = data_length ÷ 50

    Mxticks = matplotlib.ticker.MultipleLocator(Mticks_interval)
    mxticks = matplotlib.ticker.MultipleLocator(mticks_interval)

    @assert (length(data[40:end, 5]) == length(factors) == length(specembd)) "Something went wrong in `look`"

    ax2 = PyPlot.subplot(411)
    ax2[:plot](data[40:end, 5],"k-",linewidth=0.9, label="closes")
    ax2[:set_title]("$(coin), $(candlesize)")
    ax2[:grid](true)
    ax2.xaxis.grid(true, which="both")
    ax2.xaxis.grid(which="minor", linestyle="--", alpha=0.5)
    ax2.xaxis.set_major_locator(Mxticks)
    ax2.xaxis.set_minor_locator(mxticks)
    ax2[:legend](loc="best")
    PyPlot.setp(ax2.get_xticklabels(), visible=false)


    ax3 = PyPlot.subplot(412, sharex=ax2)
    ax3[:set_title]("restricted boltzmann machine")
    ax3[:plot](BRBMExtract,label="RBM image", linewidth=0.9,alpha=0.7)
    ax3[:grid](true)
    ax3.xaxis.grid(true, which="both")
    ax3.xaxis.grid(which="minor", linestyle="--", alpha=0.5)
    ax3.xaxis.set_major_locator(Mxticks)
    ax3.xaxis.set_minor_locator(mxticks)
    ax3[:legend](loc="best")
    PyPlot.setp(ax3.get_xticklabels(), visible=false)


    ax4 = PyPlot.subplot(413, sharex=ax2)
    ax4[:set_title]("spectral embedding images")
    ax4[:plot](specembd,label="avg","k-",linewidth=1,alpha=0.7)
    ax4[:plot](SpeClustLabels[:, 1],label="img 1","r--",linewidth=0.9,alpha=0.7)
    ax4[:plot](SpeClustLabels[:, 2],label="img 2","b--",linewidth=0.9,alpha=0.7)
    ax4[:grid](true)
    ax4.xaxis.grid(true, which="both")
    ax4.xaxis.grid(which="minor", linestyle="--", alpha=0.5)
    ax4.xaxis.set_major_locator(Mxticks)
    ax4.xaxis.set_minor_locator(mxticks)
    ax4[:legend](loc="best")
    PyPlot.setp(ax4.get_xticklabels(), visible=false)


    ax5 = PyPlot.subplot(414, sharex=ax2)
    ax5[:plot](factors, label = "factors","m-",linewidth=0.9,alpha=0.7)
    ax5[:plot](rsis14, label = "rsi14","b-",linewidth=0.9,alpha=0.7)
    ax5[:grid](true)
    ax5.xaxis.grid(true, which="both")
    ax5.xaxis.grid(which="minor", linestyle="--", alpha=0.5)
    ax5.xaxis.set_major_locator(Mxticks)
    ax5.xaxis.set_minor_locator(mxticks)
    ax5[:legend](loc="best")
    #PyPlot.setp(ax5.get_xticklabels(), visible=false)
    return
end

"""
function play(; coin="ETHBTC", candlesize::String="5m",candlesize_::Int64=5,stop::Bool=false, bought::Bool=false, sqtd::Float64=0.0, inft::Float64=0.4, supt::Float64=0.6, alpha1::Float64=0.4, alpha2::Float64=0.1, beta1::Float64 = 0.09, beta2::Float64 = 0.2, γ::Float64=0.5)
    faz operações, tem que ver o que são esses parâmetros
"""
function play(; coin="ETHBTC", candlesize::String="5m",candlesize_::Int64=5,stop::Bool=false, bought::Bool=false, sqtd::Float64=0.0, inft::Float64=0.4, supt::Float64=0.6, alpha1::Float64=0.4, alpha2::Float64=0.1, beta1::Float64 = 0.09, beta2::Float64 = 0.2, γ::Float64=0.5)
    while stop == false
        try
            stop, bought, sqtd = operate(coin=coin, candlesize=candlesize, candlesize_=candlesize_, stop=stop, bought=bought, sqtd=sqtd, inft=inft, supt=supt, alpha1=alpha1, alpha2=alpha2, beta1=beta1,beta2=beta2, γ=γ)
        catch errow
            println(errow)
            sleep(10)
            stop, bought, sqtd = play(coin=coin, candlesize=candlesize, candlesize_=candlesize_, stop=stop, bought=bought, sqtd=sqtd, inft=inft, supt=supt, alpha1=alpha1, alpha2=alpha2, beta1=beta1,beta2=beta2, γ=γ)
        end
    end
    return stop, bought, sqtd
end

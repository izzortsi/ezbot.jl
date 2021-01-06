pygui(true)

function initialize(; api_key = "", api_secret = "", ibtc = 0.0012)
    #copy!(client, bnc.Client(api_key, api_secret, Dict([:"verify" => false, :"timeout" => 90])))
    global client
    client = bnc.Client(api_key, api_secret, Dict([:"verify" => false, :"timeout" => 90]))
end

"""
function look(; coin="EOSBTC", candlesize="5m", candlesize_=5, num=450, qty=1)
"""
function look(; coin="EOSBTC", candlesize="5m", candlesize_=5, num=450, qty=1)

    BRBM,BRBMExtract, SpeClust, SpeClustLabels, X, data = train(coin=coin, candlesize=candlesize, candlesize_=candlesize_,num=num,qty=qty )

    specembd=(SpeClustLabels[:, 1]+SpeClustLabels[:, 2])./2
    factors =(SpeClustLabels[:, 1] - SpeClustLabels[:, 2])
    rsis14 = X[:, 5]./100

    PyPlot.subplot()

    ax2 = PyPlot.subplot(411)
    ax2[:plot](data[40:end, 5],"k-",linewidth=0.9, label="closes")
    ax2[:set_title]("$(coin), $(candlesize)")

    ax3 = PyPlot.subplot(412)
    ax3[:plot](BRBMExtract,label="RBM image", linewidth=0.9,alpha=0.7)

    ax4 = PyPlot.subplot(413)
    ax4[:set_title]("spectral embedding images")
    ax4[:plot](specembd,label="avg","k-",linewidth=1,alpha=0.7)
    ax4[:plot](SpeClustLabels[:, 1],label="img 1","r--",linewidth=0.9,alpha=0.7)
    ax4[:plot](SpeClustLabels[:, 2],label="img 2","b--",linewidth=0.9,alpha=0.7)

    ax5 = PyPlot.subplot(414)
    ax5[:plot](factors, label = "factors","m-",linewidth=0.9,alpha=0.7)
    ax5[:plot](rsis14, label = "rsi14","b-",linewidth=0.9,alpha=0.7)

    ax2[:grid](true)
    ax2[:legend](loc="best")
    ax3[:grid](true)
    ax3[:legend](loc="best")
    ax4[:grid](true)
    ax4[:legend](loc="best")
    ax5[:grid](true)
    ax5[:legend](loc="best")
    return
end

"""
function play(; coin="EOSBTC", candlesize::String="5m",candlesize_::Int64=5,stop::Bool=false, bought::Bool=false, sqtd::Float64=0.0, inft::Float64=0.4, supt::Float64=0.6, alpha1::Float64=0.4, alpha2::Float64=0.1, beta1::Float64 = 0.09, beta2::Float64 = 0.2, γ::Float64=0.5)
"""
function play(; coin="EOSBTC", candlesize::String="5m",candlesize_::Int64=5,stop::Bool=false, bought::Bool=false, sqtd::Float64=0.0, inft::Float64=0.4, supt::Float64=0.6, alpha1::Float64=0.4, alpha2::Float64=0.1, beta1::Float64 = 0.09, beta2::Float64 = 0.2, γ::Float64=0.5)
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

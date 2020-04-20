using Indicators
using PyCall
using Formatting
using IterTools
using ScikitLearn
using PyPlot
using Dates


function centers(klines, n::Int64=3)
    num=length(klines[:,1])
    Cs=[]
    Cm=[]
    Ci=[]
    N=n
    for j in 1:num
        if j <= n
            push!(Cs, NaN); push!(Cm, NaN);push!(Ci, NaN);
        else
            cs = (sum(klines[j-(N-1):j, 3] .* klines[j-(N-1):j, 6])/sum(klines[j-(N-1):j, 6]))*((sum(klines[j-(N-1):j, 6])/(N))/maximum(klines[j-(N-1):j, 6]))
            ci = (sum(klines[j-(N-1):j, 4] .* klines[j-(N-1):j, 6])/sum(klines[j-(N-1):j, 6]))*((sum(klines[j-(N-1):j, 6])/(N))/maximum(klines[j-(N-1):j, 6]))
            cm = (sum(((klines[j-(N-1):j, 2] + klines[j-(N-1):j, 5]) ./2) .* klines[j-(N-1):j, 6])/sum(klines[j-(N-1):j, 6]))*((sum(klines[j-(N-1):j, 6])/(N))/maximum(klines[j-(N-1):j, 6]))
            maxv = ((sum(klines[j-(N-1):j, 6])/(N))/maximum(klines[j-(N-1):j, 6]))
            push!(Cs, cs/maxv); push!(Cm, cm/maxv);push!(Ci, ci/maxv);
        end
    end
    return [Cs Cm Ci]
end

function Vs(klines, n::Int64=7,m::Int64=14, α::Float64=0.085)
    num=length(klines[:,1])
    Vs1=[]
    Vs2=[]
    Vs3=[]
    N=n
    for j in 1:num
        nmom1 = 0
        dmom1 = 0
        nmom2 = 0
        dmom2 = 0
        if j <= m+1
            push!(Vs1, NaN); push!(Vs2, NaN); push!(Vs3, NaN)
        else
            for indice in 1:n

                 nmom1 += (klines[j-indice, 5] - klines[j-indice-1, 5])/(1+α)^(indice)
                 dmom1 += abs(klines[j-indice, 5] - klines[j-indice-1, 5])/(1+α)^(indice)
            end
            for indice in 1:m
                 nmom2 += (klines[j-indice, 5] - klines[j-indice-1, 5])/(1+α)^(indice)
                 dmom2 += abs(klines[j-indice, 5] - klines[j-indice-1, 5])/(1+α)^(indice)
            end
            push!(Vs1, nmom1/dmom1);push!(Vs2, nmom2/dmom2);push!(Vs3, nmom1/dmom1 - nmom2/dmom2);
        end
    end
    return [Vs1 Vs2 Vs3]
end

function mns(klines, n::Int64=7, m::Int64=14,α::Float64=0.085)
    num=length(klines[:,1])
    Mns1=[]
    Mns2=[]
    Mns3=[]
    N=n
    for j in 1:num
        if j <= m+1
            push!(Mns1, NaN); push!(Mns2, NaN); push!(Mns3, NaN)
        else
            mom1 = sum((klines[j-n:j, 5] - klines[j-n-1:j-1, 5]) )/sum(abs.(klines[j-n:j, 5] - klines[j-n-1:j-1, 5]))
            mom2 = sum((klines[j-m:j, 5] - klines[j-m-1:j-1, 5]) )/sum(abs.(klines[j-m:j, 5] - klines[j-m-1:j-1, 5]))
            mom3 = mom1 - mom2

            push!(Mns1, mom1); push!(Mns2, mom2);push!(Mns3, mom3)
        end
    end
    return [Mns1 Mns2 Mns3]
end

function getdata(; coin="BTCUSDT", candlesize="30m", candlesize_=30, num=300, qty=1)
     klines = Array{Float64, 2}(undef, 0, 7)
     fromts = floor(Int64,time()*1000)-1000
     for n in 1:qty
         kl = client[:get_klines](symbol=coin, interval = candlesize, startTime = fromts - candlesize_*60000*qty*num + (n-1)candlesize_*60000*num , endTime=fromts - candlesize_*60000*qty*num+ n*candlesize_*60000*num, limit=num)#fromts - (qty-n)*3*60000
            for i in 1:num
                row = kl[i, :]
                tba = [(convert(Float64,row[1]))/1000 parse(Float64,row[2]) parse(Float64,row[3]) parse(Float64,row[4]) parse(Float64,row[5]) parse(Float64, row[6]) (convert(Float64, row[7]))/1000]
                klines = vcat(klines, tba)
            end
     end
     return klines
end

function compute(data)

        O = data[:,2]
        H = data[:,3]
        L = data[:,4]
        C = data[:,5]
        V = data[:,6]


        rsis7 = rsi(C, n=7)[40:end]
        rsis14 = rsi(C, n=14)[40:end]

        momentums = zlema(momentum(C, n=1) .* data[:,6], n=7)[40:end]
        adxs = adx([H L C])[40:end,3]
        dip = adx([H L C])[40:end,1]
        dim = adx([H L C])[40:end,2]
        macds = macd(C)[40:end, 1]
        signal = macd(C)[40:end, 2]
        divergence = macd(C)[40:end, 3]
        atrs = atr([H L C], n=7)[40:end]



        prices = C[40:end]
        Cs = centers(data,3)[40:end,1]
        Cm = centers(data,3)[40:end,2]
        Ci = centers(data,3)[40:end,3]
        Css = exp.((Cs - Cm)./(Cm - Ci)).*(prices - Cm)

        Vss = Vs(data, 7, 14)[40:end, 3]
        Mns = mns(data, 7, 14)[40:end, 3]



        stochs1 = stoch([H L C], nK=7)[40:end, 1]
        stochs2 = stoch([H L C], nK=7)[40:end, 2]


        X = [ stochs1 stochs2 momentums rsis7 rsis14 Vss Mns dip dim adxs macds signal divergence atrs Css]

        return X
end

function train(; coin="BTCUSDT", candlesize="30m", candlesize_=30, num=300, qty=1)
    data = getdata(coin=coin, candlesize=candlesize, candlesize_=candlesize_,num=num, qty=qty )
    X = compute(data)

    scaler = MinMaxScaler()

    X = scaler[:fit_transform](X)

    nc = 2
    BRBM = BernoulliRBM(n_components=1)
    SpeClust = SpectralEmbedding(n_components = nc, random_state=1, affinity="rbf", gamma=0.0001)
    scaler1=MinMaxScaler()
    scaler2=MinMaxScaler()


    BRBMExtract_ = BRBM[:fit_transform](X)
    BRBMExtract = scaler1[:fit_transform](BRBMExtract_)

    SpeClustLabels_ = SpeClust[:fit_transform](X)
    SpeClustLabels = scaler2[:fit_transform](SpeClustLabels_)
    X = compute(data)

    return BRBM,BRBMExtract, SpeClust, SpeClustLabels, X, data
end

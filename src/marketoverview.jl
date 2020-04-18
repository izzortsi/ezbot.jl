function preselec(overdata, pct1, pct2)
    presel=[]
    for i in 1:length(overdata)
        #println(i)
        pc = float(overdata[i][:"priceChangePercent"])
        #println(pc)
        if pct1 <= pc <= pct2 #  && length(Njobs) < n_cores
            push!(presel, [overdata[i][:"symbol"] pc])
        end
    end
    return presel
end


function calculate(overdata,coins, rsi_, volume)
    out = Matrix(0,3)
    for i in 1:length(coins)
        #println(coins[i][1][end-2:end])
        if string(coins[i][1][end-2:end]) == "BTC"
            data = getdata(coin=coins[i][1], num=140, qty=1)
            O = data[:,2]
            H = data[:,3]
            L = data[:,4]
            C = data[:,5]
            V = data[:,6]
            rsi14 = rsi(C, n=14)[end]
            if rsi14 <= rsi_ && V[end] >=volume
                out = vcat(out, [coins[i][1] coins[i][2] rsi14] )
            end
        end
    end
    return out
end

function overlook(; pct1=-0.1, pct2=1.0,rsi_=50.0, volume=1200)

    overdata = client[:get_ticker]()
    presel = preselec(overdata,pct1, pct2)
    M = calculate(overdata, presel, rsi_, volume)
    println("symbol, %change, RSI14")
    return M

end

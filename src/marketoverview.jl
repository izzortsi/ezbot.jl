function preselec(overdata, pct1, pct2)
    presel=[]
    for i in 1:length(overdata)
        #println(i)
        pc = parse(Float64,(overdata[i][:"priceChangePercent"]))
        #println(pc)
        if pct1 <= pc <= pct2 #  && length(Njobs) < n_cores
            push!(presel, [overdata[i][:"symbol"] pc])
        end
    end
    return presel
end


function calculate(coins, rsi_, volume, warnings)
    out = Array{Float64, 2}(undef, 0, 3)
    for i in 1:length(coins)
        #println(coins[i][1][end-2:end])
        if string(coins[i][1][end-2:end]) == "BTC"
            #println(coins[i][1])
            #println("coins[i][1][end-2:end]")
            #println("coins[i][1][end-2:end]")
            data = nothing
            try
                data = getdata(coin=coins[i][1], num=140, qty=1)
            catch er
                if warnings == true
                    println("Something went wrong while getting the data from the symbol $(coins[i][1])")
                end
                continue
            end
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

"""
function olook(; pct1=-0.1, pct2=1.0,rsi_=50.0, volume=1200, warnings==false)
    mostra as coins cuja variação de preço tá entre `pct1` e `pct2`, RSI14 é menor que `rsi_` e volume maior que `volume`
"""
function olook(; pct1=-0.1, pct2=1.0,rsi_=50.0, volume=1200, warnings=false)

    overdata = client[:get_ticker]()
    presel = preselec(overdata,pct1, pct2)
    M = calculate(presel, rsi_, volume, warnings)
    println("symbol, %change, RSI14")
    return M
end

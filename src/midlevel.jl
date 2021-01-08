

function operate(; coin="EOSBTC", candlesize::String="15m",candlesize_::Int64=5, stop::Bool=false, bought::Bool=false, sqtd::Float64=0.0, inft::Float64=0.4, supt::Float64=0.6, alpha1::Float64=0.4, alpha2::Float64=0.08, beta1::Float64 = 0.28, beta2::Float64 = 0.28, γ::Float64=0.0)
    t0 = t1 = floor(Int64,time()*1000)

    global ticksize, stepsize
    ticksize = max(length(format(float(client[:get_symbol_info](symbol=coin)[:"filters"][1][:"tickSize"]), stripzeros=true))-2, 1)
    stepsize = max(length(format(float(client[:get_symbol_info](symbol=coin)[:"filters"][2][:"stepSize"]), stripzeros=true))-2, 1)

    #println(ticksize)
    #println(stepsize)

    border = 0
    bprice = 0
    sprice = 0

    while stop == false
        if (t1 - t0)%30000 == 0

            brm, BRBMExtract, spectemb, spectembimg, X, data = train(coin=coin, candlesize=candlesize, candlesize_=candlesize_,num=550,qty=1)
            avg = (spectembimg[:,1] + spectembimg[:,2])/2

            rsis = X[:, 5]./100
            if bought == false
                if rsis[end] <= inft && BRBMExtract[end] >= alpha1 && abs(spectembimg[end,1] - spectembimg[end,2]) >= beta1

                    try
                        bprice = parse(Float64,client[:get_ticker](symbol=coin)[:"lastPrice"])
                        qtty = parse(Float64, format(ibtc/bprice, precision=stepsize))
                        println(qtty)
                        border = client[:order_market_buy](symbol=coin, quantity=qtty, recvWindow=4000)
                        bprice = parse(Float64, border[:"price"])

                    catch er
                        println(qtty)

                        return println("Buy error. Is initial_btc properly set? Error: $(er)")
                    end

                    qtty = parse(Float64, format(qtty, precision=stepsize))
                    println("bought $(qtty)")

                    #colocar pra trocar bought pra true sss qtty for maior que o minimo pra vender
                    stop = false
                    bought = true

                    return stop, bought, qtty
                else
                    println("Waiting for proper conditions to buy. RSI: $(rsis[end]). Labels: $(BRBMExtract[end]), $(abs(spectembimg[end,1] - spectembimg[end,2])).")
                end
            else

                if rsis[end] >= supt && BRBMExtract[end] <= alpha2 && abs(spectembimg[end,1] - spectembimg[end,2]) >= beta2
                    try
                        sqtd = parse(Float64, format(sqtd, precision=stepsize))
                        sorder = client[:order_market_sell](symbol=coin, quantity=sqtd, recvWindow=4000)
                        sprice = parse(Float64, sorder[:"price"])
                    catch
                        println("Error. Is sqtd properly chosen?")
                    end

                    println("sold at $(sprice). Exiting.")

                    bought = true #mudei aqui pra true
                    stop = true
                    return stop, bought
                else
                    println("Waiting for proper conditions to sell. Coin: $(coin). Quantity: $(sqtd). Current RSI: $(rsis[end]). Labels: $(BRBMExtract[end]), $(abs(spectembimg[end,1] - spectembimg[end,2])).")
                end
            end
        end
    t1 = floor(Int64,time()*1000)
    end
end

using PyPlot

n = 100

function f(x)
    return x*x*x*x + 8 * x * x * x - 6 * x * x - 72 * x
end    

function makePlot(a, b)
    x = range(a; stop = b, length = n)
    y = [f(x[i]) for i=1:n]
    plot(x, y)
end

function checkUniModal(a, b)
    x = range(a; stop = b, length = n)
    y = [f(x[i]) for i=1:n]
    flag = false
    for i=2:n
        if y[i-1] < y[i]
            flag = true
        else
            if flag
                return false
            end
        end
    end
    return true
end

function findMinIter(a, b)
    x = range(a; stop = b, length = n)
    y = [f(x[i]) for i=1:n]
    minX = x[1]
    minY = y[1]
    for i=2:n
        if y[i] < minY
            minX = x[i]
            minY = y[i]
        end
    end
    return minX, minY
end

function findMinDi(a, b, eps)
    delta = eps / 2
    xs = []
    ys = []
    append!(xs, a)
    append!(ys, f(a))
    append!(xs, b)
    append!(ys, f(b))    
    while abs(b-a) > eps
        x1 = (a + b - delta) / 2
        x2 = (a + b + delta) / 2
        fx1 = f(x1)
        fx2 = f(x2)
        if fx1 > fx2
            a = x1
            append!(xs, a)
            append!(ys, f(a))
        else
            b = x2
            append!(xs, b)
            append!(ys, f(b))
        end
    end
    scatter(xs, ys, color="red")    
    x = (a + b) / 2
    y = f(x)
    return x, y
end
    
println(checkUniModal(-8, -4))        
println(checkUniModal(-8, 4))
    
a = -8
b = -4
eps = 0.000000000001
            
makePlot(a, b)
            
println(findMinIter(a, b))                
println(findMinDi(a, b, eps)) 

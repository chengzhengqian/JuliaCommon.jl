
module JuliaGnuplot

export @plot, @save, Gnuplot, @init
using JuliaCommon
# one need to start the emacs server and sock connection before using this package
# evalInEmacs("(buffer-name)")
# term="tgnuplot"
# command="plot x"
# sendCommandToEmacaTerm("tgnuplot", "plot x, x**2,x**3,cos(x-1)")


# the basic structure for the plot
struct Gnuplot
    data_dir :: String
    term_name :: String
end

function Gnuplot()
    Gnuplot(pwd(),"tgnuplot")
end

# x,y are 1d array

# x=linspace(0.0,10.0,100)
# y=sin.(x)
# gp=Gnuplot()
function plot(gp::Gnuplot,x,y;name="tmp.dat")
    x_=reshape(x,:)
    y_=reshape(y,:)
    if(length(x_)==length(y_))
        saveData(hcat(x_,y_),"$(gp.data_dir)/$(name)")
    end
    sendCommandToEmacaTerm(gp.term_name,"cd \'$(gp.data_dir)\'")
    sendCommandToEmacaTerm(gp.term_name,"set autoscale")
    sendCommandToEmacaTerm(gp.term_name,"plot \'$(name)\' w l")
end

#  we allow mulitple plot simutaneously
# data=[x,y]
function plot(gp::Gnuplot,data...;names=["tmp.dat"])
    n=length(data)
    if(n%2==0)
        n_pair=trunc(Int,n/2)
        sendCommandToEmacaTerm(gp.term_name,"cd '$(gp.data_dir)'")
        sendCommandToEmacaTerm(gp.term_name,"set autoscale")
        plot_command="plot "
        for i in 1:n_pair
            x=data[(i-1)*2+1]
            y=data[(i-1)*2+2]
            x_=reshape(x,:)
            y_=reshape(y,:)
            name=names[i]
            if(length(x_)==length(y_))
                saveData(hcat(x_,y_),"$(gp.data_dir)/$(name)")
            else
                error("data size is not matched!")
            end
            if(i!=1)
                plot_command*=" , "
            end            
            plot_command*="'$(name)' w l"
        end
        sendCommandToEmacaTerm(gp.term_name,plot_command)
    else
        error("expected even number of points in plot!")
    end    
end


# plot(gp,x,cos.(x)+sin.(x))
# plot(gp,x,sin.(x),x,x,x,x.*x;names=["1.dat","2.dat","3.dat"])

"""
    one need to set a gp to use this method
    """
macro plot(x,y)
    filename="$(string(x))~$(string(y)).dat"
    esc(quote
        JuliaGnuplot.plot(gp,$(x),$(y),name=$(filename))
        end)
end

macro plot(data...)
    n=length(data)
    if(n%2==0)
        n_pair=trunc(Int,n/2)
        filenames=["$(string(data[(i-1)*2+1]))~$(string(data[(i-1)*2+2])).dat" for i in 1:n_pair]
        para=Expr(:parameters,Expr(:kw,:names,filenames))
        expr=Expr(:call,:(JuliaGnuplot.plot),para,:gp,data...)
        return esc(expr)
    else
        error("expected even number of points")
    end    
end


function save(gp::Gnuplot,filename)
    sendCommandToEmacaTerm(gp.term_name,
"""cd '$(gp.data_dir)'
set term push
set term pngcairo
set output '$(filename)'   
replot
set term pop
set output
replot    
""")
end

macro save(filename)
    esc(
        :(JuliaGnuplot.save(gp,$(filename)))
    )
end

function initGnuplot(dir,name="tgnuplot")
    target_dir="$(pwd())/$(dir)"
    if (!isdir(target_dir))
        mkdir(target_dir)
    end
    Gnuplot(target_dir,name)
end

macro init(dir)
    esc(:(gp=JuliaGnuplot.initGnuplot($(dir))))
end

# dump(:(a.f(x)))
# n_pair=1
# @plot x (sin.(x)+x)
# x=linspace(0,10.0,100)
# y=sin.(x)
# @plot x y
# @plot x y.*y
# add  multiplot 
# dump(:(f(1,2;names=1)))
# data=[:x,:y]
# @plot x x x sin.(x) x x.*x
# x=linspace(-1,1,100)
# @plot x x.*x x sin.(x) x cos.(x) x tan.(x)
end

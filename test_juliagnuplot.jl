using Pkg
Pkg.add("Revise")
using Revise
using JuliaCommon
includet("./JuliaGnuplot.jl")
using NumericalIntegration
y=NumericalIntegration.cumul_integrate(x,x)
int=NumericalIntegration.cumul_integrate
gp=JuliaGnuplot.Gnuplot("$(pwd())/plot","tgnuplot")
x=linspace(0,1.0,1000)
mkdir("./plot")
JuliaGnuplot.@plot x cos.(x) x int(x,cos.(x))
JuliaGnuplot.save(gp,"test.png")
JuliaGnuplot.@save "test.png"
JuliaGnuplot.@plot x x.^3 x int(x, x.^3)

lorentz(a,b)=x->(b/( (x-a)^2+b^2))

x=linspace(0,1.0,1000)

JuliaGnuplot.@plot x 0.5*(lorentz(0.5,0.01).(x)+lorentz(0.51,0.01).(x)) x lorentz(0.505,0.01).(x)

dir="plot"
rm(dir,recursive=true)
JuliaGnuplot.initGnuplot(dir)
gp=0
JuliaGnuplot.@init dir
JuliaGnuplot.@plot x x

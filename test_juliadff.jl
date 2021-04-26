using Pkg
Pkg.add("Revise")
using Revise
includet("./JuliaDiff.jl")

JuliaDiff.wrapAsInput2(zeros(4))
JuliaDiff.wrapAsDiff2(zeros(4))
JuliaDiff.wrapAsInput2(zeros(4);is_first_order=true)
JuliaDiff.wrapAsDiff2(zeros(4);is_first_order=true)


a=JuliaDiff.wrapAsInput2(rand(4))
b=JuliaDiff.wrapAsInput2(rand(4))
JuliaDiff.get_dependency([a,b])
JuliaDiff.get_dependency([a,b];is_first_order=false)
a1=JuliaDiff.wrapAsInput2(rand(4);is_first_order=true)
b1=JuliaDiff.wrapAsInput2(rand(4);is_first_order=true)

JuliaDiff.cal_is_first_order([a,b])
JuliaDiff.cal_is_first_order([a,b1])
JuliaDiff.cal_is_first_order([a1,b])

function test_f(a,b)
    [sum(a)*sum(b.^2)]
end

JuliaDiff.callFunc2(test_f,a1,b)

JuliaDiff.@track test_f(a1,b)

includet("./JuliaDiff.jl")


a_=rand(4)
b_=rand(4)
a1=JuliaDiff.input1(a_)
a2=JuliaDiff.input(a_)
b1=JuliaDiff.input1(b_)
b2=JuliaDiff.input(b_)
c1=JuliaDiff.@track test_f(a1,b1)
c2=JuliaDiff.@track test_f(a2,b2)

JuliaDiff.∇(c1*1.0,a1,b1)
JuliaDiff.∇(c2*1.0,a2,b2)

a1+a2
a1+a1
a2+a2
a2-a1
a2-a2
a1-a2
a1[1]
a2[1]
sum([a2,a2])

a1*a2
a2*a2

a2^2
a1^2
cat([a1,a1])
a1/a1[1]


#  now, we test some complex function

using JuliaDiff

# we first test seonc order
u_=rand(1)
g0_=rand(9)

u=input(u_)
g0=input(g0_)
g0_flat=reshape([g0[i]  for i in 1:9],3,3)
@time p,d,g_new=one_band_N_3_symmetric_new(u,g0_flat)
g_new=cat(reshape(g_new,9))
∇(g_new,g0,g0)
one_band_N_3_flat(u,g0)=reshape(one_band_N_3_symmetric_new(u[1],reshape(g0,3,3))[3],9)
g_new_track=@track one_band_N_3_flat(u,g0)

Δg1=(g_new-g_new_track)

u1=input1(u_)
g01=input1(g0_)
g01_flat=reshape([g01[i]  for i in 1:9],3,3)
@time p1,d1,g1_new=one_band_N_3_symmetric_new(u1,g01_flat)
g1_new=cat(reshape(g1_new,9))

∇(g1_new,g01)-∇(g_new,g0)
∇(g1_new,u1)-∇(g_new,u)


func="one_band_N_3_symmetric_new" 
include("/home/chengzhengqian/Documents/research/zhengqian/discretized_action/generic_solver/src/gene/$(func).jl")

using JuliaDiff
a=input([1.0])
∇(a-1,a,a)


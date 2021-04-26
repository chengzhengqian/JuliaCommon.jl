using JuliaJIT                  # when develop the package, using Revise

#  we first copy the asm
#  this works 

jitFunc=JITFunc("arm_test")
JuliaJIT.@call jitFunc((Int64,Int64)=>Int64,4,2)
disassembleJIT(jitFunc,syntax="arm")

asm="
    add w0, w1, w0
    ret
"


jitFunc=JITFunc(asm,"jit1",mode="arm")
JuliaJIT.@call jitFunc((Int64,Int64)=>Int64,4,2)
disassembleJIT(jitFunc,syntax="arm")

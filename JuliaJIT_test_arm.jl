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
asm="
	mul w8, w1, w0
	add w9, w1, w0
	cmp w0, w1
	csel w0, w8, w9, gt
	ret
"

jitFunc=JITFunc(asm,"jit1",mode="arm")
JuliaJIT.@call jitFunc((Int64,Int64)=>Int64,4,5)
disassembleJIT(jitFunc,syntax="arm")

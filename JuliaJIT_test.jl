# jitFunc=JITFunc("./a.out")
# ccall(jitFunc.ptr,Int64,())
# remove(jitFunc)
# dump(:(1->2))
# dump(:(ccall(1,2)))
# dump(:(x.y))
# jitFunc=:jitFunc
# types=:((Int,)=>Int)
# args=[:x,:y]

using JuliaJIT                  # when develop the package, using Revise

using Revise
includet("./JuliaJIT.jl")       # so we can update the file

asm="
	mov \$0x1, %eax		;
        retq
"
jitFunc=JuliaJIT.JITFunc(asm, "jit2")
JuliaJIT.@call jitFunc(()=>Int64,)
# GC.gc()
# module JuliaJIT
# function JITFunc(filename)
#     size=Vector{Int64}(undef,1)
#     dir=@__DIR__
#     filename="$(dir)/gene/$(filename)"
#     ptr_func=ccall((:loadBinary,libpath),Ptr{UInt8},(Ptr{UInt8},Ptr{Int64}),pointer(filename),size)
#     result=JITFunc(ptr_func,size)
#     f(result)=(@async println("remove $(result)");remove(result))
#     finalizer(f,result)
#     print("this is new\n")
# end
# end

@call jitFunc(()=>Int64)
disassembleJIT(jitFunc)
remove(jitFunc)

# this first way
# JuliaJIT.compileAsm(asm,"jit1")
# jitFunc=JuliaJIT.JITFunc("jit1")
# dir=@__DIR__
# filename="jit1"
# const libpath="$(dir)/libexecfunc.so"
# size=Vector{Int64}(undef,1)
# ptr_func=ccall((:loadBinary,libpath),Ptr{UInt8},(Ptr{UInt8},Ptr{Int64}),pointer(filename),size)

ccall(jitFunc.ptr,Int64,())
remove(jitFunc)

asm="
    lea (%rdi,%rsi,1), %eax
    retq
"
jitFunc=JITFunc(asm, "./jit2")
@call jitFunc((Int64,Int64)=>Int64,1,4)

asm="
    movsd  (%rsi),%xmm0
    addsd %xmm0, %xmm0
    movsd  %xmm0,(%rdi)
    retq
"
# rdi for &a, rsi for &b
jitFunc=JITFunc(asm, "./jit3")
a=Vector{Float64}(undef,1)
b=Vector{Float64}(undef,1)
b[1]=1.2123123
@time @call jitFunc((Ptr{Float64},Ptr{Float64})=>Cvoid,a,b)
print(a[1])


# now we have nasm backend
# we need to add
# one should use ret instead
asm="
BITS 64
    movsd xmm0, qword [rsi]
    addsd xmm0, xmm0
    addsd xmm0, xmm0
    movq qword [rdi],  xmm0
    ret
"
jitFunc=JITFunc(asm, "./jit4";mode="nasm")
@time @call jitFunc((Ptr{Float64},Ptr{Float64})=>Cvoid,a,b)

# now, we add function to disassemble the code
# jitFunc.ptr
# unsafe_load(jitFunc.ptr,2)
function dumpJITFunction(jitFunc::JITFunc,filename)
    file=open(filename,"w")
    [write(file,unsafe_load(jitFunc.ptr,i)) for i in 1:jitFunc.size[1]]
    close(file)
end

# dumpJITFunction(jitFunc,"./test_dumpfunc.bin")

"""
syntax could be : att, intel,
see objdump for more information
"""
function disassembleJIT(jitFunc::JITFunc;syntax="att")
    filename="./czq_dump_jit.bin"
    dumpJITFunction(jitFunc::JITFunc,filename)
    run(`objdump -b binary -M $(syntax) -m i386:x86-64 -D $(filename)`)
end

disassembleJIT(jitFunc;syntax="intel")
asm="
BITS 64
    movsd xmm0, qword [rsi]
    mulsd xmm0, xmm0
    movq qword [rdi],  xmm0
    movsd xmm0, qword [rsi+8]
    addsd xmm0, xmm0
    addsd xmm0, xmm0
    movq qword [rdi+8],  xmm0
    ret
"
asm="
BITS 64
    movapd xmm0,  [rsi]
    addpd xmm0, xmm0
    movapd  [rdi],  xmm0
    ret
"
a=Vector{Float64}(undef,10)
b=Vector{Float64}(undef,10)
b[:]=rand(10)
# a
# b


jitFunc=JuliaJIT.JITFunc(asm, "./jit4";mode="nasm")
@time JuliaJIT.@call jitFunc((Ptr{Float64},Ptr{Float64})=>Cvoid,a,b)
disassembleJIT(jitFunc,syntax="intel")
using JuliaJIT                  # when develop the package, using Revise

asm="
BITS 64
    cmp rdi,10
    jg great
    call _g
    ret
great:
    call _g2
    ret
_g:
    add rdi,rdi
    mov rax,rdi
    ret
_g2:
    mov rax,rdi
    ret
"
jitFunc=JuliaJIT.JITFunc(asm, "./jit4";mode="nasm")

@time JuliaJIT.@call jitFunc((Int64,)=>Int64,10)
disassembleJIT(jitFunc,syntax="intel")

asm="
BITS 64
    mulsd xmm0,[rel _data]
    ret
_data:
    dq 1.5
"
jitFunc=JuliaJIT.JITFunc(asm, "./jit4";mode="nasm")
@time JuliaJIT.@call jitFunc((Float64,)=>Float64,20.1)
disassembleJIT(jitFunc,syntax="intel")

asm="
BITS 64
    comisd xmm0,xmm1
    ret
    jg great
    movsd xmm0, [rel _result1]
    ret
great:
    movsd xmm0, [rel _result2]
    ret
_result1:
    dq 1.0
_result2:
    dq 2.0
"
jitFunc=JuliaJIT.JITFunc(asm, "./jit4";mode="nasm")
@time JuliaJIT.@call jitFunc((Float64,Float64)=>Float64,3.0,4.0)
disassembleJIT(jitFunc,syntax="intel")

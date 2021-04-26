module JuliaJIT

export JITFunc, @call, remove, disassembleJIT
    
mutable struct JITFunc
    ptr:: Ptr{UInt8}
    size::Vector{Int64}
end

# notice ccall must use a const lib path

const  libpath="$(@__DIR__)/libexecfunc.so"

"""
add finalizer
"""
function JITFunc(filename)
    size=Vector{Int64}(undef,1)
    dir=@__DIR__
    filename="$(dir)/gene/$(filename)"
    ptr_func=ccall((:loadBinary,libpath),Ptr{UInt8},(Ptr{UInt8},Ptr{Int64}),pointer(filename),size)
    result=JITFunc(ptr_func,size)
    f(result)=(@async println("remove $(result)");remove(result))
    finalizer(f,result)
end

function Base.show(io::IO, jitFunc::JITFunc)
    print(io::IO,"JITFunc at $(UInt64(jitFunc.ptr)) with size $(jitFunc.size[1])")
end


function remove(jitFunc::JITFunc)
    ccall((:free_page,libpath),Cvoid,(Ptr{UInt8},Int64),jitFunc.ptr,jitFunc.size[1])
end


function convertToCall(jitFunc,types,args...)
    jitFuncPtr=:($(jitFunc).ptr)
    para_types=types.args[2]
    return_types=types.args[3]
    Expr(:call,:ccall,jitFuncPtr,return_types,para_types,args...)
end

macro call( expr)
    esc(convertToCall(expr.args[1],expr.args[2],expr.args[3:end]...))
end

function writeString(filename,content)
    f=open(filename,"w")
    write(f,content)
    close(f)
end


"""
mode can bet gas or nasm,
use different assembler to compile the source string
for asm, one require `BITS 64` at the beginning
add different mode
"""
function compileAsm(asm,filebase; mode="gas")
    dir=@__DIR__
    filebase="$(dir)/gene/$(filebase)"
    asmfile="$(filebase).s"
    writeString(asmfile,asm)
    if(mode=="gas")
        objfile="$(filebase).o"
        run(`as $(asmfile) -o $(objfile) `)
        run(`ld --oformat binary  $(objfile) -o $(filebase)`)
    end
    if(mode=="nasm")
        run(`nasm $(asmfile) -f bin -o $(filebase)`)
    end    
end


function JITFunc(asm::String,filename::String;mode="gas")
    compileAsm(asm,filename;mode=mode)
    JITFunc(filename)
end

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
    filename="$(@__DIR__)/czq_dump_jit.bin"
    dumpJITFunction(jitFunc::JITFunc,filename)
    run(`objdump -b binary -M $(syntax) -m i386:x86-64 -D $(filename)`)
end

end

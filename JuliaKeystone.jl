"""
binding for keystone library, which is based on llvm
"""
module JuliaKeystone

export ks_arch, ks_mode, compile
const libpath= "$(@__DIR__)/libkeystone.so.0"
"""
typedef enum ks_arch {
    KS_ARCH_ARM = 1,    // ARM architecture (including Thumb, Thumb-2)
    KS_ARCH_ARM64,      // ARM-64, also called AArch64
    KS_ARCH_MIPS,       // Mips architecture
    KS_ARCH_X86,        // X86 architecture (including x86 & x86-64)
    KS_ARCH_PPC,        // PowerPC architecture (currently unsupported)
    KS_ARCH_SPARC,      // Sparc architecture
    KS_ARCH_SYSTEMZ,    // SystemZ architecture (S390X)
    KS_ARCH_HEXAGON,    // Hexagon architecture
    KS_ARCH_EVM,        // Ethereum Virtual Machine architecture
    KS_ARCH_MAX,
} ks_arch;
"""
ks_arch_keys=[
    :KS_ARCH_ARM ,
    :KS_ARCH_ARM64,  
    :KS_ARCH_MIPS,      
    :KS_ARCH_X86,        
    :KS_ARCH_PPC,       
    :KS_ARCH_SPARC, 
    :KS_ARCH_SYSTEMZ, 
    :KS_ARCH_HEXAGON, 
    :KS_ARCH_EVM,       
    :KS_ARCH_MAX,
]

ks_arch=Dict{Symbol,Cint}()
[ks_arch[ks_arch_keys[i]]=i for i in 1:length(ks_arch_keys)]

function is_arch_supported(sym)
    ccall((:ks_arch_supported,libpath),Cuchar,(Cint,),ks_arch[sym])
end

# is_arch_supported(:KS_ARCH_X86)

"""
// Mode type
typedef enum ks_mode {
    KS_MODE_LITTLE_ENDIAN = 0,    // little-endian mode (default mode)
    KS_MODE_BIG_ENDIAN = 1 << 30, // big-endian mode
    // arm / arm64
    KS_MODE_ARM = 1 << 0,              // ARM mode
    KS_MODE_THUMB = 1 << 4,       // THUMB mode (including Thumb-2)
    KS_MODE_V8 = 1 << 6,          // ARMv8 A32 encodings for ARM
    // mips
    KS_MODE_MICRO = 1 << 4,       // MicroMips mode
    KS_MODE_MIPS3 = 1 << 5,       // Mips III ISA
    KS_MODE_MIPS32R6 = 1 << 6,    // Mips32r6 ISA
    KS_MODE_MIPS32 = 1 << 2,      // Mips32 ISA
    KS_MODE_MIPS64 = 1 << 3,      // Mips64 ISA
    // x86 / x64
    KS_MODE_16 = 1 << 1,          // 16-bit mode
    KS_MODE_32 = 1 << 2,          // 32-bit mode
    KS_MODE_64 = 1 << 3,          // 64-bit mode
    // ppc 
    KS_MODE_PPC32 = 1 << 2,       // 32-bit mode
    KS_MODE_PPC64 = 1 << 3,       // 64-bit mode
    KS_MODE_QPX = 1 << 4,         // Quad Processing eXtensions mode
    // sparc
    KS_MODE_SPARC32 = 1 << 2,     // 32-bit mode
    KS_MODE_SPARC64 = 1 << 3,     // 64-bit mode
    KS_MODE_V9 = 1 << 4,          // SparcV9 mode
} ks_mode;

"""

ks_mode=Dict{Symbol,Cint}(
    :KS_MODE_LITTLE_ENDIAN => 0,    
    :KS_MODE_BIG_ENDIAN => 1 << 30, 
    
    :KS_MODE_ARM => 1 << 0,              
    :KS_MODE_THUMB => 1 << 4,       
    :KS_MODE_V8 => 1 << 6,          
    
    :KS_MODE_MICRO => 1 << 4,       
    :KS_MODE_MIPS3 => 1 << 5,       
    :KS_MODE_MIPS32R6 => 1 << 6,    
    :KS_MODE_MIPS32 => 1 << 2,      
    :KS_MODE_MIPS64 => 1 << 3,      
    
    :KS_MODE_16 => 1 << 1,          
    :KS_MODE_32 => 1 << 2,          
    :KS_MODE_64 => 1 << 3,          
    
    :KS_MODE_PPC32 => 1 << 2,       
    :KS_MODE_PPC64 => 1 << 3,       
    :KS_MODE_QPX => 1 << 4,         
    
    :KS_MODE_SPARC32 => 1 << 2,     
    :KS_MODE_SPARC64 => 1 << 3,     
    :KS_MODE_V9 => 1 << 4)

function compile(asm,arch,mode)
    ks_engine=Vector{Int64}(undef,1)
    err=ccall((:ks_open,libpath),Cint,(Cint,Cint,Ptr{Int64}),arch,mode,pointer(ks_engine))
    if(err!=0)
        error("err!\n")
    end    
    results=Vector{Int64}(undef,3)
    err=ccall((:ks_asm,libpath),Cint,(Int64,Ptr{UInt8},UInt64,Ptr{Int64},Ptr{Int64},Ptr{Int64}),ks_engine[1],pointer(asm),0,pointer(results),pointer(results)+8,pointer(results)+16)
    if(err!=0)
        error("err!\n")
    end    
    code_addr=Ptr{UInt8}(results[1])
    code=[unsafe_load(code_addr,i) for i in 1:results[2]]
    err=ccall((:ks_close,libpath),Cint,(Int64,),ks_engine[1])
    if(err!=0)
        error("err!\n")
    end
    return code
end

end


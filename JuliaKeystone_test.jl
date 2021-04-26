asm="mov eax,0x123 \n mov eax, 0x1\n movapd xmm0, [rdi]\nvmovapd ymm0, [rdi+0x13123123]"
long_asm=join([asm for i in 1:10000],"\n")
arch=ks_arch[:KS_ARCH_X86]
mode=ks_mode[:KS_MODE_64]
@time compile(long_asm,arch,mode)
@time compile(asm,arch,mode)

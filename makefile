all :  libexecfunc.so

libexecfunc.so: libexecfunc.c
	gcc -fPIC -shared -o $@ $<

# a.out: test_func.s
# 	as test_func.s -o a.o
# 	ld --oformat binary -o a.out a.o
# 	objdump -d a.o > a.s
# exec_code: exec_code.c
# 	gcc -o $@ $<


# test.s: test_func.c
# 	gcc  -fPIC -O3 -S  -o test.s test_func.c
# 	gcc  -fPIC -O3 -S -masm=intel  -o test_intel.s test_func.c
# 	gcc  -fPIC -O3 -c  -o test.o test_func.c
# 	objdump -d test.o > test_check.s
# 	ld --oformat binary -o test.bin test.o

# nasm.s: test_nasm.asm
# 	nasm test_nasm.asm -f bin -o test_nasm
# 	objdump -b binary  -m i386:x86-64 -D test_nasm > nasm.s

objects = mysysinfo.o mystdlib.o

mysysinfo : $(objects)
	ld -g -o mysysinfo $(objects)

mysysinfo.o : mysysinfo.asm mystdlib.o
	nasm -F dwarf -f elf64 mysysinfo.asm -l mysysinfo.lst

mystdlib.o : mystdlib.asm
	nasm -F dwarf -f elf64 mystdlib.asm -l mystdlib.lst

.PHONY : clean
clean :
	rm -f mysysinfo $(objects) *.lst

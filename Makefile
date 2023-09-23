# Odin code

all:
	odin build . -out:linux_dyslexic_help.exe

opti:
	odin build . -out:linux_dyslexic_help.exe -o:speed

clean:
	rm linux_dyslexic_help.exe

run:
	./linux_dyslexic_help.exe


# C code

c:
	gcc actkbd.c linux.c -o c_code.exe

cclean:
	rm c_code.exe

crun:
	./c_code.exe
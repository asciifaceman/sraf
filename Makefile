.PHONY: build compile link

all:
ifndef NAME
	$(error "Name not set")
endif

clean:
	rm -rf target/
	mkdir target/
	rm -rf *.o

compile:
	nasm -f elf64 -o target/sraf.o sraf.asm

link:
	ld -s -o target/sraf target/sraf.o

build: clean compile link

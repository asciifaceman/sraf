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
	ld -m elf_x86_64 -s -o target/sraf target/sraf.o 

compile-dev:
	nasm -g -f elf64 -F dwarf -o target/sraf.o sraf.asm

link-dev:
	ld -m elf_x86_64 -o target/sraf target/sraf.o

build: clean compile link

build-dev: clean compile-dev link-dev

build-and-run: clean compile link
	$(info Running against test.txt...)
	$(info )
	@target/sraf test.txt
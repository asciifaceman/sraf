# Stupid Read A File
The stupidest program you could possible use to read a file.

This is my first Assembly program, ever. I've wanted to learn assembly since I discovered it existed, 
but it always felt too far away and out of my grasp or understanding.

Well, I guess I learned that it is at least approachable for me now. I may never write GOOD ASM,
and this may look embarassingly bad to those of you who know ASM, but oh well - I did it.

SRAF Simply reads in a file and prints it to STDOUT.

# Target

Linux am64 - NASM

# Build

`make build`

or

`make build-dev` for symbols

# Run

`target/sraf {path_to_file}`

# Limitations / Bugs

* Limitations
  * The filepath can't exceed 255 byes/characters.

* Bugs
  * It seems to die on certain files (it can read 1mb.txt, sraf.asm, but not util.asm)
    * error occurs during slen, at `cmp byte [rdi], 0`
    * repro: `target/sraf util.asm`



floppy: boot kernel shell
	./source/makepfs.py out/portland.img part/boot.bin part/fs/*

boot:
	mkdir part
	nasm -f bin -o part/boot.bin source/boot.asm

kernel:
	make -C kernel
	mkdir -p part/fs
	mv kernel/out/* part/fs/

shell:
	make -C shell
	mkdir -p part/fs
	mv shell/out/* part/fs/

clean:
	rm -r part out
	make clean -C kernel
	make clean -C shell

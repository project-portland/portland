floppy: boot kernel shell
	./source/makepfs.py part/portland.pfs part/boot.bin part/fs/*
	dd if=/dev/zero of=out/portland.img bs=512 count=2880
	dd if=part/portland.pfs of=out/portland.img conv=notrunc

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

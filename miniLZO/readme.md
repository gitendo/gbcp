`lzocomp-0.21.tar.gz` and `lzocomp-0.21_dos.zip` are original files from [the past](https://web.archive.org/web/19991005082405/http://www.pcmedia.co.nz/~michaelh/). They both contain `miniLZO v1.04` by Markus F.X.J. Oberhumer and `lzocomp 0.21` (that does packing) by Michael Hope. Since compiling it looks troublesome I've used DOS version for comparison. On the other hand, the [latest version](http://www.oberhumer.com/opensource/lzo/) of `miniLZO` compiles fine but compressed files have worse ratio. I've no time to investigate it at this moment so I leave this as it is.

`minilzo-gb-0.21.tar.gz` contains original decompression routine by Michael Hope but its source format is obsolete. I've converted it to work with latest [RGBASM](https://github.com/gbdev/rgbds) and saved a couple of cycles here and there. This might be good base for further optimizations. ;)